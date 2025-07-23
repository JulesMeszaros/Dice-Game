local Fonts = require("src.utils.Fonts")

local PopUpText = {}
PopUpText.__index = PopUpText

function PopUpText:new()
    local self = setmetatable({}, PopUpText)

    self.text = love.graphics.newText(Fonts.soraMedium, "Placeholder")

    self.x = 300
    self.y = 300

    self.canvas = love.graphics.newCanvas(500, 500)

    return self
end

function PopUpText:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    love.graphics.draw(self.text, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.text:getWidth()/2, self.text:getHeight()/2)

    love.graphics.setCanvas(currentCanvas)
end

function PopUpText:draw()
    love.graphics.draw(self.canvas, x, y, 0, 1, 1, self.canvas:getWidth()/2, self.canvas:getHeight()/2)
end

return PopUpText