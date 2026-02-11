local TutorialEvents = require("src.utils.TutorialEvents")
local StickerTypes = require("src.classes.StickerTypes")
local StickerObject = require("src.classes.StickerObject")
local Sticker = require("src.classes.ui.Sticker")
local Deck = require("src.classes.ui.Deck")
local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local AnimationUtils = require("src.utils.scripts.Animations")
local Sprites = require("src.utils.Sprites")
local Ciggie = require("src.classes.ui.Ciggie")
local DiceFace = require("src.classes.ui.DiceFace")
local Screen = require("src.classes.GameScreen")
local FaceTypes = require("src.classes.FaceTypes")
local Fonts = require("src.utils.Fonts")
local CiggieTypes = require("src.classes.CiggieTypes")
local CoffeeButton = require("src.classes.ui.CoffeeButton")
local UI = require("src.utils.scripts.UI")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")

local Shop = setmetatable({}, { __index = Screen })
Shop.__index = Shop

function Shop:new(run)
	local self = setmetatable(Screen:new(run.currentFloor, run, Constants.RUN_STATES.SHOP, run.currentRound), Shop)

	--Tutorial variables
	self.canBuyDiceFace = false
	self.canBuySticker = false
	self.canBuyAnything = false
	self.canRerollShop = false
	self.canGoToNextRound = false

	self.priceTagsScale = 1
	self:createDeck()
	self.dragAndDroppedObject = nil

	--Toggle for the first shop generation
	self.firstShopGeneration = true

	--Wavy Texts
	self.sellText = UI.Text.TextWavy:new("Sell (3$)", 250, 950, {
		font = Fonts.SoraBig,
		centered = true,
		amplitude = 5,
		speed = 2,
		colorStart = { 255 / 255, 178 / 255, 89 / 255 },
		colorEnd = { 255 / 255, 178 / 255, 89 / 255 },
	})

	self.buyCiggieText = UI.Text.TextWavy:new(
		"Buy (" .. tostring(Constants.BASE_CIGGIE_PRICE) .. "$)",
		self.ciggiesTrayTX + self.ciggiesTray:getWidth() / 2,
		self.ciggiesTrayTY + self.ciggiesTray:getHeight() / 2,
		{
			font = Fonts.soraMedium,
			centered = true,
			amplitude = 5,
			speed = 2,
			colorStart = { 1, 1, 1 },
			colorEnd = { 1, 1, 1 },
		}
	)

	self.useCiggieText = UI.Text.TextWavy:new(
		"Use Now (" .. tostring(Constants.BASE_CIGGIE_PRICE) .. "$)",
		30 + Sprites.USE_NOW:getWidth() / 2,
		self.canvas:getHeight() - 30 - Sprites.USE_NOW:getHeight() / 2,
		{
			font = Fonts.soraMedium,
			centered = true,
			amplitude = 5,
			speed = 2,
			colorStart = { 1, 1, 1 },
			colorEnd = { 1, 1, 1 },
		}
	)

	self.buyText = UI.Text.TextWavy:new(
		"Buy (5$)",
		self.inventorySMTX + self.inventoryCanvasSmall:getWidth() / 2,
		self.inventorySMTY + self.inventoryCanvasSmall:getHeight() / 2,
		{
			font = Fonts.SoraBig,
			centered = true,
			amplitude = 5,
			speed = 2,
		}
	)

	self.addRewardText = UI.Text.TextWavy:new(
		"Add to inventory?",
		self.inventorySMTX + self.inventoryCanvasSmall:getWidth() / 2,
		self.inventorySMTY + self.inventoryCanvasSmall:getHeight() / 2,
		{
			font = Fonts.soraRewardTotal,
			centered = true,
			amplitude = 5,
			speed = 2,
		}
	)

	--Shop Objects
	self.availableFaceObjects = {}
	self.availableCiggies = {}
	self.availableCoffees = {}
	self.availableStickers = {}
	--Shop Objects UI
	self.availableFaceObjectsUI = {}
	self.availableCiggieObjectsUI = {}
	self.availableCoffeesUI = {}
	self.stickersUI = {}
	self.facesPriceTags = {}
	self.ciggiesPriceTags = {}
	self.stickersPriceTags = {}

	--Inventory faces
	self.inventoryFacesUI = {}
	self.rewardsFacesUI = {}

	self.rerollShopPrice = self.run.baseShopRerollPrice

	--Wait for all the animations to end, then show the inventory and the shop + ciggies UI
	self.animator:addDelay(0.5, function()
		self:generateNewShop()
		self:createInventoryFaces()
		self:createRewardFaces()
		self:generateCiggiesUI()
	end)

	self.animator:addDelay(0.5, TutorialEvents.shop())

	--Booleen sachant si montrer le terrain quand un sticker est glissé depuis le shop
	self.terrainCanvas = love.graphics.newCanvas(930, 460)
	self.showTerrain = false

	self.terrainShowY, self.terrainHideY = -500, 30
	self.terrainX, self.terrainY = 505, -500
	return self
end

function Shop:update(dt)
	self.animator:update(dt)

	self.uiElements.buttons["rerollShopButton"].isActivated = self.rerollShopPrice <= self.run.money

	if love.timer.getTime() % 0.1 < dt then
		self.scoresChanged = true
	end

	self:getCurrentlyHoveredCiggie()
	self:getCurrentlyHoveredSticker()
	self:getCurrentlyHoveredFace()
	self:getCurrentlyHoveredCoffeeButton()
	self:getCurrentlyHoveredObject()

	--Detection de sticker glissé
	self.showTerrainPrev = self.showTerrain
	self.showTerrain = false

	for i, sticker in next, self.stickersUI do
		if sticker.isBeingDragged then
			self.showTerrain = true
			self.draggedSticker = sticker
		end
	end
	if self.draggedSticker then
		self:detectStickerPositionOnTerrain(self.draggedSticker)
	end
	--Si l'état de showterrain est différente entre deux frames, on vérifie si l'état est vrai ou faux et on affiche ou désactive le terrain

	if self.showTerrainPrev ~= self.showTerrain then
		if self.showTerrain then
			self:showTerrainAnim()
		else
			self:hideTerrain()
		end
	end

	self:updateCanvas(dt)
end

