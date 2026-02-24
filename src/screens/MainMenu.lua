local Fonts = require("src.utils.Fonts")
local Inputs = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local Sprites = require("src.utils.Sprites")
local TextInput = require("src.classes.ui.TextInput")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")

local Button = require("src.classes.ui.Button")

local MainMenu = {}

MainMenu.__index = MainMenu

seedLabel = love.graphics.newText(love.graphics.newFont("src/assets/fonts/Sora-ExtraBold.otf", 50), "Seed :")

function MainMenu:new()
	local self = setmetatable({}, MainMenu)

	self.uiElements = {
		buttons = {},
	}

	self.animationDices = {}

	--Creating the canvas
	self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)

	--Creation de la boîte de texte pour la seed (temporaire)
	self.seedInput = TextInput:new(
		self.canvas:getWidth() - 30 - 225,
		self.canvas:getHeight() - 30 - 25,
		450,
		50,
		{ noSpace = true, maxChars = 8, noSpecial = true, forceCaps = true }
	)

	-- Create version text only once
	self.versionText =
		love.graphics.newText(Fonts.soraSmall, "AEROSOL DELUXE Interactives — " .. Constants.GAME_VERSION)

	self.uiElements.buttons["newRun"] = Button:new(
		function()
			G.game:startNewRun(self.seedInput.text, false)
		end,
		"src/assets/sprites/ui/New Run.png",
		Constants.VIRTUAL_GAME_WIDTH / 2,
		620 + 180 / 2,
		680,
		180,
		nil,
		function()
			return Inputs.getMouseInCanvas(0, 0)
		end
	)

	self.uiElements.buttons["newTutorial"] = Button:new(
		function()
			G.game:startNewRun("IOXAHBAJ", true)
		end,
		"src/assets/sprites/ui/TutorialButton.png",
		Constants.VIRTUAL_GAME_WIDTH / 2,
		930,
		340,
		90,
		nil,
		function()
			return Inputs.getMouseInCanvas(0, 0)
		end
	)

	self.uiElements.buttons["website"] = Button:new(
		function()
			love.system.openURL("http://adx.n8scape.fr")
		end,
		"src/assets/sprites/ui/WWW.png",
		250,
		100,
		120,
		120,
		nil,
		function()
			return Inputs.getMouseInCanvas(0, 0, 4)
		end
	)

	self.uiElements.buttons["discord"] = Button:new(
		function()
			love.system.openURL("https://discord.gg/SEbbEsjt57")
		end,
		"src/assets/sprites/ui/Discord.png",
		100,
		100,
		120,
		120,
		nil,
		function()
			return Inputs.getMouseInCanvas(0, 0, 4)
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
	love.graphics.draw(
		seedLabel,
		self.canvas:getWidth() - 500,
		self.canvas:getHeight() - 30,
		0,
		1,
		1,
		seedLabel:getWidth(),
		seedLabel:getHeight()
	)
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
