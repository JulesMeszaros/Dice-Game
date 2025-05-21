--Classe servant à afficher une face de dé, avec ses propriétés et ses effets et ses interractions
local UIElement = require("src.classes.ui.UIElement")


local DiceFace = setmetatable({}, { __index = UIElement })
DiceFace.__index = DiceFace

function DiceFace:new(dice, face, x, y, size, isSelectable, isHoverable)
    self.srite = nil
        
    local self = setmetatable(UIElement.new(), DiceFace)

    --Parametres d'interractions
    self.isSelectable = true
    self.isHoverable = true
    self.isDraggable = true
    self.dragXspeed = 0

    self.dice = dice -- sets the dice and the face it represents
    self.face = face
    self.spriteSheet = dice:getSpriteSheet()
    self.quad = dice:getQuad(face)
    self.dim = dice:getFaceDim()
    self.x = x
    self.y = y
    self.baseSize = size
    self.size = self.baseSize

    self.targetedRotation = 0
    self.rotation = 0

    return self
end

function DiceFace:update(dt)
    if(self:isHovered())then
        self.targetedScale = 0.95 --Si hovered
        if(love.mouse.isDown(1)) then
            self.targetedScale = 0.90 --Si clicked
        end
    else
        self.targetedScale = 1
    end

    self:calculateAngleDrag()

    local speed = 30
    self.scale = self.scale + (self.targetedScale - self.scale)*speed*dt
    self.rotation = self.rotation + (self.targetedRotation - self.rotation)*speed*dt

end

function DiceFace:draw()
    shadow = self:renderShadow()
    render = self:render()

    love.graphics.draw(shadow, self.x+10, self.y+10, self.rotation, self.scale, self.scale, render:getWidth()/2, render:getHeight()/2)
    love.graphics.draw(render, self.x, self.y, self.rotation, self.scale, self.scale, render:getWidth()/2, render:getHeight()/2)

end

function DiceFace:render()
    canvasSize = self.size --sets the base face of the canvas

    ratio = canvasSize/self.dim --ratio between the image size and the canvas size

    faceCanvas = love.graphics.newCanvas(canvasSize, canvasSize) -- create the canvas
    
    --General settings
    faceCanvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(faceCanvas)

    --Draw the face image
    love.graphics.draw(self.spriteSheet, self.quad, 0, 0, 0, ratio, ratio) -- add the image

    love.graphics.setCanvas()
    return faceCanvas
end

function DiceFace:renderShadow()
    canvasSize = self.size --sets the base face of the canvas
    ratio = canvasSize/self.dim --ratio between the image size and the canvas size
    shadowCanvas = love.graphics.newCanvas(canvasSize, canvasSize) -- create the canvas

    --General settings
    shadowCanvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(shadowCanvas)

    love.graphics.setColor(0, 0, 0, 0.25)  -- black with 50% opacity
    love.graphics.rectangle("fill", 0, 0, shadowCanvas:getWidth(), shadowCanvas:getHeight())
    love.graphics.setColor(1,1,1,1)  -- black with 50% opacity

    love.graphics.setCanvas()
    return shadowCanvas

end

function DiceFace:isHovered() --Check if mouse is above the face
    if(not self.isHoverable) then
        return false
    end
    
    if(
        (love.mouse.getX() > self:getX()-(self.size/2)) 
        and 
        (love.mouse.getX() < (self:getX() + (self.size/2)))
        and
        (love.mouse.getY() > self:getY()-(self.size/2)) 
        and 
        (love.mouse.getY() < (self:getY() + (self.size/2)))
    )
    then
        return true
    else
        return false
    end
    
end

function DiceFace:clickEvent()
    wasClicked = false -- Variable retournée : vrai si le dé a été cliqué, faux si le dé n'a pas été clické
    if(self:isHovered()) then
        self.isBeingClicked = true
        wasClicked = true
    end

    return wasClicked
end

function DiceFace:clickAction()
    self:selectOrDeselect()
end

function DiceFace:updateSize()
    if(self:getIsSelected())then
        self.size = self.baseSize + (self.baseSize/100)*20
    else
        self.size = self.baseSize
    end 
end

function DiceFace:updateSprite()
    self.spriteSheet = self.dice:getSpriteSheet()
    self.quad = self.dice:getQuad(self.face)
    self.dim = self.dice:getFaceDim()
end

--Get/set Functions--
function DiceFace:setSelected(state)
    self.isSelected = state
    self:updateSize()
end

function DiceFace:getDice()
    return self.dice
end

function DiceFace:getFace()
    return self.face
end

function DiceFace:setDice(dice)
    self.dice = dice
end

function DiceFace:setFace(face)
    self.face = face
    self:updateSprite()
end

function DiceFace:calculateAngleDrag()
    maxRotation = 0.3

    if(self.isBeingDragged)then --Rotation pendant le drag
        self.targetedRotation = 0.02*self.dragXspeed
    else
        self.targetedRotation = 0
    end

    if self.targetedRotation < 0-maxRotation then
        self.targetedRotation = 0-maxRotation
    end

    if self.targetedRotation > maxRotation then
        self.targetedRotation = maxRotation
    end
end

return DiceFace