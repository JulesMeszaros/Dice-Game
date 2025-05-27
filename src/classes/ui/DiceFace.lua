--Classe servant à afficher une face de dé, avec ses propriétés et ses effets et ses interractions
local UIElement = require("src.classes.ui.UIElement")

local InputsUtils = require("src.utils.scripts.inputs")
local Constants = require("src.utils.constants")
local Shaders = require("src.utils.shaders")

local DiceFace = setmetatable({}, { __index = UIElement })

local scaleSpeed = 20
local rSpeed = 50
local moveSpeed = 15

DiceFace.__index = DiceFace

function DiceFace:new(dice, face, x, y, size, isSelectable, isHoverable, mousePosition, renderCanvas)    
    local self = setmetatable(UIElement.new(), DiceFace)

    --Parametres d'interractions
    self.mousePosition = mousePosition --The function returning the mousePosition for this dice.
    self.isSelectable = isSelectable
    self.isHoverable = isHoverable
    self.isDraggable = true
    self.dragXspeed = 0
	self.isHighlighted = false

    --Dice parameters
    self.dice = dice -- sets the dice and the face it represents
    self.face = face
    self.spriteSheet = dice:getSpriteSheet()
    self.quad = dice:getQuad(face)
    self.dim = dice:getFaceDim()

    --Position
    self.targetX = x
    self.targetY = y
    self.x = x
    self.y = y
	self.z = 0 --Détermine l'ordre de dessin des dés sur le terrain

    --Size
    self.baseSize = size
    self.size = self.baseSize

    --Rotation
    self.targetedRotation = 0 --Angle the dice is targeting
    self.baseRotation = 0 --Base angle for the calculation of targetedRotation (basically the targeted angle when nothing happens)
    self.dragRotation = 0 --Angle calculated based on the drag speed
    self.rotation = 0 --Angle the dice is actually showed at

    --Scale
	self.highlightScale = 0
    self.baseTargetedScale = 1
    self.selectionScale = 0
    self.hoverScale = 0

    --Animations variables
    self.velx = 0
    self.vely = 0
    self.velrotation = 0
    self.velscale = 0

    --The canvas to be rendred in
    self.renderCanvas = renderCanvas --Le canvas dans laquel le dé est dessiné. Permet d'avoir des infos genre sa largeur.

    --Clock
    self.time = 0

    --Create canvas and shadow canvas
    self.diceCanvas = self:createCanvas()
    self.shadowCanvas = self:createShadow()

    return self
end

function DiceFace:update(dt)
    self.time=self.time+dt

    --Calculate scale
    if(self:isHovered())then
        self.hoverScale = -0.1 --Si hovered
        if(love.mouse.isDown(1)) then
            self.hoverScale = -0.15 --Si clicked
        end
    else
        self.hoverScale = 0
    end

    if(self.isSelected)then
        self.selectionScale = 0.2
    else
        self.selectionScale = 0
    end

	if(self.isHighlighted==true)then
		self.highlightScale = 0.3
	else
		self.highlightScale = 0
	end

    self.targetedScale = self.baseTargetedScale + self.selectionScale + self.hoverScale + self.highlightScale

    self:calculateAngleDrag()
    self.targetedRotation = self.baseRotation + self.dragRotation

    --Update scale, rotation and position

    self:updatePosition(dt)
    self:updateScale(dt)
    self:updateAngle(dt)

    --update canvas
    self:updateCanvas()
end

function DiceFace:draw()
    --local shadow = self:renderShadow()
    local render = self.diceCanvas

    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.renderCanvas)
    --Render l'ombre
    love.graphics.draw(self.shadowCanvas, self.x+10, self.y+10, self.rotation, self.scale, self.scale, render:getWidth()/2, render:getHeight()/2)

    --Render la face du dé  
    love.graphics.draw(render, self.x, self.y, self.rotation, self.scale, self.scale, render:getWidth()/2, render:getHeight()/2)

    love.graphics.setCanvas(currentCanvas)
end

function DiceFace:createCanvas()
    local currentCanvas = love.graphics.getCanvas()
    local canvasSize = self.size --sets the base face of the canvas

    local ratio = canvasSize/self.dim --ratio between the image size and the canvas size

    local faceCanvas = love.graphics.newCanvas(canvasSize, canvasSize) -- create the canvas

    --General settings
    faceCanvas:setFilter("nearest", "nearest")
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

function DiceFace:createShadow()
    local currentCanvas = love.graphics.getCanvas()
    local canvasSize = self.size --sets the base face of the canvas

    local ratio = canvasSize/self.dim --ratio between the image size and the canvas size

    local shadowCanvas = love.graphics.newCanvas(canvasSize, canvasSize) -- create the canvas
    
    --General settings
    shadowCanvas:setFilter("nearest", "nearest")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(shadowCanvas)


    love.graphics.setColor(0, 0, 0, 0.25)  -- black with 50% opacity
    love.graphics.rectangle("fill", 0, 0, shadowCanvas:getWidth(), shadowCanvas:getHeight())
    love.graphics.setColor(1,1,1,1)  -- black with 50% opacity

    love.graphics.setCanvas(currentCanvas)
    return shadowCanvas

end

function DiceFace:updateCanvas()
    local currentCanvas = love.graphics.getCanvas()
    
    local canvasSize = self.size --sets the base face of the canvas
    local ratio = canvasSize/self.dim --ratio between the image size and the canvas size

    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceCanvas)
    love.graphics.clear()

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

function DiceFace:setHighlighted(state)
	self.isHighlighted = state
end

function DiceFace:setFace(face)
    self.face = face
    self:updateSprite()
end



--==ANGLE/SCALE/POSITION FUNCTIONS==--

function DiceFace:calculateAngleDrag()
    --Function used to calculate the target angle of the dice base on the drag speed
    local maxRotation = 1

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

function DiceFace:updatePosition(dt)
    self.x, self.velx = springUpdate(self.x, self.targetX, self.velx, dt, 4, 0.8)
    self.y, self.vely = springUpdate(self.y, self.targetY, self.vely, dt, 4, 0.8)
end

function DiceFace:updateAngle(dt)
    self.rotation, self.velrotation = springUpdate(self.rotation, self.targetedRotation, self.velrotation, dt, 5, 0.4)
end

function DiceFace:updateScale(dt)
    self.scale, self.velscale = springUpdate(self.scale, self.targetedScale, self.velscale, dt, 4, 0.6)
end

--==Utilities==--
function springUpdate(current, target, velocity, dt, frequency, damping)
    local f = frequency * 2 * math.pi
    local g = damping
    local delta = target - current
    local accel = f * f * delta - 2 * g * f * velocity
    velocity = velocity + accel * dt
    current = current + velocity * dt
    return current, velocity
end

return DiceFace