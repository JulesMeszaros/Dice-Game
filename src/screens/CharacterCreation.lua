local UI = require("src.utils.scripts.UI")
local MainMenu = require("src.screens.MainMenu")
local Animator = require("src.utils.Animator")
local Fonts = require("src.utils.Fonts")
local Inputs = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local Sprites = require("src.utils.Sprites")
local TextInput = require("src.classes.ui.TextInput")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")
local Button = require("src.classes.ui.Button")
local Lion = require("src.classes.ui.Lion")

local CharacterCreation = {}

CharacterCreation.__index = CharacterCreation

function CharacterCreation:new()
	local self = setmetatable({}, CharacterCreation)

	self.animator = Animator:new(self)

	self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)

	--Positions des éléments pour animation
	local lionStartY, lionY = -300, self.canvas:getHeight() / 2 - 100
	local rButtonStartY, rButtonY = self.canvas:getHeight() + 200, 745 + 80 / 2
	local nameInputStartT, nameInputY = self.canvas:getHeight() + 100, 150 / 2 + 882

	--Text en haut
	self.welcomeText = UI.Text.TextWavy:new(
		"Create your avatar !",
		self.canvas:getWidth() / 2,
		100,
		{ amplitude = 5, speed = 3, spacing = 0.3, font = Fonts.soraBig, revealSpeed = 10, centered = true }
	)

	self.nameInput = TextInput:new(
		self.canvas:getWidth() / 2,
		980,
		900,
		90,
		{ noSpace = false, maxChars = 10, noSpecial = true, forceCaps = false }
	)

	self.nextButton = Button:new(
		function()
			self:saveCharacter()
		end,
		"src/assets/sprites/ui/NextTuto.png",
		223 / 2 + 1650,
		150 / 2 + 882,
		223,
		150,
		nil,
		function()
			return Inputs.getMouseInCanvas(0, 0)
		end
	)

	self.randomizeButton = Button:new(
		function()
			self:generateRandomCharacter()
		end,
		"src/assets/sprites/ui/Randomize.png",
		690 + 544 / 2,
		745 + 80 / 2,
		544,
		80,
		nil,
		function()
			return Inputs.getMouseInCanvas(0, 0)
		end
	)

	self.randomizeButton.layer = 1
	self.nextButton.layer = 1

	--Texts de personalisation
	self.customizationTexts = {
		head = { love.graphics.newText(Fonts.soraMedium, "Head color"), 320, 200 },
		shoulders = { love.graphics.newText(Fonts.soraMedium, "Shoulders color"), 320, 400 },
		crown1 = { love.graphics.newText(Fonts.soraMedium, "Crown 1 color"), 320, 600 },
		crown2 = { love.graphics.newText(Fonts.soraMedium, "Crown 2 color"), 320, 800 },
		eyes = { love.graphics.newText(Fonts.soraMedium, "Eyes"), 1590, 200 },
		nose = { love.graphics.newText(Fonts.soraMedium, "Nose"), 1590, 400 },
		mouth = { love.graphics.newText(Fonts.soraMedium, "Mouth"), 1590, 600 },
	}
	--Boutons de customization
	self.arrowButtons = {
		headArrowLeft = Button:new(
			function()
				self:changePart("head", -1)
			end,
			"src/assets/sprites/ui/Arrow Button L.png",
			111,
			200,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		headArrowRight = Button:new(
			function()
				self:changePart("head", 1)
			end,
			"src/assets/sprites/ui/Arrow Button.png",
			529,
			200,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		shouldersArrowLeft = Button:new(
			function()
				self:changePart("shoulders", -1)
			end,
			"src/assets/sprites/ui/Arrow Button L.png",
			111,
			400,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		shouldersArrowRight = Button:new(
			function()
				self:changePart("shoulders", 1)
			end,
			"src/assets/sprites/ui/Arrow Button.png",
			529,
			400,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		cr1ArrowLeft = Button:new(
			function()
				self:changePart("cr1", -1)
			end,
			"src/assets/sprites/ui/Arrow Button L.png",
			111,
			600,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		cr1ArrowRight = Button:new(
			function()
				self:changePart("cr1", 1)
			end,
			"src/assets/sprites/ui/Arrow Button.png",
			529,
			600,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		cr2ArrowLeft = Button:new(
			function()
				self:changePart("cr2", -1)
			end,
			"src/assets/sprites/ui/Arrow Button L.png",
			111,
			800,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		cr2ArrowRight = Button:new(
			function()
				self:changePart("cr2", 1)
			end,
			"src/assets/sprites/ui/Arrow Button.png",
			529,
			800,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		--Colonne de droite
		eyesArrowLeft = Button:new(
			function()
				self:changePart("eyes", -1)
			end,
			"src/assets/sprites/ui/Arrow Button L.png",
			Constants.VIRTUAL_GAME_WIDTH - 529,
			200,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		eyesArrowRight = Button:new(
			function()
				self:changePart("eyes", 1)
			end,
			"src/assets/sprites/ui/Arrow Button.png",
			Constants.VIRTUAL_GAME_WIDTH - 111,
			200,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		noseArrowLeft = Button:new(
			function()
				self:changePart("nose", -1)
			end,
			"src/assets/sprites/ui/Arrow Button L.png",

			Constants.VIRTUAL_GAME_WIDTH - 529,
			400,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		noseArrowRight = Button:new(
			function()
				self:changePart("nose", 1)
			end,
			"src/assets/sprites/ui/Arrow Button.png",
			Constants.VIRTUAL_GAME_WIDTH - 111,
			400,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		mouthArrowLeft = Button:new(
			function()
				self:changePart("mouth", -1)
			end,
			"src/assets/sprites/ui/Arrow Button L.png",
			Constants.VIRTUAL_GAME_WIDTH - 529,
			600,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
		mouthArrowRight = Button:new(
			function()
				self:changePart("mouth", 1)
			end,
			"src/assets/sprites/ui/Arrow Button.png",
			Constants.VIRTUAL_GAME_WIDTH - 111,
			600,
			80,
			80,
			nil,
			function()
				return Inputs.getMouseInCanvas(0, 0)
			end
		),
	}
	for i, button in next, self.arrowButtons do
		button.layer = 2
	end

	self.ui = { self.randomizeButton, self.nextButton }
	self.lion = Lion:new()

	return self
end

function CharacterCreation:update(dt)
	self.animator:update(dt)
	self:updateCanvas(dt)
	self.lion:update()
	self.nameInput:update(dt)
	self.welcomeText:update(dt)

	self.nextButton:setActivated(self.nameInput.text ~= "")

	for i, button in next, self.arrowButtons do
		button:update(dt)
	end

	for i, element in next, self.ui do
		element:update(dt)
	end
end

function CharacterCreation:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	self.welcomeText:draw()

	--Dessin des boutons
	for i, element in next, self.ui do
		element:draw()
	end

	for i, button in next, self.arrowButtons do
		button:draw()
	end

	--Texts
	local px, py = G.calculateParalaxeOffset(3)

	for i, text in next, self.customizationTexts do
		love.graphics.draw(
			text[1],
			text[2] + px,
			text[3] + py,
			0,
			1,
			1,
			text[1]:getWidth() / 2,
			text[1]:getHeight() / 2
		)
	end

	--Dessin du texte Input
	self.nameInput:draw()
	--Dessin du lion
	--Background
	local px, py = G.calculateParalaxeOffset(1)
	love.graphics.draw(
		Sprites.LION_FRAME,
		self.canvas:getWidth() / 2 + px,
		self.canvas:getHeight() / 2 - 90 + py,
		0,
		1,
		1,
		Sprites.LION_FRAME:getWidth() / 2,
		Sprites.LION_FRAME:getHeight() / 2
	)
	self.lion:draw(self.canvas:getWidth() / 2 + px, self.canvas:getHeight() / 2 - 100 + py, 550, 550)

	--Dessin du texte de bienvenue (Créée ton personnage !)

	love.graphics.setCanvas(currentCanvas)
end

function CharacterCreation:draw()
	love.graphics.draw(self.canvas, 0, 0)
end

--Inputs

function CharacterCreation:mousepressed(x, y, button, istouch, presses)
	for i, element in next, self.ui do
		element:clickEvent()
	end
	for i, element in next, self.arrowButtons do
		element:clickEvent()
	end

	self.nameInput:mousepressed()
end

function CharacterCreation:mousereleased(x, y, button, istouch, presses)
	for i, element in next, self.ui do
		local wasReleased = element:releaseEvent()
		if wasReleased then --Si le click a été complété
			element:getCallback()()
		end
	end
	for i, element in next, self.arrowButtons do
		local wasReleased = element:releaseEvent()
		if wasReleased then --Si le click a été complété
			element:getCallback()()
		end
	end
end

function CharacterCreation:mousemoved(x, y, dx, dy, isDragging) end

function CharacterCreation:keypressed(key)
	self.nameInput:keypressed(key)
end

function CharacterCreation:textinput(t)
	self.nameInput:textinput(t)
end

--Functions

function CharacterCreation:generateRandomCharacter()
	self.lion:generateRandomLion()
end

function CharacterCreation:saveCharacter()
	G.saveManager.data.profile = {
		name = self.nameInput.text,
		avatar = {
			head = self.lion.headIndex,
			crown_1 = self.lion.crownOneIndex,
			crown_2 = self.lion.crownTwoIndex,
			shoulders = self.lion.shouldersIndex,
			eyes = self.lion.eyesIndex,
			mouth = self.lion.mouthIndex,
			nose = self.lion.noseIndex,
		},
	}

	G.saveManager:save()

	G.game.mainMenu = MainMenu:new()

	G.game.currentScreen = Constants.PAGES.MAIN_MENU

	G.playerName = self.nameInput.text
	G.playerLion = Lion:new()
	G.playerLion:createFromIndexes(G.saveManager.data.profile.avatar)
end

function CharacterCreation:changePart(part, direction)
	local nParts = {
		cr1 = self.lion.nCrown1,
		cr2 = self.lion.nCrown2,
		eyes = self.lion.nEyes,
		head = self.lion.nHead,
		mouth = self.lion.nMouth,
		nose = self.lion.nNose,
		shoulders = self.lion.nShoulders,
	}

	local indexParts = {
		cr1 = "crownOneIndex",
		cr2 = "crownTwoIndex",
		eyes = "eyesIndex",
		head = "headIndex",
		mouth = "mouthIndex",
		nose = "noseIndex",
		shoulders = "shouldersIndex",
	}

	if self.lion[indexParts[part]] + direction > nParts[part] then
		self.lion[indexParts[part]] = 1
	elseif self.lion[indexParts[part]] + direction <= 0 then
		self.lion[indexParts[part]] = self.lion[indexParts[part]]
	else
		self.lion[indexParts[part]] = direction + self.lion[indexParts[part]]
	end

	self.lion:updateSprite()
end

return CharacterCreation
