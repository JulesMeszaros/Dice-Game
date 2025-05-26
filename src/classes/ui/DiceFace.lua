--Classe servant à afficher une face de dé, avec ses propriétés et ses effets et ses interractions
local UIElement = require("src.classes.ui.UIElement")

local InputsUtils = require("src.utils.scripts.inputs")
local Constants = require("src.utils.constants")
local Shaders = require("src.utils.shaders")

local DiceFace = setmetatable({}, { __index = UIElement })
DiceFace.__index = DiceFace

function DiceFace:new(dice, face, x, y, size, isSelectable, isHoverable, mousePosition, renderCanvas)    
    local self = setmetatable(UIElement.new(), DiceFace)

    --Parametres d'interractions
    self.isSelectable = isSelectable
    self.isHoverable = isHoverable
    self.isDraggable = true
    self.dragXspeed = 0

    self.dice = dice -- sets the dice and the face it represents
    self.face = face
    self.spriteSheet = dice:getSpriteSheet()
    self.quad = dice:getQuad(face)
    self.dim = dice:getFaceDim()
    
    
    self.targetX = x
    self.targetY = y
    self.x = x
    self.y = y


    self.baseSize = size
    self.size = self.baseSize

    self.targetedRotation = 0 --Angle the dice is targeting
    self.baseRotation = 0 --Base angle for the calculation of targetedRotation (basically the targeted angle when nothing happens)
    self.dragRotation = 0 --Angle calculated based on the drag speed
    self.rotation = 0 --Angle the dice is actually showed at

    self.mousePosition = mousePosition --The function returning the mousePosition for this dice.

    self.renderCanvas = renderCanvas --Le canvas dans laquel le dé est dessiné. Permet d'avoir des infos genre sa largeur.

    self.time = 0

    self.diceCanvas = self:render()

    return self
end

function DiceFace:update(dt)
    self.time=self.time+dt

    if(self:isHovered())then
        self.targetedScale = 0.95 --Si hovered
        if(love.mouse.isDown(1)) then
            self.targetedScale = 0.90 --Si clicked
        end
    else
        self.targetedScale = 1
    end

    self:calculateAngleDrag()
    self.targetedRotation = self.baseRotation + self.dragRotation

    local scaleSpeed = 20
    self.scale = self.scale + (self.targetedScale - self.scale)*scaleSpeed*dt
    local rSpeed = 8
    self.rotation = self.rotation + (self.targetedRotation - self.rotation)*rSpeed*dt

    local moveSpeed = 15
    self.x = self.x + (self.targetX - self.x)*moveSpeed*dt
    self.y = self.y + (self.targetY - self.y)*moveSpeed*dt


end

function DiceFace:draw()
    local shadow = self:renderShadow()
    local render = self:render()

    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.renderCanvas)
    --Render l'ombre
    love.graphics.draw(shadow, self.x+10, self.y+10, self.rotation, self.scale, self.scale, render:getWidth()/2, render:getHeight()/2)
    --Render la face du dé    
    love.graphics.draw(render, self.x, self.y, self.rotation, self.scale, self.scale, render:getWidth()/2, render:getHeight()/2)
    
    love.graphics.setCanvas(currentCanvas)
end

function DiceFace:render()
    local currentCanvas = love.graphics.getCanvas()
    local canvasSize = self.size --sets the base face of the canvas

    local ratio = canvasSize/self.dim --ratio between the image size and the canvas size

    local faceCanvas = love.graphics.newCanvas(canvasSize, canvasSize) -- create the canvas
    
    --General settings
    faceCanvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(faceCanvas)

    --Draw the face image
     if(self:getIsSelected()==true)then
        love.graphics.setShader(Shaders.rainbowShader)
        Shaders.rainbowShader:send("time", self.time/10 % 1)

    else
        love.graphics.setShader()
    end

    love.graphics.draw(self.spriteSheet, self.quad, 0, 0, 0, ratio, ratio) -- add the image
    
    love.graphics.setShader()
    love.graphics.setCanvas(currentCanvas)
    return faceCanvas
end

function DiceFace:renderShadow()
    local currentCanvas = love.graphics.getCanvas()

    local canvasSize = self.size --sets the base face of the canvas
    local ratio = canvasSize/self.dim --ratio between the image size and the canvas size
    local shadowCanvas = love.graphics.newCanvas(canvasSize, canvasSize) -- create the canvas

    --General settings
    shadowCanvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(shadowCanvas)

    love.graphics.setColor(0, 0, 0, 0.25)  -- black with 50% opacity
    love.graphics.rectangle("fill", 0, 0, shadowCanvas:getWidth(), shadowCanvas:getHeight())
    love.graphics.setColor(1,1,1,1)  -- black with 50% opacity

    love.graphics.setCanvas(currentCanvas)
    return shadowCanvas

end

function DiceFace:isHovered() --Check if mouse is above the face
    --Utilise la fonction passée en paramètre, qui permet d'avoir la position de la souris dans laquelle elle est rendue.
    local vx, vy = self.mousePosition().x, self.mousePosition().y

    return(
        self.isHoverable and
        vx > (self.x-(self.size/2)) and vx < (self.x+(self.size/2))
        and
        vy > (self.y-(self.size/2)) and vy < (self.y+(self.size/2))
        )
end

function DiceFace:clickEvent()
    local wasClicked = false -- Variable retournée : vrai si le dé a été cliqué, faux si le dé n'a pas été clické
    if(self:isHovered()) then
        self.isBeingClicked = true
        wasClicked = true
        self:resetBaseAngle()
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
function DiceFace:resetBaseAngle()
    self.baseRotation = 0
end

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
    local maxRotation = 0.3

    if(self.isBeingDragged)then --Rotation pendant le drag
        self.dragRotation = 0.02*self.dragXspeed
    else
        self.dragRotation = 0
    end

    if self.dragRotation < 0-maxRotation then
        self.dragRotation = 0-maxRotation
    end

    if self.dragRotation > maxRotation then
        self.dragRotation = maxRotation
    end
end

return DiceFace