function Shop:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	--Check if a ciggie is being dragged to the screen
	self:checkForDraggedCiggie()
	self:drawRightPanel(dt)
	if self.showDeck == false then
		self:drawInventoryBackGroundSmall()
		self:drawShopBackground(dt)
		self:drawRewardsSmall()
		self:drawInventoryFaces(dt)
	end
	--UI
	--

	--Popup d'achat de face de dé
	if self.dragAndDroppedShopDice then
		love.graphics.draw(Sprites.BUY_POPUP, self.inventorySMTX, self.inventorySMTY, 0, 1, 1)
		self.buyText:update(dt)
		self.buyText:draw()
	else
		self.buyText:reset()
	end

	--Popup d'ajout de face de dé reward
	if self.dragAndDroppedReward then
		love.graphics.draw(Sprites.ADD_TO_INVENTORY, self.inventorySMTX, self.inventorySMTY, 0, 1, 1)
		self.addRewardText:update(dt)
		self.addRewardText:draw()
	else
		self.addRewardText:reset()
	end

	if self.showDeck == false then
		--Shop faces UI
		for i, faceUI in next, self.availableFaceObjectsUI do
			faceUI:update(dt)
			if faceUI ~= self.dragAndDroppedObject then
				faceUI:draw()
			end
		end

		--Coffee UI
		for i, coffee in next, self.availableCoffeesUI do
			coffee:update(dt)
		end

		--Shop Ciggie UI
		for i, ciggieUI in next, self.availableCiggieObjectsUI do
			ciggieUI:update(dt)
			if ciggieUI ~= self.dragAndDroppedObject then
				ciggieUI:draw()
			end
		end

		--Stickers
		for s, sticker in next, self.stickersUI do
			sticker:update(dt)
			sticker:draw()
		end

		self:drawPriceTags()
		self:drawHorizontalDice(dt)
	end

	--Upgrade hand popup
	if self.addingAvailableHand == true then
		self:drawUpgradingFigurePopup(dt)
	end

	self:drawFigureGrid()

	--Popup de vente de face de dé
	if self.dragAndDroppedReward or self.dragAndDroppedInventory then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(
			Sprites.SELL_CIGGIE,
			30,
			self.canvas:getHeight() - 30,
			0,
			1,
			1,
			0,
			Sprites.SELL_CIGGIE:getHeight()
		)
		self.sellText:update(dt)
		self.sellText:draw()
	else
		self.sellText:reset()
	end

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

	self:drawCiggiesTrayFront()

	--Buy Ciggie Popup
	if self.dragAndDroppedShopCiggie then
		local px, py = G.calculateParalaxeOffset(1)

		love.graphics.draw(Sprites.BUY_CIGGIE, 1670 + px, 590 + py, 0, 1, 1)

		love.graphics.draw(
			Sprites.USE_NOW,
			30 + px,
			self.canvas:getHeight() - 30 + py,
			0,
			1,
			1,
			0,
			Sprites.USE_NOW:getHeight()
		)
		-- love.graphics.draw(Sprites.USE_NOW, 30, 0, 1, 1, 0, Sprites.USE_NOW:getHeight())

		self.useCiggieText:update(dt)
		self.useCiggieText:draw()

		self.buyCiggieText:update(dt)
		self.buyCiggieText:draw()
	else
		self.buyCiggieText:reset()
		self.useCiggieText:reset()
	end

	--Dessine le terrain qui descend quand on DnD un sticker
	self:drawShopTerrain(dt)

	--Draw the drag and dropped object on top of everything else
	if self.dragAndDroppedObject then
		self.dragAndDroppedObject:draw()
	end

	if self.showDeck and self.deckScreen then
		self.deckScreen:update(dt)
		self.deckScreen:draw()
	end
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

	love.graphics.setCanvas(currentCanvas)
end

function Shop:draw()
	love.graphics.draw(self.canvas, 0, 0)
end

--==Update functions==--
function Shop:updateDiceNet(dt)
	local i = 1
	for k, df in next, self.infoFaces do
		df:setRepresentedFace(self.currentlySelectedDice.diceObject:getFace(i))
		df:updateSprite()
		df:update(dt)
		df:draw()
		i = i + 1
	end
end

--==Input functions==--
function Shop:mousepressed(x, y, button, istouch, presses)
	--Buttons
	for key, button in next, self.uiElements.buttons do
		if self.showDeck == false or (key ~= "rerollShopButton" and key ~= "nextRoundSmallBtn") then
			button:clickEvent()
		end
	end

	--Ciggies
	for key, ciggie in next, self.uiElements.ciggiesUI do
		ciggie:clickEvent()
	end
	if self.showDeck == false then
		--Deck faces
		for key, uiFace in next, self.deckFaces do
			uiFace:clickEvent()
		end

		--Inventory
		for key, uiFace in next, self.inventoryFacesUI do
			uiFace:clickEvent()
		end
		--Rewards
		for key, uiFace in next, self.rewardsFacesUI do
			uiFace:clickEvent()
		end

		--Coffe buttons
		for key, coffeeBtn in next, self.availableCoffeesUI do
			coffeeBtn:clickEvent()
		end

		--Shop elements
		--Faces
		for key, uiFace in next, self.availableFaceObjectsUI do
			uiFace:clickEvent()
		end

		--Ciggies
		for key, ciggie in next, self.availableCiggieObjectsUI do
			ciggie:clickEvent()
		end

		for key, sticker in next, self.stickersUI do
			sticker:clickEvent()
		end

		--Figure buttons
		self.clickedFigure = self:getCurrentlyHoveredLine()
	end
end

