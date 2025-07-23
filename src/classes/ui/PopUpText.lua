local Fonts = require("src.utils.Fonts")
local Animator = require("src.utils.Animator")
local Constants = require("src.utils.Constants")

local PopUpText = {}
PopUpText.__index = PopUpText

function PopUpText:new(text, screen)
    local self = setmetatable({}, PopUpText)

    self.animator = Animator:new(self)

    self.rotations, self.scaleX, self.scaleY, self.opacity = math.random(-0.5, 0.5), 1, 1, 1

    self.text = love.graphics.newText(Fonts.soraBig, text)

    --Random position
    self.x = math.random(Constants.VIRTUAL_GAME_WIDTH/3, 2*Constants.VIRTUAL_GAME_WIDTH/3)
    self.y = math.random(Constants.VIRTUAL_GAME_HEIGHT/3, 2*Constants.VIRTUAL_GAME_HEIGHT/3)

    self.color = {1, 0, 0}

    self.canvas = love.graphics.newCanvas(1000, 500)
    print("terrain", screen)
    self.animator:add("opacity", 1, 0, 0.3, nil, function()self:destruct(screen)end)

    return self
end

function PopUpText:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    self.animator:update(dt)

    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.opacity)
    love.graphics.draw(self.text, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.text:getWidth()/2, self.text:getHeight()/2)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setCanvas(currentCanvas)
end

function PopUpText:draw()
    love.graphics.draw(self.canvas, self.x, self.y, self.rotations, self.scaleX, self.scaleY, self.canvas:getWidth()/2, self.canvas:getHeight()/2)
end

function PopUpText:destruct(screen)
    print(screen)
    for i,v in next,screen.popupTexts do
        if(v==self)then
            table.remove(screen.popupTexts, i)
        end
    end
end

return PopUpText