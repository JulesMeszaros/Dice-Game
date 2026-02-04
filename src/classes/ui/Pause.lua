local Fonts = require("src.utils.Fonts")
local Inputs = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local Sprites = require("src.utils.Sprites")
local TextInput = require("src.classes.ui.TextInput")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")
local Animator = require("src.utils.Animator")
local Button = require("src.classes.ui.Button")

local PauseMenu = {}

PauseMenu.__index = PauseMenu

local pauseText = love.graphics.newText(Fonts.soraBig, "Pause")

function PauseMenu:new()
	local self = setmetatable({}, PauseMenu)

	self.canvas = love.graphics.newCanvas(1247, 770)
	self.animator = Animator:new(self)

	--Création des boutons
	self.buttons = {}
	self.buttons["resume"] = Button:new(
		function()
			G.game.run:togglePauseMenu()
		end,
		"src/assets/sprites/ui/ResumeRun.png",
		626,
		678,
		1176,
		80,
		nil,
		function()
			return Inputs.getMouseInCanvas(336, 155)
		end
	)

	self.buttons["toggle"] = Button:new(
		function()
			print("toggle sound")
		end,
		"src/assets/sprites/ui/ToggleSound.png",
		385 + (477 / 2),
		180,
		477,
		80,
		nil,
		function()
			return Inputs.getMouseInCanvas(336, 155)
		end
	)

	self.buttons["reset"] = Button:new(
		function()
			print("reset run")
		end,
		"src/assets/sprites/ui/ResetRun.png",
		385 + (477 / 2),
		385,
		477,
		80,
		nil,
		function()
			return Inputs.getMouseInCanvas(336, 155)
		end
	)

	self.buttons["quit"] = Button:new(
		function()
			print("quit run")
		end,
		"src/assets/sprites/ui/QuitRun.png",
		385 + (477 / 2),
		515,
		477,
		80,
		nil,
		function()
			return Inputs.getMouseInCanvas(336, 155)
		end
	)

	return self
end

function PauseMenu:update(dt)
	self.animator:update(dt)
	self:updateCanvas(dt)
end

function PauseMenu:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	--Background
	love.graphics.draw(Sprites.PAUSE_BG, 0, 0)

	--buttons
	for k, button in next, self.buttons do
		button:update(dt)
		button:draw()
	end

	love.graphics.setCanvas(currentCanvas)
end

function PauseMenu:draw()
	love.graphics.draw(
		self.canvas,
		Constants.VIRTUAL_GAME_WIDTH / 2,
		Constants.VIRTUAL_GAME_HEIGHT / 2,
		0,
		1,
		1,
		self.canvas:getWidth() / 2,
		self.canvas:getHeight() / 2
	)
end

--Interactions

function PauseMenu:mousepressed(x, y, button, istouch, presses)
	for k, button in next, self.buttons do
		button:clickEvent()
	end
end

function PauseMenu:keypressed(k) end

function PauseMenu:mousereleased(x, y, button, istouch, presses)
	for key, button in next, self.buttons do
		local wasReleased = button:releaseEvent()
		if wasReleased then --Si le click a été complété
			button:getCallback()()
		end
	end
end

function PauseMenu:mousemoved(x, y, dx, dy, isDragging) end

return PauseMenu
