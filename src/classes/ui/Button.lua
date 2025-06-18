local Shaders = require("src.utils.shaders")

local UIElement = require("src.classes.ui.UIElement")
local Inputs = require("src.utils.scripts.inputs")

local Animator = require("src.utils.Animator")

local Button = setmetatable({}, { __index = UIElement })
Button.__index = Button

function Button:new(
    callback, 
    spritePath, 
    x, 
    y, 
    width, 
    height, 
    gameCanvas, 
    mousePosition)

    self.gameCanvas = gameCanvas

    self.animator = Animator:new(self)

    local self = setmetatable(UIElement.new(), Button)

    self:setSprite(love.graphics.newImage(spritePath))

    self:setX(x)
    self:setY(y)

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

    self.callbackFunction = callback

    --Create the canvas ONCE
    self.uiCanvas = self:createCanvas()

    return self
end

function Button:update(dt)
    self.animator:update(dt)
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

    --update the button canvas
    self:updateCanvas()
end

function Button:createCanvas(gameCanvas)
    local canvas = love.graphics.newCanvas(self.width, self.height)

    --General settings
    canvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(canvas)

    love.graphics.setCanvas(gameCanvas)

    return canvas
end

function Button:updateCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.uiCanvas)
    love.graphics.clear()
    --If desactivated : grey the button
    if self.isActivated==false then
        love.graphics.setShader(Shaders.grayscaleShader)
    else
        love.graphics.setShader()
    end
    --Draw the UI into the canvas
    local widthRatio = self.width/self.sprite:getWidth()
    local heightRatio = self.height/self.sprite:getHeight()

    love.graphics.draw(self.sprite, 0, 0, 0, widthRatio, heightRatio) -- add the image

    love.graphics.setShader()
    love.graphics.setCanvas(currentCanvas)
end

function Button:draw()
    love.graphics.draw(self.uiCanvas, self.x, self.y, 0, self.scale, self.scale, self.uiCanvas:getWidth()/2, self.uiCanvas:getHeight()/2)
end

function Button:getCallback()
    if(self.isActivated==true) then
        return self.callbackFunction --Returns the function
    else
        return function()end --Doesnt do anything
    end
end

function Button:isHovered() --Check if mouse is above the face
    --Utilise la fonction passée en paramètre, qui permet d'avoir la position de la souris dans laquelle elle est rendue.
    local vx, vy = self.mousePosition().x, self.mousePosition().y

    return(
        self.isHoverable and
        vx > (self.x-(self.width/2)) and vx < (self.x+(self.width/2))
        and
        vy > (self.y-(self.height/2)) and vy < (self.y+(self.height/2))
        )
end

return Button