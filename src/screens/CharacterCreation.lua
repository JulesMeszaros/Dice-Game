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

	self.character = Lion:new()

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
		900,
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

	--Dessin du texte Input
	self.nameInput:draw()
	--Dessin du lion
	--Background
	love.graphics.draw(
		Sprites.LION_FRAME,
		self.canvas:getWidth() / 2,
		self.canvas:getHeight() / 2 - 90,
		0,
		1,
		1,
		Sprites.LION_FRAME:getWidth() / 2,
		Sprites.LION_FRAME:getHeight() / 2
	)
	self.lion:draw(self.canvas:getWidth() / 2, self.canvas:getHeight() / 2 - 100, 550, 550)

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
	self.nameInput:mousepressed()
end

function CharacterCreation:mousereleased(x, y, button, istouch, presses)
	for i, element in next, self.ui do
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
end

return CharacterCreation
