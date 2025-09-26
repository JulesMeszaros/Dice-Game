local DiceFace = require("src.classes.ui.DiceFace")
local Sprites = require("src.utils.Sprites")
local Inputs = require("src.utils.scripts.Inputs")

local Deck = {}
Deck.__index = Deck

function Deck:new()
	local self = setmetatable({}, Deck)

	self.canvas = love.graphics.newCanvas(1130, 830)
	self.diceFaces = {}

	--Create the dice faces
	for _, d in next, G.game.run.diceObjects do
		local dice = {}
		for __, df in next, d:getAllFaces() do
			local f = DiceFace:new(d, df, 30 + (_ - 1) * 150 + 410, (__ - 1) * 120 + 140, 120, false, true, function()
				return Inputs.getMouseInCanvas(510, 30)
			end, nil, 510, 30)
			print(f)
			table.insert(dice, f)
		end
		self.diceFaces[d] = dice
	end

	return self
end

function Deck:update(dt)
	self:updateCanvas(dt)
end

function Deck:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)

	--love.graphics.rectangle("fill", 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
	love.graphics.draw(Sprites.DECK_PANEL, self.canvas:getWidth(), 0, 0, 1, 1, Sprites.DECK_PANEL:getWidth(), 0)

	--Draw the faces
	for i, dice in next, self.diceFaces do
		for _, diceface in next, dice do
			diceface:update(dt)
			diceface:draw()
		end
	end

	love.graphics.setCanvas(currentCanvas)
end

function Deck:draw()
	love.graphics.draw(self.canvas, 510, 30)
end

return Deck
