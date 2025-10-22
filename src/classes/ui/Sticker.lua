local Animator = require("src.utils.Animator")
local UIElement = require("src.classes.ui.UIElement")

local Sticker = setmetatable({}, { __index = UIElement })

Sticker.__index = Sticker

function Sticker:new(stickerObject, x, y, size, isSelectable, isHoverable, mousePosition, absoluteX, absoluteY)
	local self = setmetatable(UIElement.new(), Sticker)

	self.animator = Animator:new(self)
	self.canvas = love.graphics.newCanvas(90, 90)

	self.x = x
	self.y = y
	self.isHoverable = isHoverable
	self.isSelectable = isSelectable
	self.isDraggable = true
	self.dragXspeed = 0

	self.sprite = love.graphics.newImage("src/assets/sprites/stickers/Flame.png")

	self.anchorX = nil
	self.anchorY = nil

	self.stickerObject = stickerObject

	return self
end

function Sticker:update(dt) end

function Sticker:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	love.graphics.setCanvas(currentCanvas)
end

function Sticker:draw() end

return Sticker
