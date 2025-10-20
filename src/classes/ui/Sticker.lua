local Animator = require("src.utils.Animator")
local UIElement = require("src.classes.ui.UIElement")

local Sticker = setmetatable({}, { __index = UIElement })

Sticker.__index = Sticker

function Sticker:new()
	local self = setmetatable(UIElement.new(), Sticker)

	self.animator = Animator:new(self)
	self.canvas = love.graphics.newCanvas(120, 120)

	return self
end

function Sticker:update(dt) end

function Sticker:updateCanvas(dt) end

function Sticker:draw() end

return Sticker
