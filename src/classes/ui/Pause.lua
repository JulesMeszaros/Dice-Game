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

	self.canvas = love.graphics.newCanvas(500, 500)
	self.animator = Animator:new(self)

	return self
end

function PauseMenu:update(dt)
	self.animator:update(dt)
	self:updateCanvas(dt)
end

function PauseMenu:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear(1, 1, 1)
	love.graphics.setColor(1, 0, 0)
	love.graphics.draw(
		pauseText,
		self.canvas:getHeight() / 2,
		self.canvas:getHeight() / 2,
		0,
		1,
		1,
		pauseText:getWidth() / 2,
		pauseText:getHeight() / 2
	)

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

function PauseMenu:mousepressed(x, y, button, istouch, presses) end

function PauseMenu:keypressed(k) end

function PauseMenu:mousereleased(x, y, button, istouch, presses) end

function PauseMenu:mousemoved(x, y, dx, dy, isDragging) end

return PauseMenu