function Shop:mousereleased(x, y, button, istouch, presses)
	self.dragAndDroppedObject = nil
	self.draggedSticker = nil
	self.dragAndDroppedShopDice = nil
	self.dragAndDroppedReward = nil
	self.dragAndDroppedInventory = nil
	self.dragAndDroppedShopCiggie = nil

	--release event on UI elements (buttons)
	for key, button in next, self.uiElements.buttons do
		local wasReleased = button:releaseEvent()
		if wasReleased then --Si le click a été complété
			button:getCallback()()
		end
	end

	for key, button in next, self.availableCoffeesUI do
		local wasReleased = button:releaseEvent()
	end

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

	--Ciggies
	for key, ciggie in next, self.uiElements.ciggiesUI do
		local wasReleased = ciggie:releaseEvent()
		ciggie.isBeingDragged = false
		self:ciggieReleaseAction(ciggie)
	end

	--Inventory
	for key, face in next, self.inventoryFacesUI do
		local wasReleased = face:releaseEvent()
		face.isBeingDragged = false

		face.targetX = face.anchorX
		face.targetY = face.anchorY

		if (face.x > 0 and face.x < 500) and (face.y > 850 and face.y < self.canvas:getHeight()) then
			self:sellDiceFace(face.representedObject, face, key)
		end
	end
	--Rewards
	for key, face in next, self.rewardsFacesUI do
		local wasReleased = face:releaseEvent()
		face.isBeingDragged = false

		if
			(
				face.targetX > self.inventorySMTX
				and face.targetX < self.inventorySMTX + self.inventoryCanvasSmall:getWidth()
			)
			and (face.targetY > self.inventorySMTY and face.targetY < self.inventorySMTY + self.inventoryCanvasSmall:getHeight())
			and (table.getn(self.run.facesInventory) < 8)
		then
			self:addRewardToInventory(face, key)
		else
			face.targetX = face.anchorX
			face.targetY = face.anchorY
		end

		if (face.x > 0 and face.x < 500) and (face.y > 850 and face.y < self.canvas:getHeight()) then
			self:sellReward(face.representedObject, face, key)
		end
	end

	--Shop

	--Faces
	for key, face in next, self.availableFaceObjectsUI do
		local wasReleased = face:releaseEvent()
		face.isBeingDragged = false

		face.targetX = face.anchorX
		face.targetY = face.anchorY

		--On check que le dé est laché dans la zone d'inventaire pour l'acheter
		if
			face.x > self.inventorySMTX
			and face.x < self.inventorySMTX + self.inventoryCanvasSmall:getWidth()
			and face.y > self.inventorySMTY
			and face.y < self.inventorySMTY + self.inventoryCanvasSmall:getHeight()
		then
			if not self.run.tutorial or self.canBuyDiceFace == true then
				self:buyDiceFace(face.representedObject, face, key)
			end
		end
	end

	--Ciggies
	for key, ciggie in next, self.availableCiggieObjectsUI do
		local wasReleased = ciggie:releaseEvent()
		ciggie.isBeingDragged = false

		ciggie.targetX = ciggie.anchorX
		ciggie.targetY = ciggie.anchorY

		if
			ciggie.x > 1670
			and ciggie.y > 590
			and ciggie.x < 1670 + Sprites.BUY_CIGGIE:getWidth()
			and ciggie.y < 590 + Sprites.BUY_CIGGIE:getHeight()
		then
			if not self.run.tutorial or self.canBuyAnything == true then
				self:buyCiggie(ciggie.representedObject, ciggie, key)
			end
		end

		if
			ciggie.x > 30
			and ciggie.x < 30 + Sprites.USE_NOW:getWidth()
			and ciggie.y > self.canvas:getHeight() - 30 - Sprites.USE_NOW:getHeight()
			and ciggie.y < self.canvas:getHeight() - 30
		then
			if self.run.money >= Constants.BASE_CIGGIE_PRICE then
				ciggie.representedObject:triggerInShop(self, key)
				--Remove ciggie from availableCiggieObjetcsUI
				--Remove ciggie from list of shop ciggies
			end
		end
	end

	--Stickers
	for key, sticker in next, self.stickersUI do
		local wasReleased = sticker:releaseEvent()
		sticker.isBeingDragged = false

		if sticker.anchorX and sticker.anchorY then
			sticker.targetX = sticker.anchorX
			sticker.targetY = sticker.anchorY
		end

		if self:detectStickerPositionOnTerrain(sticker) then
			local stickerPos = self:detectStickerPositionOnTerrain(sticker)

			--Action d'acheter le sticker, et le placer sur le terrain
			if
				(sticker.representedObject.holographic == true and self.run.money >= Constants.BASE_HOLO_STICKER_PRICE)
				or (sticker.representedObject.holographic == false and self.run.money >= Constants.BASE_STICKER_PRICE)
			then
				if not self.tutorial and self.canBuySticker == true then
					self:buySticker(sticker)

					if sticker.representedObject.holographic == true then
						self:setMoneyTo(self.run.money - Constants.BASE_HOLO_STICKER_PRICE)
					else
						self:setMoneyTo(self.run.money - Constants.BASE_STICKER_PRICE)
					end

					if self.run.tutorial then
						self.animator:addDelay(0.2, function()
							TutorialEvents.shop3()
						end)
					end
				end
			end
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

function Shop:mousemoved(x, y, dx, dy, isDragging)
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

	--Inventory
	if isDragging == true then
		for key, face in next, self.inventoryFacesUI do
			if face.isDraggable and face.isBeingClicked then
				face.isBeingDragged = true
				self.dragAndDroppedObject = face
				self.dragAndDroppedInventory = face
				face.dragXspeed = dx
				face.targetX = (face.targetX + dx)
				face.targetY = (face.targetY + dy)
				break
			end
		end
	end

	--Rewards
	if isDragging == true then
		for key, face in next, self.rewardsFacesUI do
			if face.isDraggable and face.isBeingClicked then
				face.isBeingDragged = true
				self.dragAndDroppedObject = face
				self.dragAndDroppedReward = face
				face.dragXspeed = dx
				face.targetX = (face.targetX + dx)
				face.targetY = (face.targetY + dy)
				break
			end
		end
	end

	--Shop
	--Faces
	if isDragging == true then
		for key, face in next, self.availableFaceObjectsUI do
			if face.isDraggable and face.isBeingClicked then
				face.isBeingDragged = true
				self.dragAndDroppedShopDice = face
				self.dragAndDroppedObject = face
				face.dragXspeed = dx
				face.targetX = (face.targetX + dx)
				face.targetY = (face.targetY + dy)
				break
			end
		end
	end
	--Ciggie
	if isDragging == true then
		for key, ciggie in next, self.availableCiggieObjectsUI do
			if ciggie.isDraggable and ciggie.isBeingClicked then
				ciggie.isBeingDragged = true
				self.dragAndDroppedObject = ciggie
				self.dragAndDroppedShopCiggie = ciggie
				ciggie.dragXspeed = dx
				ciggie.targetX = x
				ciggie.targetY = y
				break
			end
		end
	end

	--Stickers
	if isDragging == true then
		for key, sticker in next, self.stickersUI do
			if sticker.isDraggable and sticker.isBeingClicked then
				sticker.isBeingDragged = true
				self.dragAndDroppedObject = sticker
				sticker.dragXspeed = dx
				sticker.targetX = x
				sticker.targetY = y
				break
			end
		end
	end
end

function Shop:keypressed(key) end

--==Shop Functions==--
function Shop:buyDiceFace(face, faceUI, key)
	if table.getn(self.run.facesInventory) < 8 and self.run.money >= 5 then
		--Remove the money
		self:setMoneyTo(self.run.money - 5)
		self.run.totalspent = self.run.totalspent + 5

		--Add face to inventory
		table.insert(self.run.facesInventory, face)

		--Remove faceUI from shop list
		table.remove(self.availableFaceObjectsUI, key)

		--Add FaceUI to inventory
		table.insert(self.inventoryFacesUI, faceUI)

		--Remove face from shop
		table.remove(self.availableFaceObjects, key)

		--Update the positions of the dices
		self:updateInventoryPositions()

		if self.run.tutorial then
			self.animator:addDelay(0.2, TutorialEvents.shop2())
		end
	end
end

function Shop:buyCiggie(ciggie, ciggieUI, key)
	if table.getn(self.run.ciggiesObjects) < self.run.maxCiggies and self.run.money >= Constants.BASE_CIGGIE_PRICE then
		self:setMoneyTo(self.run.money - Constants.BASE_CIGGIE_PRICE)
		self.run.totalspent = self.run.totalspent + Constants.BASE_CIGGIE_PRICE
		--Add the ciggie to the inventory
		table.insert(self.run.ciggiesObjects, ciggie)
		--Remove the ciggie from the shop
		table.remove(self.availableCiggies, key)
		--Remove the ciggie from the shop UI
		table.remove(self.availableCiggieObjectsUI, key)

		--Regenerate the ciggies inventory
		self:generateCiggiesUI()
	end
end

