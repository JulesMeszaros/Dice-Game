--Ceci est le premier fichier créé à l'aide de NeoVim, pour l'histoire.

local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local AnimationUtils = require("src.utils.scripts.Animations")
local Sprites = require("src.utils.Sprites")
local Ciggie = require("src.classes.ui.Ciggie")
local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")
local Badge = require("src.classes.ui.Badge")
local DiceFace = require("src.classes.ui.DiceFace")
local Screen = require("src.classes.GameScreen")
local UI = require("src.utils.scripts.UI")
local Fonts = require("src.utils.Fonts")
local Deck = require("src.classes.ui.Deck")
local TutorialEvents = require("src.utils.TutorialEvents")

local DeskChoice = setmetatable({}, { __index = Screen })
DeskChoice.__index = DeskChoice

local choiceNumber = 4

function DeskChoice:new(floor, run)
	local self = setmetatable(Screen:new(floor, run, Constants.RUN_STATES.ROUND_CHOICE), DeskChoice)

	--Tutorial function
	if self.run.floorNumber == 1 or (self.run.floorNumber == 2 and self.run.floorDeskNumber == 1) then
		self.canSelectRound = false
	else
		self.canSelectRound = true
	end

	self.dragAndDroppedObject = nil

	--Créer le deck
	self:createDeck()

	--Créer le dice net
	--self:createDiceNet()

	self.round = run.currentRound

	if self.run.floorDeskNumber <= Constants.DESKS_BY_FLOOR then
		self.possibleRounds = self.floor.desks[self.run.floorDeskNumber]
	else
		self.possibleRounds = { self.floor.boss }
		self.animator:addDelay(0.0, function()
			--Si boss d'étage : on ajoute un texte wavy
			self.bossWavyText = UI.Text.TextWavy:new("Face the manager!", 890, 110, {
				colorStart = { 255 / 255, 104 / 255, 147 / 255 },
				colorEnd = { 176 / 255, 169 / 255, 228 / 255 },
				amplitude = 5,
				speed = 3,
				centered = true,
				font = Fonts.soraLarge,
				revealSpeed = 40,
			})
			--Description de boss (nom)
			self.bossWavyTitle = UI.Text.TextWavy:new(
				Constants.BOSS_TYPES_DESC[self.possibleRounds[1].bossType][1],
				self.bossDesc:getWidth() / 2,
				30,
				{
					colorStart = { 0, 0, 0 },
					amplitude = 2,
					speed = 1,
					centered = true,
					font = Fonts.sora30,
					revealSpeed = 40,
				}
			)

			--Description de boss
			self.bossWavyDesc = UI.Text.TextWavy:new(
				Constants.BOSS_TYPES_DESC[self.possibleRounds[1].bossType][2],
				self.bossDesc:getWidth() / 2,
				80,
				{
					colorStart = { 0, 0, 0 },
					amplitude = 2,
					speed = 1,
					centered = true,
					font = Fonts.soraSmall,
					revealSpeed = 40,
				}
			)
		end)
	end

	self.showText = true

	--Création des différents canvas de choix de round
	self:generateChoiceCanvas()

	--Apparition des cigarettes à la toute fin
	self.animator:addDelay(0.5, function()
		self:generateCiggiesUI()
	end)

	if self.run.tutorial then
		self.animator:addDelay(0.3, TutorialEvents.deskChoice)

		if self.run.roundNumber == 2 then
			self.animator:addDelay(0.3, TutorialEvents.managerSelection)
		end

		if self.run.floorNumber == 2 then
			self.animator:addDelay(0.3, TutorialEvents.secondFloor)
		end
		print("floor", self.run.floorNumber)
	end

	--self:createHorizontalDice()

	return self
end

function DeskChoice:update(dt)
	if love.timer.getTime() % 0.1 < dt then
		self.scoresChanged = true
	end

	self.animator:update(dt)
	if self.showDeck == false then
		if self.bossWavyText and self.showText == true then
			self.bossWavyText:update(dt)
			self.bossWavyText:draw()
		end

		--Check if a ciggie is being dragged to the screen
		self:checkForDraggedCiggie()
	end

	if self.showDeck and self.deckScreen then
		self.deckScreen:update(dt)
	end

	--hovered objects
	self:getCurrentlyHoveredFace()
	self:getCurrentlyHoveredCiggie()
	self:getCurrentlyHoveredObject()

	--Update canvas
	self:updateCanvas(dt)
