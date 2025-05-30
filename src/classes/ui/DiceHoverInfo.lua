local Fonts = require("src.utils.fonts")

local DiceHoverInfo = {}
DiceHoverInfo.__index = DiceHoverInfo

function DiceHoverInfo:new(text)
    local self = setmetatable({}, DiceHoverInfo)

    self.canvas = love.graphics.newCanvas(400, 170)

    self.title = "."
    self.text = "."
    self.x = 0
    self.y = 0
    self.hidden = true

    return self
end

function DiceHoverInfo:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)

    love.graphics.clear()

    local width, wrappedText = Fonts.pixelatedMedium:getWrap(self.title, self.canvas:getWidth())
    local textObject = love.graphics.newText(Fonts.pixelatedMedium, table.concat(wrappedText, '\n'))
    love.graphics.draw(textObject, self.canvas:getWidth()/2, self.canvas:getHeight(), 0, 1, 1, textObject:getWidth()/2, textObject:getHeight())

    love.graphics.setCanvas(currentCanvas)
end

function DiceHoverInfo:draw()
    if(self.hidden==false)then
        love.graphics.draw(self.canvas, self.x, self.y)
    end
end

function DiceHoverInfo:setText(text)
    self.title = text
end

return DiceHoverInfo