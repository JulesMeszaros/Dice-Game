local Shop = require("src.screens.Shop")
local DeskChoice = require("src.screens.DeskChoice")
local DiceCustomization = require("src.screens.DiceCustomization")
local Infos = require("src.classes.ui.Infos")
local MainMenu = require("src.screens.MainMenu")
local Constants = require("src.utils.Constants")
local Floor = require("src.classes.Floor")
local CiggieTypes = require("src.classes.CiggieTypes")
local Animator = require("src.utils.Animator")

local Run = {}

Run.__index = Run

function Run:new(dices, gameCanvas, game, diceObjects)
	local self = setmetatable({}, Run)

	self.animator = Animator:new(self)

	self.facesInventory = {}
	self.facesRewardsInventory = {}

	--Stickers
	--On créée deux listes de stickers. Une pour les stickers normeaux, une pour les stickers de case.
	self.stickers = {} --Liste pour les objets stickers
	self.uiStickers = {} --Liste pour les objets visuels de stickers
	self.caseStickers = {} --Liste pour les objets stickers attribués à des cases

	--Ciggies
	self.ciggiesObjects = {}
	--Run stats
	self.totalUsedCiggie = 0
	self.totalUsedCoffees = 0
	self.totalDisabled = 0
	self.bestHand = 0
	self.lastLeveledUpFigure = 0
	self.hivemindTriggers = 0

	self.shop = nil

	--Dices variables
	self.drawedDices = {} --Current Drawed Dices
	--Drag variables (should rather be located in the Game class i guess...)
	self.isDragging = false
	self.dragOriginX = nil
	self.dragOriginY = nil
	self.draggingTreshold = 10
	--Gameplay variables
	self.usedRerolls = 0 --total rerolls used for this game
	--Run variables

	self.roundNumber = 0 --Représente le numéro de round total
	--Run state
	self.currentState = Constants.RUN_STATES.ROUND
	self.runPaused = false

	--Creating base stats (modifiables par les stickers)
	self.baseHands = Constants.BASE_TURNS
	self.baseRerolls = Constants.BASE_REROLLS
	self.baseShopRerollPrice = Constants.BASE_SHOP_REROLL_PRICE

	--Money
	self.additionalMoney = 0
	self.money = 5
	self.totalspent = 0

	--Figures playcount and level
	self.figuresInfos = {}
	for k, f in next, Constants.FIGURES do
		self.figuresInfos[f] = { level = 1, playcount = 0 }
	end

	--The canvas the game is rendered on.
	self.gameCanvas = gameCanvas
	self.game = game

	--On attribue le set de dés
	self.diceObjects = diceObjects

	--Sets the number of time we can play a figure

	self.baseAvailableHands = {}
	for i = 1, 13 do
		table.insert(self.baseAvailableHands, Constants.BASE_AVAILABLE_HANDS)
	end

	self:resetAvailableFigures()

	--Floor variables
	--Create the first floor of the game
	self.currentFloor = Floor:new(1, self)

	self.floorNumber = 1 --Représente l'étage (augmente de 1 après un boss)
	self.floorDeskNumber = 1 --Représente le numéro de bureau dans l'étage actuel (retourne à 1 après un boss)
	self:goToRoundSelection()

	return self
end

function Run:update(dt)
	if self.runPaused ~= true then
		self.animator:update(dt)
		if self.currentState == Constants.RUN_STATES.ROUND then
			--update Round
			self.currentRound:update(dt)
		elseif self.currentState == Constants.RUN_STATES.SHOP then
			--update shop
			self.shop:update(dt)
		elseif self.currentState == Constants.RUN_STATES.ROUND_CHOICE then
			--update shop
			self.deskChoice:update(dt)
		elseif self.currentState == Constants.RUN_STATES.GAME_OVER then
			self.gameOver:update(dt)
		elseif self.currentState == Constants.RUN_STATES.DICE_CUSTOMIZATION then
			self.customizationScreen:update(dt)
		end
	else
		self.infoScreen:update(dt)
		self.infoScreen:updateCanvas(dt)
	end
end

function Run:draw(gameCanvas) --Render the game into the Game Canvas.
	if self.currentState == Constants.RUN_STATES.ROUND then --check if we are in round
		self:drawRound() --Draw the round
	elseif self.currentState == Constants.RUN_STATES.SHOP then --check if we are in shop
		self.shop:draw() --Draw the shop
	elseif self.currentState == Constants.RUN_STATES.ROUND_CHOICE then --check if we are in shop
		self.deskChoice:draw() --Draw the shop
	elseif self.currentState == Constants.RUN_STATES.GAME_OVER then
		self.gameOver:draw()
	elseif self.currentState == Constants.RUN_STATES.DICE_CUSTOMIZATION then
		self.customizationScreen:draw()
	end

	--Info screen
	if self.runPaused == true and self.infoScreen then
		self.infoScreen:draw()
	end