end

function DeskChoice:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	self:drawRightPanel(dt)

	if self.showDeck == false then
		--Dessine le panneau de droite (deck + infos + boutons)
		self:updateChoiceCanvas(dt)
		if self.run.floorDeskNumber > Constants.DESKS_BY_FLOOR then
			self:drawBossDesc(dt)
		end
		self:drawHorizontalDice(dt)
		--Upgrading figure popup
		if self.addingAvailableHand == true then
			self:drawUpgradingFigurePopup(dt)
		end
	else
		self.deckScreen:draw()
	end
	self:drawFigureGrid()

	--Ciggie Popup

	if self.previousCiggieDraggedState ~= self.draggedCiggie then
		if self.draggedCiggie then
			self:startCiggiePopUp()
		else
			self:endCiggiePopup()
		end
	end

	if self.showCiggiePopup then
		self:drawCiggiePopup(dt)
	end

	--self:drawDescription()
	self:drawCiggiesTray()

	--Ciggies UI
	for i, ciggie in next, self.uiElements.ciggiesUI do
		ciggie:update(dt)
		if ciggie ~= self.dragAndDroppedObject then
			ciggie:draw()
		end
	end

	if self.dragAndDroppedObject then
		self.dragAndDroppedObject:draw()
	end

	self:drawCiggiesTrayFront()

	if self.currentlyHoveredObject then
		--Info bubble (wip)
		self.infoBubble.x, self.infoBubble.y =
			self.currentlyHoveredObject.x + self.currentlyHoveredObject.absoluteX,
			self.currentlyHoveredObject.y + self.currentlyHoveredObject.absoluteY
		--self.infoBubble.x, self.infoBubble.y = self.currentlyHoveredFace.x , self.currentlyHoveredFace.y
		self.infoBubble:update(dt)
		self.infoBubble:draw()
	end

	if self.run.tutorial and self.run.tutorial.current then
		self:drawTutoText()
	end

	if self.run.tutorial and self.run.tutorial.currentToast then
		self:drawTutoToast()
	end

	love.graphics.setCanvas(currentCanvas)
end

function DeskChoice:draw()
	love.graphics.draw(self.canvas, 0, 0)
end

--==UI==--

--Deck

--TODO: move in gamescreen.lua
function DeskChoice:createDeck()
	local deckFaces = {}
	for i, dice in next, self.diceObjects do
		--Create the UIFaces
		local faceUI = DiceFace:new(
			dice,
			dice:getFace(1),
			self.deckCanvas:getWidth() / 2,
			60 + 73 + ((i - 1) * 152),
			120,
			true,
			true,
			function()
				return Inputs.getMouseInCanvas(1460, 30)
			end,
			nil,
			1460,
			30
		)
		deckFaces[dice] = faceUI
	end
	self.deckFaces = deckFaces
end

--TODO: move in gamescreen.lua

--TODO: move in gamescreen.lua
function DeskChoice:updateDiceNet(dt)
	local i = 1
	for k, df in next, self.infoFaces do
		df:setRepresentedFace(self.currentlySelectedDice.diceObject:getFace(i))
		df:updateSprite()
		df:update(dt)
		df:draw()
		i = i + 1
	end
end

--==CHOICES==--
function DeskChoice:generateChoiceCanvas()
	self.badges = {}

	local coords = {
		{ 590, 30 },
		{ 990, 30 },
		{ 590, 550 },
		{ 990, 550 },
	}

	if self.run.floorDeskNumber > Constants.DESKS_BY_FLOOR then
		coords = { { 620, 170 } }
	end

	local originalY = {
		-1000,
		-1000,
		3000,
		3000,
	}

	for i = 1, table.getn(self.possibleRounds) do
		if self.possibleRounds[i].roundType == Constants.ROUND_TYPES.BOSS then
			local b = Badge:new(self.possibleRounds[i], coords[i][1], coords[i][2], originalY[i], 540, 680, function()
				return Inputs.getMouseInCanvas(0, 0)
			end, true)
			table.insert(self.badges, b)
		else
			local b = Badge:new(self.possibleRounds[i], coords[i][1], coords[i][2], originalY[i], 370, 500, function()
				return Inputs.getMouseInCanvas(0, 0)
			end)
			table.insert(self.badges, b)
		end
	end
