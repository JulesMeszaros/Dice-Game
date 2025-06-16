local Shaders = require("src.utils.shaders")

local UIElement = require("src.classes.ui.UIElement")
local Inputs = require("src.utils.scripts.inputs")

local badgeSprite = love.graphics.newImage("src/assets/sprites/ui/terrain/badge-proto.png")

local Badge = setmetatable({}, { __index = UIElement })
Badge.__index = Badge

function Badge:new(
    round, 
    x, 
    y, 
    width, 
    height,
    mousePosition)

    local self = setmetatable(UIElement.new(), Badge)

    self:setX(x)
    self:setY(y)

    self.sprite = badgeSprite

    self.height = height
    self.width = width
    self.targetedScale = 1

    --Hover options
    self.isHoverable = true
    self.mousePosition = mousePosition

    --Dragging options
    self.isDraggable = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0

    self.round = round

    --Create the canvas ONCE
    self.uiCanvas = self:createCanvas()

    return self
end

function Badge:update(dt)
    if(self:isHovered())then
        self.targetedScale = 0.95
        if(love.mouse.isDown(1) and self.isActivated) then
            self.targetedScale = 0.90
        end
    else
        self.targetedScale = 1
    end

    local speed = 30
    self.scale = self.scale + (self.targetedScale - self.scale)*speed*dt

    --update the Badge canvas
    self:updateCanvas(dt)
end

function Badge:createCanvas(gameCanvas)
    local canvas = love.graphics.newCanvas(self.width, self.height)

    --General settings
    canvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(canvas)

    love.graphics.setCanvas(gameCanvas)

    return canvas
end

function Badge:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.uiCanvas)
    love.graphics.clear()

    love.graphics.draw(self.sprite, 0, 0) -- add the background

    love.graphics.setCanvas(currentCanvas)
end

function Badge:draw()
    love.graphics.draw(self.uiCanvas, self.x+self.uiCanvas:getWidth()/2, self.y+self.uiCanvas:getHeight()/2, 0, self.scale, self.scale, self.uiCanvas:getWidth()/2, self.uiCanvas:getHeight()/2)
end

--[[ function Badge:getCallback()
    if(self.isActivated==true) then
        return self.callbackFunction --Returns the function
    else
        return function()end --Doesnt do anything
    end
end ]]

function Badge:isHovered() --Check if mouse is above the face
    --Utilise la fonction passée en paramètre, qui permet d'avoir la position de la souris dans laquelle elle est rendue.
    local vx, vy = self.mousePosition().x, self.mousePosition().y

    return(
        self.isHoverable and
        vx > (self.x) and vx < (self.x+(self.width))
        and
        vy > (self.y) and vy < (self.y+(self.height))
        )
end

return Badge