end

--==ROUND FUNCTIONS==--
function Run:createNewFloor()
	local floorNumber = self.currentFloor.floorNumber + 1
	local newFloor = Floor:new(floorNumber, self)
	return newFloor
end

function Run:goToNextRound()
	--Calculate the money earned, based on the number of hands remaining
	local moneyEarned = self.currentRound.remainingHands + self.currentRound.baseReward + self.additionalMoney
	self.money = self.money + moneyEarned

	--Increments the desk, and goes to the next floor if the desk rank is > 3
	self.floorDeskNumber = self.floorDeskNumber + 1

	if self.currentRound.roundType == Constants.ROUND_TYPES.BOSS then --Si le rank de desktop est superieur à 4 (donc que le bosse vient d'etre battu) on créée un nouvel étage
		--On vérifie que la run soit terminée (étage 5 atteint)
		if self.currentFloor.floorNumber == Constants.FLOORS_BY_RUN then
			self.game.mainMenu = MainMenu:new(nil, self.game)
			self.game.currentScreen = Constants.PAGES.MAIN_MENU
			return
		end

		self.currentFloor = self:createNewFloor()
		self.floorDeskNumber = 1

		--Resets the available hands
		self:resetAvailableFigures()
	end

	--Adds the rewards to the rewards inventory
	self.facesRewardsInventory = {} --On le vide par mesure de sécurité
	for i, face in next, self.currentRound.faceRewards do
		table.insert(self.facesRewardsInventory, face)
	end

	--GOTO Shop, seulement si on est à la fin d'un étage, ou que la fonction debug associée est activée
	if self.currentRound.roundType == Constants.ROUND_TYPES.BOSS or Constants.SHOP_EVERY_DESK == true then
		self.shop = Shop:new(self)
		self.currentState = Constants.RUN_STATES.SHOP
	else
		--GOTO dice customization

		self:goToDiceCustomization()
	end
end

--==INFO MENU FUNCTION==--
function Run:startInfoScreen()
	self.runPaused = true
	self.infoScreen = Infos:new(self)
end

function Run:endInfoScreen()
	self.runPaused = false
	self.infoScreen = nil
end

function Run:toggleInfoScreen()
	if self.runPaused == true then
		self:endInfoScreen()
	else
		self:startInfoScreen()
	end
end

--==DRAW FUNCTIONS==--

function Run:drawRound()
	--Set the right canvas
	love.graphics.draw(self.currentRound.terrain.canvas, self.currentRound.terrain.x, self.currentRound.terrain.y)
end

--==INPUTS FUNCTIONS==

function Run:keypressed(key)
	if self.currentState == Constants.RUN_STATES.ROUND then
		self.currentRound:keypressed(key)
	elseif self.currentState == Constants.RUN_STATES.SHOP then
		self.shop:keypressed(key)
	elseif self.currentState == Constants.RUN_STATES.ROUND_CHOICE then
		self.deskChoice:keypressed(key)
	elseif self.currentState == Constants.RUN_STATES.GAME_OVER then
		self.gameOver:keypressed(key)
	elseif self.currentState == Constants.RUN_STATES.DICE_CUSTOMIZATION then
		self.customizationScreen:keypressed(key)
	end

	if key == "m" then
		self.money = 20000
	end

	if key == "f" then
		self:resetAvailableFigures()
	end
end

function Run:mousepressed(x, y, button, istouch, presses)
	--Met les coordonnées de drag à 0
	self.dragOriginX = x
	self.dragOriginY = y

	if self.runPaused == false then
		if self.currentState == Constants.RUN_STATES.ROUND then
			self.currentRound.terrain:mousepressed(x, y, button, istouch, presses)
		elseif self.currentState == Constants.RUN_STATES.SHOP then
			self.shop:mousepressed(x, y, button, istouch, presses)
		elseif self.currentState == Constants.RUN_STATES.ROUND_CHOICE then
			self.deskChoice:mousepressed(x, y, button, istouch, presses)
		elseif self.currentState == Constants.RUN_STATES.GAME_OVER then
			self.gameOver:mousepressed(x, y, button, istouch, presses)
		elseif self.currentState == Constants.RUN_STATES.DICE_CUSTOMIZATION then
			self.customizationScreen:mousepressed(x, y, button, istouch, presses)
		end
	else
		self.infoScreen:mousepressed(x, y, button, istouch, presses)
	end
end

function Run:mousereleased(x, y, button, istouch, presses)
	if self.runPaused == false then
		if self.currentState == Constants.RUN_STATES.ROUND then
			self.currentRound.terrain:mousereleased(x, y, button, istouch, presses)
		elseif self.currentState == Constants.RUN_STATES.SHOP then
			self.shop:mousereleased(x, y, button, istouch, presses)
		elseif self.currentState == Constants.RUN_STATES.ROUND_CHOICE then
			self.deskChoice:mousereleased(x, y, button, istouch, presses)
		elseif self.currentState == Constants.RUN_STATES.GAME_OVER then
			self.gameOver:mousereleased(x, y, button, istouch, presses)
		elseif self.currentState == Constants.RUN_STATES.DICE_CUSTOMIZATION then
			self.customizationScreen:mousereleased(x, y, button, istouch, presses)
		end
	else
		self.infoScreen:mousereleased(x, y, button, istouch, presses)
	end

	--Deactivate dragging
	self.isDragging = false
end

function Run:mousemoved(x, y, dx, dy)
	if self.runPaused == false then
		if self.currentState == Constants.RUN_STATES.ROUND then
			self.currentRound.terrain:mousemoved(x, y, dx, dy, self.isDragging)
		elseif self.currentState == Constants.RUN_STATES.SHOP then
			self.shop:mousemoved(x, y, dx, dy, self.isDragging)
		elseif self.currentState == Constants.RUN_STATES.ROUND_CHOICE then
			self.deskChoice:mousemoved(x, y, dx, dy, self.isDragging)
		elseif self.currentState == Constants.RUN_STATES.GAME_OVER then
			self.gameOver:mousemoved(x, y, dx, dy, self.isDragging)
		elseif self.currentState == Constants.RUN_STATES.DICE_CUSTOMIZATION then
			self.customizationScreen:mousemoved(x, y, dx, dy, self.isDragging)
		end
	else
		self.infoScreen:mousemoved(x, y, dx, dy, self.isDragging)
	end
	--x et y sont la position, dx et dy sont la vitesse.

	if love.mouse.isDown(1) and self.dragOriginX and self.dragOriginY then
		if
			math.abs(love.mouse.getX() - self.dragOriginX) > self.draggingTreshold
			or math.abs(love.mouse.getY() - self.dragOriginY) > self.draggingTreshold
		then
			self.isDragging = true
		end
	end
end

--Run functions

function Run:resetAvailableFigures()
	self.availableFigures = {}
	for k, f in next, self.baseAvailableHands do
		self.availableFigures[k] = self.baseAvailableHands[k]
	end
end

function Run:levelUpFigure(index)
	self.lastLeveledUpFigure = index
	if index >= 1 and index <= 13 then
		self.figuresInfos[index].level = self.figuresInfos[index].level + 1
	end
end

--==Change screen==--
function Run:goToRoundSelection()
	local deskchoice = DeskChoice:new(self.currentFloor, self)
	self.deskChoice = deskchoice

	self.currentState = Constants.RUN_STATES.ROUND_CHOICE --Change d'état de Run
end

function Run:startNewRound(round, roundtype)
	--Sets the round number
	self.roundNumber = self.roundNumber + 1

	self.currentRound = round

	--Changes the screen to the round screen
	self.currentState = Constants.RUN_STATES.ROUND
end

function Run:goToDiceCustomization()
	self.customizationScreen = DiceCustomization:new(self.currentRound, self.facesInventory)
	self.currentState = Constants.RUN_STATES.DICE_CUSTOMIZATION
end

function Run:cleanup()
	-- Cleanup shop screen
	if self.shop then
		if self.shop.shopCanvas then
			self.shop.shopCanvas:release()
			self.shop.shopCanvas = nil
		end
		self.shop = nil
	end

	-- Cleanup desk choice screen
	if self.deskChoice then
		self.deskChoice = nil
	end

	-- Cleanup current round
	if self.currentRound then
		if self.currentRound.terrain and self.currentRound.terrain.canvas then
			self.currentRound.terrain.canvas:release()
			self.currentRound.terrain.canvas = nil
		end
		self.currentRound = nil
	end

	-- Cleanup customization screen
	if self.customizationScreen then
		self.customizationScreen = nil
	end

	-- Cleanup game over screen
	if self.gameOver then
		self.gameOver = nil
	end

	-- Clear large tables
	self.diceObjects = {}
	self.facesInventory = {}
	self.facesRewardsInventory = {}
	self.ciggiesObjects = {}
end

--Sticker functions
function Run:stickerStartRoundEffect()
	for i, sticker in next, self.stickers do
		sticker:startRoundEffect(self)
	end
end

function Run:stickerEndRoundEffect()
	for i, sticker in next, self.stickers do
		sticker:endRoundEffect(self)
	end
end

function Run:stickerFigurePlayedEffect()
	for i, sticker in next, self.stickers do
		sticker:figurePlayedEffect(self)
	end
end

function Run:stickerEndTriggeringPhaseEffect()
	for i, sticker in next, self.stickers do
		sticker:endTriggerEffect(self)
	end
end

function Run:stickerRerollEffect()
	for i, sticker in next, self.stickers do
		sticker:rerollEffect(self)
	end
end

return Run