end

function DeskChoice:updateChoiceCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()

	for i, badge in next, self.badges do
		badge:update(dt)
		badge:draw()
	end
end

--==INPUT FUNCTIONS==--

function DeskChoice:keypressed(key)
	if key == "d" then
		self.deckScreen = Deck:new()
		self.showDeck = not self.showDeck
	end
end

function DeskChoice:mousepressed(x, y, button, istouch, presses)
	--Buttons
	for key, button in next, self.uiElements.buttons do
		button:clickEvent()
	end

	if self.showDeck == false then
		--Badges
		for key, badge in next, self.badges do
			badge:clickEvent()
		end

		--Deck faces
		for key, uiFace in next, self.deckFaces do
			uiFace:clickEvent()
		end

		--Figure buttons
		self.clickedFigure = self:getCurrentlyHoveredLine()
	end

	--Ciggies
	for key, ciggie in next, self.uiElements.ciggiesUI do
		ciggie:clickEvent()
	end
end

function DeskChoice:mousereleased(x, y, button, istouch, presses)
	self.dragAndDroppedObject = nil
	if self.showDeck == false then
		--release event on UI elements (badges)
		for key, badge in next, self.badges do
			local wasReleased = badge:releaseEvent()
			if wasReleased then --Si le click a été complété
				if not self.run.tutorial or self.canSelectRound == true then
					self:outAnimation(badge)
				end
			end
		end
		--Gestion des dés dans le deck vertical à droite
		self.previouslySelectedDice = self.currentlySelectedDice
		self.horizontalDiceNet = nil
		self.currentlySelectedDice = nil
		self:resetSelectedDices()
		for key, face in next, self.deckFaces do
			local wasReleased = face:releaseEvent()
			if wasReleased then
				--On sélectionne la face a switcher
				if face ~= self.previouslySelectedDice then
					face:setSelected(true)
					self.currentlySelectedDice = face
					self:createHorizontalDice(face)
				else
					face:setSelected(false)
				end
				--On créée une animation pour les faces de dé à droite (à supprimer)
			end
		end
	end
	--release event on UI elements (buttons)
	for key, button in next, self.uiElements.buttons do
		local wasReleased = button:releaseEvent()
		if wasReleased then --Si le click a été complété
			button:getCallback()()
		end
	end

	--Ciggies
	for key, ciggie in next, self.uiElements.ciggiesUI do
		ciggie:releaseEvent()
		ciggie.isBeingDragged = false
		if self.showDeck == false then
			self:ciggieReleaseAction(ciggie)
		end
	end

	--Figure buttons
	if self.clickedFigure and self.clickedFigure ~= 7 then
		if self.clickedFigure == self:getCurrentlyHoveredLine() then
			if self.addingAvailableHand == true then
				self:addAvailableHand(self.clickedFigure)
			end
		end
	end
end

function DeskChoice:mousemoved(x, y, dx, dy, isDragging)
	--Drag and drop Ciggies
	if isDragging == true then
		for key, ciggie in next, self.uiElements.ciggiesUI do
			if ciggie.isDraggable and ciggie.isBeingClicked then
				ciggie.isBeingDragged = true
				self.dragAndDroppedObject = ciggie
				ciggie.dragXspeed = dx
				ciggie.targetX = x
				ciggie.targetY = y
				break
			end
		end
	end
end

--==Utils==--

