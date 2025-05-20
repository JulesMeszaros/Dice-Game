local UIElement = require("src.classes.ui.UIElement")

local Button = setmetatable({}, { __index = UIElement })
Button.__index = Button

function Button:new(callback, spritePath, x, y, width, height)
    local self = setmetatable(UIElement.new(), Button)

    self:setSprite(love.graphics.newImage(spritePath))

    self:setX(x)
    self:setY(y)

    self.height = height
    self.width = width

    --Dragging options
    self.isDraggable = true
    self.dragOffsetX = 0
    self.dragOffsetY = 0

    self:shadowOnHover(false)

    self.callbackFunction = callback

    return self
end

function Button:update(dt)
    if(self:isHovered())then
        self.targetedScale = 0.95
        if(love.mouse.isDown(1)) then
            self.targetedScale = 0.90
        end
    else
        self.targetedScale = 1
    end

    local speed = 30
    self.scale = self.scale + (self.targetedScale - self.scale)*speed*dt
end

function Button:renderSprite()
    canvasHeight = self.height
    canvasWidth = self.width

    canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)

    --General settings
    canvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(canvas)

    widthRatio = canvasWidth/self.sprite:getWidth()
    heightRatio = canvasHeight/self.sprite:getHeight()

    --Draw the UI into the canvas
    love.graphics.draw(self.sprite, 0, 0, 0, widthRatio, heightRatio) -- add the image

    --If Hovered : draw a shadow above the button
    if(self:isHovered() and self.shadowOnHover)then
        -- Apply dark filter
        love.graphics.setColor(0, 0, 0, 0.25)  -- black with 50% opacity
        love.graphics.rectangle("fill", 0, 0, canvas:getWidth(), canvas:getHeight())
        love.graphics.setColor(1,1,1,1)  -- black with 50% opacity
    end

    love.graphics.setCanvas()

    return canvas
end

function Button:getCallback()
    return self.callbackFunction
end

return Button