function Shop:sellDiceFace(face, faceUI, key)
	--Add money to bank account
	self:setMoneyTo(self.run.money + 3)
	self.run.totalspent = self.run.totalspent + 3
	--Remove dice face object from inventory

	table.remove(self.run.facesInventory, key)
	local apparitionDuration = 0.3

	--Remove dice face from ui with animation
	faceUI.animator:addGroup({
		--Rotation
		{
			property = "rotation",
			from = 0,
			targetValue = -2,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		{
			property = "baseRotation",
			from = 0,
			targetValue = -2,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		--Scale
		{
			property = "baseTargetedScale",
			from = 1,
			targetValue = 0,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		{
			property = "scaleX",
			from = 1,
			targetValue = 0,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		{
			property = "scaleY",
			from = 1,
			targetValue = 0,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		{
			property = "targetedScale",
			from = 1,
			targetValue = 0,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
			onComplete = function()
				table.remove(self.inventoryFacesUI, key)
				self:updateInventoryPositions()
			end,
		},
	})
end

function Shop:sellReward(face, faceUI, key)
	--Add money to bank account
	self:setMoneyTo(self.run.money + 3)

	--Remove dice face object from inventory

	table.remove(self.run.facesRewardsInventory, key)
	local apparitionDuration = 0.3

	--Remove dice face from ui with animation
	faceUI.animator:addGroup({
		--Rotation
		{
			property = "rotation",
			from = 0,
			targetValue = -2,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		{
			property = "baseRotation",
			from = 0,
			targetValue = -2,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		--Scale
		{
			property = "baseTargetedScale",
			from = 1,
			targetValue = 0,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		{
			property = "scaleX",
			from = 1,
			targetValue = 0,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		{
			property = "scaleY",
			from = 1,
			targetValue = 0,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
		},
		{
			property = "targetedScale",
			from = 1,
			targetValue = 0,
			duration = apparitionDuration,
			easing = AnimationUtils.Easing.easeOutBack,
			onComplete = function()
				table.remove(self.rewardsFacesUI, key)
				self:updateRewardsPositions()
			end,
		},
	})
end

function Shop:rerollShop()
	if not self.run.tutorial or self.canRerollShop == true then
		if self.run.money >= self.rerollShopPrice then
			G.animator:finishAll()
			G.animator:add("waveY", -6, 0, 1.0, AnimationUtils.Easing.outQuad)
			self.run.money = self.run.money - self.rerollShopPrice
			self.run.totalspent = self.run.totalspent + self.rerollShopPrice
			self:generateNewShop()
			self.rerollShopPrice = self.rerollShopPrice + Constants.BASE_SHOP_REROLL_PRINCE_INCREMENT
		end
	end
end

--==Shop generation==--
function Shop:generateNewShop()
	-- Cleanup previous objects before generating new ones
	for _, face in ipairs(self.availableFaceObjects or {}) do
		face = nil -- Allow for garbage collection
	end
	for _, sticker in ipairs(self.availableStickers or {}) do
		sticker = nil -- Allow for garbage collection
	end
	for _, ciggie in ipairs(self.availableCiggies or {}) do
		ciggie = nil -- Allow for garbage collection
	end

	--Generate the objects to buy
	self:generateAvailableFaces()
	self:generateAvailableCiggies()

	if self.firstShopGeneration == true then
		self:generateRandomStickers()
	end

	-- Clear previous UI lists completely
	for k in pairs(self.availableFaceObjectsUI or {}) do
		self.availableFaceObjectsUI[k] = nil
	end
	for k in pairs(self.availableCiggieObjectsUI or {}) do
		self.availableCiggieObjectsUI[k] = nil
	end

	--Generate the UI elements--
	-- Cleanup previous face UI objects
	for k = #self.availableFaceObjectsUI, 1, -1 do
		local faceUI = self.availableFaceObjectsUI[k]
		-- Explicitly nil out properties to help garbage collection
		if faceUI then
			if faceUI.animator then
				faceUI.animator:clear() -- Clear any running animations
				faceUI.animator = nil
			end
			faceUI.representedObject = nil
			faceUI.diceObject = nil
			faceUI.sprite = nil
			self.availableFaceObjectsUI[k] = nil
		end
	end
	self.availableFaceObjectsUI = {}

	--Faces
	for i, f in next, self.availableFaceObjects do
		local xs = { 570, 720, 570, 720 }
		local ys = { 120, 120, 300, 300 }

		local faceUI = DiceFace:new(nil, f, xs[i] + 60, ys[i] + 60, 120, false, true, function()
			return Inputs.getMouseInCanvas(0, 0, 3)
		end, nil)
		--Add them an anchor
		faceUI.anchorX = xs[i] + 60
		faceUI.anchorY = ys[i] + 60
		faceUI.layer = 3

		--Add an animation for their apparition
		local apparitionDuration = 0.3
		faceUI.animator:addGroup({
			--Rotation
			{
				property = "rotation",
				from = 3,
				targetValue = 0,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "baseRotation",
				from = 3,
				targetValue = 0,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			--Scale
			{
				property = "baseTargetedScale",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "scaleX",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "scaleY",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})

		table.insert(self.availableFaceObjectsUI, faceUI)
	end

	-- Cleanup previous ciggie UI objects
	for k = #self.availableCiggieObjectsUI, 1, -1 do
		local ciggieUI = self.availableCiggieObjectsUI[k]
		-- Explicitly nil out properties to help garbage collection
		if ciggieUI then
			if ciggieUI.animator then
				ciggieUI.animator:clear() -- Clear any running animations
				ciggieUI.animator = nil
			end
			ciggieUI.representedObject = nil
			ciggieUI.sprite = nil
			self.availableCiggieObjectsUI[k] = nil
		end
	end
	self.availableCiggieObjectsUI = {}

	--Ciggies
	--Create the UI
	for i, c in next, self.availableCiggies do
		local xs = { 890, 970 }
		local ys = { 140, 140 }

		local x = xs[i] + 25
		local y = ys[i] + 150

		local ciggieUI = Ciggie:new(c, x, y, false, true, function()
			return Inputs.getMouseInCanvas(0, 0, 3)
		end, nil)
		--Set an anchor
		ciggieUI.anchorX = x
		ciggieUI.anchorY = y
		--Insert in the table
		ciggieUI.layer = 3
		table.insert(self.availableCiggieObjectsUI, ciggieUI)

		--Add them an animation
		local apparitionDuration = 0.3
		ciggieUI.animator:addGroup({
			--Rotation
			--Scale
			{
				property = "baseTargetedScale",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "scaleX",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "scaleY",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})
	end

	--Coffee
	local maxPlayed = 0
	local maxPlayedCount = 0

	if self.firstShopGeneration == true then
		--Variable de la figure la plus jouée. On la met à 0, comme ca dans l'éventualité ou toutes les figures sont à 0, on peut skip le sticker MorningBrew
		for figure, info in pairs(self.run.figuresInfos) do
			print(figure, info.playcount)
			if info.playcount > maxPlayedCount then
				maxPlayed = figure
				maxPlayedCount = info.playcount
			end
		end
	end

	local randomFigures = GenerateRandom.generateUniqueNumbersShop(1, 13, 4)

	--SI on est dans la premiere generation, que la figure la plus jouée n'est pas 0 et qu'on a le morning brew sticker,
	--On remplace le premier numéro généré par le numéro de la figure la plus jouée.
	if self.run.morningBrewSticker == true and self.firstShopGeneration and maxPlayed > 0 then
		randomFigures[1] = maxPlayed
	end

	self.availableCoffeesUI = {}

	for i = 1, 3 do
		self:generateRandomCoffee(i, randomFigures[i])
	end

	--Stickers
	if self.firstShopGeneration == true then
		self:generateStickersUI()
	end
	--Generate the price tags
	self:createFacesPriceTags()
	self.firstShopGeneration = false
end

function Shop:generateAvailableFaces()
	-- Cleanup previous faces before generating new ones
	for k = #self.availableFaceObjects, 1, -1 do
		self.availableFaceObjects[k] = nil
	end

	--On créée une liste des clés de facetype à retirer de la génération
	local forbiddenFaces = {}
	table.insert(forbiddenFaces, "WhiteDice")

	for i, name in pairs(G.faceNames) do
		--Maintenant on parcoure l'inventaire
		for k, d in next, self.run.facesInventory do
			if d.name == name then
				table.insert(forbiddenFaces, i)
			end
		end
	end

	self.availableFaceObjects = {}
	for i = 1, 4 do
		local f = GenerateRandom.faceObjectShop(forbiddenFaces)
		table.insert(self.availableFaceObjects, f)
	end
end

function Shop:generateAvailableCiggies()
	-- Cleanup previous ciggies before generating new ones
	for k = #self.availableCiggies, 1, -1 do
		self.availableCiggies[k] = nil
	end

	--On créée une liste des clés de ciggies à retirer de la génération
	local forbiddenCiggies = {}
	for key, _ in pairs(CiggieTypes) do
		--Maintenant on parcoure l'inventaire
		local dummyCiggie = CiggieTypes[key]:new()

		for k, c in next, self.run.ciggiesObjects do
			if c.name == dummyCiggie.name then
				table.insert(forbiddenCiggies, key)
			end
		end
	end

	self.availableCiggies = {}
	for i = 1, 2 do
		local c = self:generateRandomCiggie(forbiddenCiggies)
		table.insert(self.availableCiggies, c)
	end
end

--Coffee
function Shop:generateRandomCoffee(i, randomFigureIndex)
	local x = 550 + 350 / 2
	local y = 20 + 100 + (i - 1) * 80

	--Creation du bouton
	local coffeeButton = CoffeeButton:new(x, y, function()
		return Inputs.getMouseInCanvas(self.shopBGX, self.shopBGY, 3)
	end, randomFigureIndex, self.run)

	coffeeButton.absoluteX, coffeeButton.absoluteY = self.shopBGX, self.shopBGY
	coffeeButton.layer = 4

	table.insert(self.availableCoffeesUI, coffeeButton)
end

function Shop:generateRandomStickers()
	local function popRandom(list)
		if #list == 0 then
			return nil
		end
		local index = G.rngShop:random(#list)
		return table.remove(list, index)
	end

	self.availableStickers = {}

	-- ===== Stickers normaux =====
	local possibleStickers = {}
	for key, sticker in next, G.basicStickers do
		local isInInventory = false

		for _, playerSticker in next, self.run.stickers do
			if playerSticker.name == sticker.name then
				isInInventory = true
				break
			end
		end

		if sticker:unlockCondition(self.run) and not isInInventory then
			table.insert(possibleStickers, key)
		end
	end
	possibleSticker = GenerateRandom.sorted(possibleStickers)

	-- ===== Stickers holo =====
	local possibleStickersHolo = {}
	for key, sticker in next, G.holoStickers do
		local isInInventory = false

		for _, playerSticker in next, self.run.stickers do
			if playerSticker.name == sticker.name then
				isInInventory = true
				break
			end
		end

		if sticker:unlockCondition(self.run) and not isInInventory then
			table.insert(possibleStickersHolo, key)
		end
	end
	possibleStickersHolo = GenerateRandom.sorted(possibleStickersHolo)

	-- ===== 1) Jusqu’à 3 stickers normaux =====
	for i = 1, 3 do
		local key = popRandom(possibleStickers)
		if not key then
			break
		end
		table.insert(self.availableStickers, self:generateRandomSticker({ key }))
	end

	-- ===== 2) Sticker holo si possible =====
	local holoKey = popRandom(possibleStickersHolo)
	if holoKey then
		table.insert(self.availableStickers, self:generateRandomSticker({ holoKey }))
	else
		-- ===== 3) Sinon un 4e normal =====
		local key = popRandom(possibleStickers)
		if key then
			table.insert(self.availableStickers, self:generateRandomSticker({ key }))
		end
	end
end

function Shop:generateStickersUI()
	self.stickersUI = {}

	local xs = { 555, 725, 895, 1065 }
	local y = 535

	for i, sticker in next, self.availableStickers do
		local s = Sticker:new(sticker, xs[i] + (110 / 2), y + (110 / 2), 110, true, true, function()
			return Inputs.getMouseInCanvas(0, 0)
		end, 0, 0)
		s.layer = 3
		self.stickersUI[sticker] = s
	end
end

--==UTILS==--
function Shop:getCurrentlyHoveredFace()
	self.currentlyHoveredFace = nil

	if self.showDeck and self.deckScreen then
		self.currentlyHoveredFace = self.deckScreen:getCurrentlyHoveredFace()
		return
	end

	--Dice Net
	--Deck sur le coté droit
	if self.horizontalDiceNet then
		for i, df in next, self.horizontalDiceFaces do
			if df:isHovered() then
				self.currentlyHoveredFace = df
				return
			end
		end
	end

	--Shop faces
	for i, face in next, self.availableFaceObjectsUI do
		if face:isHovered() then
			self.currentlyHoveredFace = face
			return
		end
	end
	--Inventory Faces
	for i, face in next, self.inventoryFacesUI do
		if face:isHovered() then
			self.currentlyHoveredFace = face
			return
		end
	end
	--Rewards
	for i, face in next, self.rewardsFacesUI do
		if face:isHovered() then
			self.currentlyHoveredFace = face
			return
		end
	end
end

function Shop:getCurrentlyHoveredSticker()
	self.currentlyHoveredSticker = nil
	for key, sticker in next, self.stickersUI do
		if sticker:isHovered() then
			self.currentlyHoveredSticker = sticker
			break
		end
	end
end

function Shop:getCurrentlyHoveredCoffeeButton()
	self.currentlyHoveredCoffeeButton = nil
	for i, btn in next, self.availableCoffeesUI do
		if btn:isHovered() then
			self.currentlyHoveredCoffeeButton = btn
			break
		end
	end
end

function Shop:getCurrentlyHoveredObject()
	if self.currentlyHoveredFace then
		self.currentlyHoveredObject = self.currentlyHoveredFace
	elseif self.currentlyHoveredCiggie then
		self.currentlyHoveredObject = self.currentlyHoveredCiggie
	elseif self.currentlyHoveredCoffeeButton then
		self.currentlyHoveredObject = self.currentlyHoveredCoffeeButton
	elseif self.currentlyHoveredSticker then
		self.currentlyHoveredObject = self.currentlyHoveredSticker
	else
		self.currentlyHoveredObject = nil
	end
end

function Shop:resetSelectedDices()
	--Dice faces
	for key, face in next, self.deckFaces do
		face:setSelected(false)
	end
end

function Shop:getRandomFaceObject(forbiddenKeys)
	--Get the list of keys
	local keys = {}
	for key, _ in pairs(FaceTypes) do
		local isForbidden = false
		for i, fk in next, forbiddenKeys do
			if fk == key then
				isForbidden = true
			end
		end

		if isForbidden == false then
			table.insert(keys, key)
		end
	end

	local randomFaceKey = keys[G.rngShop:random(#keys)]
	local randomFaceType = FaceTypes[randomFaceKey] --On récupère une face type au hasard
	local randomFaceValue = G.rngShop:random(1, 6) --La face numérique

	local randomFaceObject = randomFaceType:new(randomFaceValue, 10)

	return randomFaceObject
end

function Shop:generateRandomSticker(possibleStickers)
	if #possibleStickers == 0 then
		return nil
	end

	local randomKey = possibleStickers[G.rngShop:random(#possibleStickers)]

	return StickerTypes[randomKey]:new()
end

function Shop:generateRandomCiggie(forbiddenKeys)
	--Get the list of keys
	local keys = {}
	for key, _ in pairs(CiggieTypes) do
		local isForbidden = false
		for i, fk in next, forbiddenKeys do
			if fk == key then
				isForbidden = true
			end
		end

		if isForbidden == false then
			table.insert(keys, key)
		end
	end

	keys = GenerateRandom.sorted(keys)

	local randomCiggieKey = keys[G.rngShop:random(#keys)]
	local randomCiggieType = CiggieTypes[randomCiggieKey] --On récupère une face type au hasard

	local randomCiggieObject = randomCiggieType:new()

	return randomCiggieObject
end

--==Additionnal init functions==--
function Shop:createDeck()
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

function Shop:createInventoryFaces()
	local xPos = { 20, 150, 280, 410, 20, 150, 280, 410 }
	local yPos = { 81, 81, 81, 81, 220, 220, 220, 220 }

	for i, face in next, self.run.facesInventory do
		--Create the UIFaces

		local faceUI = DiceFace:new(
			nil,
			face,
			xPos[i] + 60 + self.inventorySMTX,
			yPos[i] + self.inventorySMTY + 60,
			120,
			false,
			true,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end,
			nil
		)

		faceUI.anchorX = xPos[i] + 60 + self.inventorySMTX
		faceUI.anchorY = yPos[i] + self.inventorySMTY + 60
		faceUI.layer = 3

		local apparitionDuration = 0.3
		faceUI.animator:addGroup({
			--Rotation
			{
				property = "rotation",
				from = 3,
				targetValue = 0,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "baseRotation",
				from = 3,
				targetValue = 0,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			--Scale
			{
				property = "baseTargetedScale",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "scaleX",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "scaleY",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})

		table.insert(self.inventoryFacesUI, faceUI)
	end
end

function Shop:createRewardFaces()
	local xPos = { 40, 40 }
	local yPos = { 70, 200 }

	for i, face in next, self.run.facesRewardsInventory do
		--Create the UIFaces

		local faceUI = DiceFace:new(
			nil,
			face,
			xPos[i] + 60 + self.rewardsSMTX,
			yPos[i] + self.rewardsSMTY + 60,
			120,
			false,
			true,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end,
			nil
		)

		faceUI.anchorX = xPos[i] + 60 + self.rewardsSMTX
		faceUI.anchorY = yPos[i] + self.rewardsSMTY + 60
		faceUI.layer = 3

		local apparitionDuration = 0.3
		faceUI.animator:addGroup({
			--Rotation
			{
				property = "rotation",
				from = 3,
				targetValue = 0,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "baseRotation",
				from = 3,
				targetValue = 0,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			--Scale
			{
				property = "baseTargetedScale",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "scaleX",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "scaleY",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = 0,
				targetValue = 1,
				duration = apparitionDuration,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})

		table.insert(self.rewardsFacesUI, faceUI)
	end
end

function Shop:createFacesPriceTags()
	-- Release previous canvases to free GPU memory
	for _, canvas in pairs(self.facesPriceTags or {}) do
		canvas:release()
	end
	for _, canvas in pairs(self.ciggiesPriceTags or {}) do
		canvas:release()
	end
	for _, canvas in pairs(self.stickersPriceTags or {}) do
		canvas:release()
	end

	self.facesPriceTags = {}
	self.faceTextObjects = {}
	--Faces
	for i = 1, 4 do
		local c = love.graphics.newCanvas(70, 30)
		love.graphics.setBlendMode("alpha")
		local priceText = love.graphics.newText(Fonts.soraPrice, "5€")
		table.insert(self.facesPriceTags, c)
		table.insert(self.faceTextObjects, priceText)
	end

	--Ciggies
	self.ciggiesPriceTags = {}
	for i = 1, 2 do
		local c = love.graphics.newCanvas(70, 30)
		love.graphics.setBlendMode("alpha")
		local priceText = love.graphics.newText(Fonts.soraPrice, tostring(Constants.BASE_CIGGIE_PRICE) .. "€")
		table.insert(self.ciggiesPriceTags, c)
		table.insert(self.faceTextObjects, priceText)
	end

	--Stickers
	self.stickersPriceTags = {}
	for i = 1, #self.availableStickers do
		local c = love.graphics.newCanvas(70, 30)
		love.graphics.setBlendMode("alpha")
		local priceText = love.graphics.newText(Fonts.soraPrice, tostring(Constants.BASE_STICKER_PRICE) .. "€")
		if self.availableStickers[i].holographic == true then
			priceText = love.graphics.newText(Fonts.soraPrice, tostring(Constants.BASE_HOLO_STICKER_PRICE) .. "€")
		end
		table.insert(self.stickersPriceTags, c)
		table.insert(self.faceTextObjects, priceText)
	end
end

function Shop:drawInventoryFaces(dt)
	for k, uiFace in next, self.inventoryFacesUI do
		uiFace:update(dt)
		if uiFace ~= self.dragAndDroppedObject then
			uiFace:draw()
		end
	end

	for k, uiFace in next, self.rewardsFacesUI do
		uiFace:update(dt)
		if uiFace ~= self.dragAndDroppedObject then
			uiFace:draw()
		end
	end
end

function Shop:updateInventoryPositions()
	local xPos = { 60, 210, 360, 510, 60, 210, 360, 510 }
	local yPos = { 70, 70, 70, 70, 200, 200, 200, 200 }

	for i, uiFace in next, self.inventoryFacesUI do
		uiFace.anchorX = xPos[i] + 60 + self.inventorySMTX
		uiFace.anchorY = yPos[i] + self.inventorySMTY + 60
		uiFace.targetX = xPos[i] + 60 + self.inventorySMTX
		uiFace.targetY = yPos[i] + self.inventorySMTY + 60
	end
end

function Shop:updateRewardsPositions()
	local xPos = { 40, 40 }
	local yPos = { 70, 200 }

	for i, uiFace in next, self.rewardsFacesUI do
		uiFace.anchorX = xPos[i] + 60 + self.rewardsSMTX
		uiFace.anchorY = yPos[i] + self.rewardsSMTY + 60
		uiFace.targetX = xPos[i] + 60 + self.rewardsSMTX
		uiFace.targetY = yPos[i] + self.rewardsSMTY + 60
	end
end

function Shop:drawPriceTags()
	local currentCanvas = love.graphics.getCanvas()
	local px, py = G.calculateParalaxeOffset(2)
	local xs = { 570, 720, 570, 720 }
	local ys = { 120, 120, 300, 300 }

	for i, c in next, self.facesPriceTags do
		love.graphics.setCanvas(c)
		love.graphics.clear()
		--Background
		love.graphics.draw(Sprites.PRICE_TAG, 0, 0)
		--Text
		local priceText = self.faceTextObjects[i]

		love.graphics.setColor(232 / 255, 79 / 255, 79 / 255, 1)
		love.graphics.draw(
			priceText,
			c:getWidth() / 2,
			c:getHeight() / 2,
			0,
			1,
			1,
			priceText:getWidth() / 2,
			priceText:getHeight() / 2
		)
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.setCanvas(currentCanvas)

		love.graphics.draw(
			c,
			xs[i] + px + 60,
			ys[i] + py + 130,
			0,
			self.priceTagsScale,
			self.priceTagsScale,
			c:getWidth() / 2,
			0
		)
	end

	--Ciggies
	for i, c in next, self.ciggiesPriceTags do
		love.graphics.setCanvas(c)
		love.graphics.clear()
		--Background
		love.graphics.draw(Sprites.PRICE_TAG, 0, 0)
		--Text
		local priceText = self.faceTextObjects[#self.facesPriceTags + i]

		love.graphics.setColor(232 / 255, 79 / 255, 79 / 255, 1)
		love.graphics.draw(
			priceText,
			c:getWidth() / 2,
			c:getHeight() / 2,
			0,
			1,
			1,
			priceText:getWidth() / 2,
			priceText:getHeight() / 2
		)
		love.graphics.setColor(1, 1, 1, 1)
		local xs = { 915, 995 }
		local ys = { 120 + 310, 120 + 310 }

		love.graphics.setCanvas(currentCanvas)
		love.graphics.draw(c, xs[i] + px, ys[i] + py, 0, self.priceTagsScale, self.priceTagsScale, c:getWidth() / 2, 0)
	end

	--Stickers
	for i, c in next, self.stickersPriceTags do
		love.graphics.setCanvas(c)
		love.graphics.clear()
		--Background
		love.graphics.draw(Sprites.PRICE_TAG, 0, 0)
		--Text
		local priceText = self.faceTextObjects[#self.facesPriceTags + #self.ciggiesPriceTags + i]

		love.graphics.setColor(232 / 255, 79 / 255, 79 / 255, 1)
		love.graphics.draw(
			priceText,
			c:getWidth() / 2,
			c:getHeight() / 2,
			0,
			1,
			1,
			priceText:getWidth() / 2,
			priceText:getHeight() / 2
		)
		love.graphics.setColor(1, 1, 1, 1)
		local xs = 610 + 170 * (i - 1)
		local ys = 635

		love.graphics.setCanvas(currentCanvas)
		love.graphics.draw(c, xs + px, ys + py, 0, self.priceTagsScale, self.priceTagsScale, c:getWidth() / 2, 0)
	end
end

function Shop:addRewardToInventory(face, key)
	--Supprimer la face de la liste des rewards
	table.remove(self.run.facesRewardsInventory, key)
	--Ajouter la face à l'inventaire de jeu
	table.insert(self.run.facesInventory, face.representedObject)
	--Supprimer la face UI des rewards
	table.remove(self.rewardsFacesUI, key)
	--Ajouter la face UI à l'inventaire
	table.insert(self.inventoryFacesUI, face)
	--Réorganiser les rewards
	self:updateRewardsPositions()

	--Réorganiser l'inventaire
	self:updateInventoryPositions()
end

--==Hover functions==--
function Shop:getCurrentlyHoveredCiggie()
	self.currentlyHoveredCiggie = nil
	--Inventaire
	for i, ciggie in next, self.uiElements.ciggiesUI do
		if ciggie:isHovered() then
			self.currentlyHoveredCiggie = ciggie
			break
		end
	end
	--Shop
	for i, ciggie in next, self.availableCiggieObjectsUI do
		if ciggie:isHovered() then
			self.currentlyHoveredCiggie = ciggie
			break
		end
	end
end
--Animations
function Shop:drawShopTerrain(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.terrainCanvas)
	love.graphics.clear()

	--Dessine le background
	love.graphics.draw(Sprites.DICE_MAT, 0, self.terrainCanvas:getHeight(), 0, 1, 1, 0, Sprites.DICE_MAT:getHeight())

	--Dessine les stickers déjà placés
	for i, sticker in next, self.run.uiStickers do
		sticker:update(dt)
		sticker:draw()
	end

	love.graphics.setCanvas(currentCanvas)
	love.graphics.draw(self.terrainCanvas, self.terrainX, self.terrainY)
end

function Shop:showTerrainAnim()
	self.animator:add("terrainY", -500, 30, 0.2, AnimationUtils.Easing.outQuad)
end

function Shop:hideTerrain()
	self.animator:add("terrainY", 30, -500, 0.2, AnimationUtils.Easing.inQuad)
end

function Shop:detectStickerPositionOnTerrain(sticker)
	if
		sticker.x > self.terrainX
		and sticker.x < self.terrainX + self.terrainCanvas:getWidth()
		and sticker.y > self.terrainY
		and sticker.y < self.terrainY + self.terrainCanvas:getHeight()
	then
		return { x = math.floor(sticker.x - self.terrainX), y = math.floor(sticker.y - self.terrainY) }
	else
		return nil
	end
end

function Shop:buySticker(sticker)
	--On ajout le stickerObject à la liste des stickerObject de la run
	table.insert(self.run.stickers, sticker.representedObject)
	--On ajoute le sticker UI à la liste de la run
	local pos = self:detectStickerPositionOnTerrain(sticker)
	local s = Sticker:new(sticker.representedObject, pos.x, pos.y, 110, false, true, function()
		return Inputs.getMouseInCanvas(510, 490)
	end, 510, 490)

	s.isTerrainSticker = true --Permet de dire qu'il s'agit d'un sticker affiché sur le terrain, et non dans le shop

	table.insert(self.run.uiStickers, s)

	--On active l'effet d'achat du sticker
	sticker.representedObject:buyEffect(self.run)

	--On supprime le sticker du shop (ui)
	self.stickersUI[sticker.representedObject] = nil
end

function Shop:outAnimation()
	local outDuration = 0.4

	if self.run.tutorial and self.canGoToNextRound == false then
		return
	end

	--Out animation for inventory faces
	for i = #self.inventoryFacesUI, 1, -1 do
		local face = self.inventoryFacesUI[i]
		face.animator:addGroup({
			{ property = "scaleX", from = face.scaleX, targetValue = 0, duration = outDuration / 2 },
			{ property = "scaleY", from = face.scaleY, targetValue = 0, duration = outDuration / 2 },
			{
				property = "baseTargetedScale",
				from = face.baseTargetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = face.targetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},

			--Rotation
			{
				property = "rotation",
				from = 0,
				targetValue = -1,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "baseRotation",
				from = 0,
				targetValue = -1,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})
	end

	--Out animation for reward faces
	for i, face in next, self.rewardsFacesUI do
		face.animator:addGroup({
			{ property = "scaleX", from = face.scaleX, targetValue = 0, duration = outDuration / 2 },
			{ property = "scaleY", from = face.scaleY, targetValue = 0, duration = outDuration / 2 },
			{
				property = "baseTargetedScale",
				from = face.baseTargetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = face.targetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},

			--Rotation
			{
				property = "rotation",
				from = 0,
				targetValue = -1,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "baseRotation",
				from = 0,
				targetValue = -1,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})
	end

	--Out animation of shop faces
	for i, face in next, self.availableFaceObjectsUI do
		face.animator:addGroup({
			{ property = "scaleX", from = face.scaleX, targetValue = 0, duration = outDuration / 2 },
			{ property = "scaleY", from = face.scaleY, targetValue = 0, duration = outDuration / 2 },
			{
				property = "baseTargetedScale",
				from = face.baseTargetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = face.targetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},

			--Rotation
			{
				property = "rotation",
				from = 0,
				targetValue = -1,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "baseRotation",
				from = 0,
				targetValue = -1,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})
	end

	for i, sticker in next, self.stickersUI do
		sticker.animator:addGroup({
			{ property = "scaleX", from = sticker.scaleX, targetValue = 0, duration = outDuration / 2 },
			{ property = "scaleY", from = sticker.scaleY, targetValue = 0, duration = outDuration / 2 },
			{
				property = "baseTargetedScale",
				from = sticker.baseTargetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = sticker.targetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},

			--Rotation
			{
				property = "rotation",
				from = 0,
				targetValue = -1,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "baseRotation",
				from = 0,
				targetValue = -1,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})
	end

	--Out animation for ciggies
	for i, face in next, self.availableCiggieObjectsUI do
		face.animator:addGroup({
			{ property = "scaleX", from = face.scaleX, targetValue = 0, duration = outDuration / 2 },
			{ property = "scaleY", from = face.scaleY, targetValue = 0, duration = outDuration / 2 },
			{
				property = "baseTargetedScale",
				from = face.baseTargetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
			{
				property = "targetedScale",
				from = face.targetedScale,
				targetValue = 0,
				duration = outDuration / 2,
				easing = AnimationUtils.Easing.easeOutBack,
			},
		})
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

	self.animator:add("priceTagsScale", 1, 0, outDuration / 4, AnimationUtils.Easing.easeOutBack)
	self.animator:addDelay(outDuration / 2)

	--Remove the elements from the UI
	self.animator:addGroup({
		{
			property = "gridX",
			from = self.gridX,
			targetValue = 0 - self.figureButtonsCanvas:getWidth() - 40,
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

		{
			property = "shopBGY",
			from = self.shopBGY,
			targetValue = -1000,
			duration = outDuration,
			easing = AnimationUtils.Easing.inCubic,
		},

		{
			property = "inventorySMY",
			from = self.inventorySMY,
			targetValue = self.canvas:getHeight() + 600,
			duration = outDuration,
			easing = AnimationUtils.Easing.inOutCubic,
		},
		{
			property = "rewardsSMY",
			from = self.rewardsSMY,
			targetValue = self.canvas:getHeight() + 600,
			duration = outDuration,
			easing = AnimationUtils.Easing.inOutCubic,
		},
		{
			property = "rightPanelX",
			from = self.rightPanelX,
			targetValue = self.canvas:getWidth() + 550,
			duration = outDuration,
			easing = AnimationUtils.Easing.inOutCubic,
		},
	})
	self.animator:addDelay(0.5, function()
		self.run:goToDiceCustomization()
	end)

	--Buttons animation
end

function Shop:isInList(diceList, targetDice)
	--Fonction pour vérifier qu'un élément est dans une liste
	for _, dice in ipairs(diceList) do
		if dice == targetDice then
			return true
		end
	end
	return false
end

function Shop:getCurrentlyHoveredLine()
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

function Shop:cleanup()
	-- Release canvases to free GPU memory
	for _, canvas in pairs(self.facesPriceTags or {}) do
		canvas:release()
	end
	for _, canvas in pairs(self.ciggiesPriceTags or {}) do
		canvas:release()
	end

	-- Clear text objects
	if self.faceTextObjects then
		for i = 1, #self.faceTextObjects do
			self.faceTextObjects[i] = nil
		end
		self.faceTextObjects = {}
	end

	-- Clear UI faces with proper cleanup
	if self.availableFaceObjectsUI then
		for _, face in pairs(self.availableFaceObjectsUI) do
			if face and face.animator then
				face.animator:clear()
				face.animator = nil
			end
			if face then
				face.representedObject = nil
				face.diceObject = nil
				face.sprite = nil
			end
		end
		self.availableFaceObjectsUI = {}
	end

	if self.inventoryFacesUI then
		for _, face in pairs(self.inventoryFacesUI) do
			if face and face.animator then
				face.animator:clear()
				face.animator = nil
			end
			if face then
				face.representedObject = nil
				face.diceObject = nil
				face.sprite = nil
			end
		end
		self.inventoryFacesUI = {}
	end

	if self.rewardsFacesUI then
		for _, face in pairs(self.rewardsFacesUI) do
			if face and face.animator then
				face.animator:clear()
				face.animator = nil
			end
			if face then
				face.representedObject = nil
				face.diceObject = nil
				face.sprite = nil
			end
		end
		self.rewardsFacesUI = {}
	end

	-- Clear available objects
	if self.availableFaceObjects then
		for i = #self.availableFaceObjects, 1, -1 do
			self.availableFaceObjects[i] = nil
		end
		self.availableFaceObjects = {}
	end

	if self.availableCiggies then
		for i = #self.availableCiggies, 1, -1 do
			self.availableCiggies[i] = nil
		end
		self.availableCiggies = {}
	end

	-- Clear UI elements
	if self.uiElements and self.uiElements.buttons then
		for _, button in pairs(self.uiElements.buttons) do
			if button and button.animator then
				button.animator:clear()
				button.animator = nil
			end
		end
		self.uiElements.buttons = {}
	end

	-- Clear ciggies UI
	if self.uiElements and self.uiElements.ciggiesUI then
		for _, ciggie in pairs(self.uiElements.ciggiesUI) do
			if ciggie and ciggie.animator then
				ciggie.animator:clear()
				ciggie.animator = nil
			end
			if ciggie then
				ciggie.representedObject = nil
				ciggie.sprite = nil
			end
		end
		self.uiElements.ciggiesUI = {}
	end

	-- Clear additional objects
	self.dragAndDroppedObject = nil
	self.dragAndDroppedShopDice = nil
	self.dragAndDroppedReward = nil
	self.dragAndDroppedInventory = nil
	self.dragAndDroppedShopCiggie = nil
	self.currentlyHoveredFace = nil
	self.currentlyHoveredCiggie = nil
	self.currentlyHoveredCoffeeButton = nil

	-- Clear canvas references
	self.facesPriceTags = {}
	self.ciggiesPriceTags = {}
end

return Shop