function DeskChoice:outAnimation(badge)
	if self.run.tutorial then
		self.run.tutorial:confirmToast("oponentSelect")
	end
	self.showText = false
	local outDuration = 0.3
	local newBadgeY = {
		-1000,
		-1000,
		3000,
		3000,
	}
	--UI
	self.animator:addGroup({
		{
			property = "gridX",
			from = self.gridX,
			targetValue = 0 - self.figureButtonsCanvas:getWidth() - 40,
			duration = outDuration,
			easing = AnimationUtils.Easing.inOutCubic,
		},

		--right Pannel

		{
			property = "rightPanelX",
			from = self.rightPanelX,
			targetValue = self.canvas:getWidth() + 550,
			duration = outDuration,
			easing = AnimationUtils.Easing.inOutCubic,
		},

		{
			property = "bossDescY",
			from = self.bossDescY,
			targetValue = self.canvas:getHeight() + 400,
			duration = outDuration,
			easing = AnimationUtils.Easing.inOutCubic,
		},

		{
			property = "ciggiesTrayX",
			from = self.ciggiesTrayX,
			targetValue = self.canvas:getWidth() + 650,
			duration = outDuration,
			easing = AnimationUtils.Easing.inOutCubic,
		},
	})

	--Bages
	for i = 1, table.getn(self.badges) do
		self.badges[i].animator:add("y", self.badges[i].y, newBadgeY[i], 0.4, AnimationUtils.Easing.inCubic)
	end

	--Ciggarettes
	for i, c in next, self.uiElements.ciggiesUI do
		c.animator:addGroup({
			{ property = "scaleX", from = c.scaleX, targetValue = 0, duration = outDuration / 2 },
			{ property = "scaleY", from = c.scaleY, targetValue = 0, duration = outDuration / 2 },
			{
				property = "baseTargetedScale",
				from = c.baseTargetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = c.targetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})
	end

	self.animator:addDelay(0.5, function()
		self.run:startNewRound(badge.round, badge.round.roundtype)
	end)
end

function DeskChoice:resetSelectedDices()
	--Dice faces
	for key, face in next, self.deckFaces do
		face:setSelected(false)
	end
end

function DeskChoice:getCurrentlyHoveredCiggie()
	self.currentlyHoveredCiggie = nil

	for i, ciggie in next, self.uiElements.ciggiesUI do
		if ciggie:isHovered() then
			self.currentlyHoveredCiggie = ciggie
			break
		end
	end
end

function DeskChoice:getCurrentlyHoveredFace()
	self.previouslyHoveredFace = self.currentlyHoveredFace --We save the state of the frame before
	self.currentlyHoveredFace = nil

	local canvasX = nil
	local canvasY = nil

	--Faces de la vue de deck
	if self.showDeck == true then
		self.currentlyHoveredFace = self.deckScreen:getCurrentlyHoveredFace()
		return
	end
	--Deck sur le coté droit
	if self.horizontalDiceNet then
		for i, df in next, self.horizontalDiceFaces do
			if df:isHovered() then
				self.currentlyHoveredFace = df
				return
			end
		end
	end

	--Pour les faces dans le patron à droite
	--[[
	for i, face in next, self.infoFaces do
		if face:isHovered() and self.currentlySelectedDice then
			self.currentlyHoveredFace = face
			break
		end
	end]]
	--

	--Pour les faces de badges
	for i, badge in next, self.badges do
		if badge.currentlyHoveredFace then
			self.currentlyHoveredFace = badge.currentlyHoveredFace
			break
		end
	end
	--Si un dé est survolé et qu'il est différent du dé précédent alors on créé un nouveau canvas d'infos
end

--Gets the currently hovered object (dice, ciggie, etc...)
function DeskChoice:getCurrentlyHoveredObject()
	local object = nil

	if self.currentlyHoveredCiggie then
		self.currentlyHoveredObject = self.currentlyHoveredCiggie
	elseif self.currentlyHoveredFace then
		self.currentlyHoveredObject = self.currentlyHoveredFace
	else
		self.currentlyHoveredObject = nil
	end
end

function DeskChoice:getCurrentlyHoveredLine()
	local mv = Inputs.getMouseInCanvas(30, 30) --get the mouse position
	local i = math.floor((mv.y - 90) / 70) + 1

	if i > 0 and i <= 13 then
		if mv.x > 0 and mv.x < self.figureButtonsCanvas:getWidth() then
			return i
		end
	else
		return nil
	end
end

function DeskChoice:drawBossDesc(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.bossDesc)
	love.graphics.clear()

	--bakground
	love.graphics.draw(Sprites.BOSS_DESC, 0, 0)

	--Text

	if self.bossWavyDesc and self.bossWavyTitle then
		self.bossWavyTitle:update(dt)
		self.bossWavyTitle:draw(dt)
		self.bossWavyDesc:update(dt)
		self.bossWavyDesc:draw(dt)
	end

	love.graphics.setCanvas(currentCanvas)
	love.graphics.draw(self.bossDesc, self.bossDescX, self.bossDescY, 0, 1, 1)
end

return DeskChoice
