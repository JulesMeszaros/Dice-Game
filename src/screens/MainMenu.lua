local Fonts = require("src.utils.Fonts")
local Inputs = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local Sprites = require("src.utils.Sprites")
local TextInput = require("src.classes.ui.TextInput")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")

local Button = require("src.classes.ui.Button")

local MainMenu = {}

MainMenu.__index = MainMenu

function MainMenu:new(gameCanvas, game)
	local self = setmetatable({}, MainMenu)

	self.uiElements = {
		buttons = {},
	}

	self.gameCanvas = gameCanvas
	self.game = game

	self.animationDices = {}

	--Creating the canvas
	self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)

	--Creation de la boîte de texte pour la seed (temporaire)
	self.seedInput = TextInput:new(self.canvas:getWidth() - 30 - 300, self.canvas:getHeight() - 30 - 50, 300, 50)

	-- Create version text only once
	self.versionText = love.graphics.newText(Fonts.soraSmall, "AEROSOL DELUXE GAMES — " .. Constants.GAME_VERSION)

	self.uiElements.buttons["newRun"] = Button:new(
		function()
			self.game:startNewRun(self.seedInput.text)
		end,
		"src/assets/sprites/ui/New Run.png",
		618 + 678 / 2,
		730 + 180 / 2,
		678,
		180,
		nil,
		function()
			return Inputs.getMouseInCanvas(0, 0)
		end
	)

	G.backgroundChange(Constants.BACKGROUND_COLORS.DARK_GRAY, 0.5)

	return self
end

function MainMenu:update(dt)
	--Buttons
	for key, button in next, self.uiElements.buttons do
		button:update(dt)
	end

	--Text box (temporaire)
	self.seedInput:update(dt)

	--Update the canvas
	self:updateCanvas(dt)
end

function MainMenu:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	--Main title
	love.graphics.draw(Sprites.MAIN_LOGO, self.canvas:getWidth() / 2, 75, 0, 1, 1, Sprites.MAIN_LOGO:getWidth() / 2, 0)

	--Text box (temporaire)
	self.seedInput:draw()

	--Version
	love.graphics.draw(self.versionText, 20, self.canvas:getHeight() - 20, 0, 1, 1, 0, self.versionText:getHeight())

	--Buttons
	for key, button in next, self.uiElements.buttons do
		button:draw()
	end

	love.graphics.setCanvas(currentCanvas)
end

function MainMenu:draw()
	love.graphics.draw(self.canvas, 0, 0)
end

--==MAIN MENU ANIMATION==--

--==KEYBOARD/MOUSE INPUTS==--

function MainMenu:keypressed(key)
	self.seedInput:keypressed(key)
end

function MainMenu:textinput(t)
	self.seedInput:textinput(t)
end

function MainMenu:mousepressed(x, y, button, istouch, presses)
	--Buttons
	for key, button in next, self.uiElements.buttons do
		button:clickEvent()
	end

	--Text input (temporaire)
	self.seedInput:mousepressed()

	print(self.seedInput.text)
end

function MainMenu:mousereleased(x, y, button, istouch, presses)
	--release event on UI elements (buttons)
	for key, button in next, self.uiElements.buttons do
		local wasReleased = button:releaseEvent()
		if wasReleased then --Si le click a été complété
			button:getCallback()()
		end
	end
end

function MainMenu:mousemoved(x, y, dx, dy, isDragging) end

function MainMenu:cleanup()
	-- Release main menu canvas
	if self.canvas then
		self.canvas:release()
		self.canvas = nil
	end

	-- Release button canvases
	for _, button in pairs(self.uiElements.buttons) do
		if button.uiCanvas then
			button.uiCanvas:release()
			button.uiCanvas = nil
		end
	end

	-- Release version text
	if self.versionText then
		self.versionText:release()
		self.versionText = nil
	end
end

return MainMenu

