--Classe servant à afficher une face de dé, avec ses propriétés et ses effets et ses interractions
local UIElement = require("src.classes.ui.UIElement")
--Utils
local AnimationUtils = require("src.utils.scripts.animationUtils")
local InputsUtils = require("src.utils.scripts.inputs")
local Constants = require("src.utils.constants")
local Shaders = require("src.utils.shaders")

local DiceFace2 = setmetatable({}, { __index = UIElement })

local scaleSpeed = 20
local rSpeed = 50
local moveSpeed = 15

DiceFace2.__index = DiceFace2

function DiceFace2:new(diceObject, faceNumber, x, y, size, isSelectable, isHoverable, mousePosition, round)    
    local self = setmetatable(UIElement.new(), DiceFace2)

    --Parametres d'interractions
    self.mousePosition = mousePosition --The function returning the mousePosition for this dice.
    self.isSelectable = isSelectable
    self.isHoverable = isHoverable
    self.isDraggable = true
    self.dragXspeed = 0
	self.isHighlighted = false

    --Dice parameters
    self.diceObject = diceObject -- link to the diceObject it represents
    self.faceNumber = faceNumber -- Sets the number of the face

    self.spriteSheet = self.diceObject:getFace(self.faceNumber):getSpriteSheet()
    self.quad = self.diceObject:getFace(self.faceNumber):getQuad(self.faceNumber)
    self.dim = self.diceObject:getFace(self.faceNumber):getFaceDim()

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
    self.targetedScale = 1
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
    self.round = round

    --Clock
    self.time = 0

    --Create canvas and shadow canvas
    self.diceCanvas = self:createCanvas()
    --self.shadowCanvas = self:createShadow()

    --Triggering variables
    self.isTriggering = false
    self.triggerTimer = 0 --Minuteur de trigger 
    self.triggerTime = Constants.BASE_TRIGGER_ANIMATION_TIME --Temps que prend un dé à se trigger

    return self
end

function DiceFace2:update(dt)
    self.time=self.time+dt

    --Calculate targeted Scale and Rotation
    self:calculateAngleDrag()
    self.targetedRotation = self.baseRotation + self.dragRotation

    --Update scale, rotation and position
    self:updatePosition(dt)
    self:updateScale(dt)
    self:updateAngle(dt)

    --==Update the trigger==--
    if(self.isTriggering)then
        self.triggerTimer = self.triggerTimer + dt
        if(self.triggerTimer >= self.triggerTime)then
            self.isTriggering = false
            self.round:triggerNextDice() --Triggers the next dice in queue in the round
        end
    end

    if(self.isTriggering)then
        self.isHoverable = false
        self.isSelectable = false
        self:calculateTriggerScale()
    else
        self.isSelectable = true
        self.isHoverable = true
        self:calculateScale()
    end

    --update canvas
    self:updateCanvas(dt)
end

function DiceFace2:draw()
    love.graphics.draw(self.diceCanvas, self.x, self.y, self.rotation, self.scale, self.scale, self.diceCanvas:getWidth()/2, self.diceCanvas:getHeight()/2)
end

--==INTERACTION==--
function DiceFace2:isHovered() --Check if mouse is above the face
    --Utilise la fonction passée en paramètre, qui permet d'avoir la position de la souris dans laquelle elle est rendue.
    local vx, vy = self.mousePosition().x, self.mousePosition().y

    return(
        self.isHoverable and
        vx > (self.x-(self.size/2)) and vx < (self.x+(self.size/2))
        and
        vy > (self.y-(self.size/2)) and vy < (self.y+(self.size/2))
        )
end

function DiceFace2:clickEvent()
    local wasClicked = false -- Variable retournée : vrai si le dé a été cliqué, faux si le dé n'a pas été clické
    if(self:isHovered()) then
        self.isBeingClicked = true
        wasClicked = true
        self:resetBaseAngle()
    end

    return wasClicked
end

function DiceFace2:clickAction()
    self:selectOrDeselect()
end

--==VISUAL FUNCTIONS==--

function DiceFace2:createCanvas()
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

function DiceFace2:updateCanvas(dt)
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

function DiceFace2:calculateScale()
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
		self.highlightScale = AnimationUtils.osccilate(self.time, 5, 0.15)
	else
		self.highlightScale = 0
	end

    --Update targeted scale, rotation and position
    self.targetedScale = self.baseTargetedScale + self.selectionScale + self.hoverScale + self.highlightScale
    
end

function DiceFace2:calculateTriggerScale()
     local t = self.triggerTimer / self.triggerTime

    local s = math.sin(2*t * math.pi) -- varie de 0 à 1 à 0
    self.targetedScale = 1 + (1.5 - 1) * s
end

--==GET/SET FUNCTIONS==--
function DiceFace2:resetBaseAngle()
    self.baseRotation = 0
end

function DiceFace2:setSelected(state)
    self.isSelected = state
end

function DiceFace2:getDiceObject()
    return self.diceObject
end

function DiceFace2:setDiceObject(diceObject)
    self.diceObject = diceObject
end

function DiceFace2:setHighlighted(state)
	self.isHighlighted = state
end

--==UTILS==--

function DiceFace2:calculateAngleDrag()
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

function DiceFace2:updatePosition(dt)
    self.x, self.velx = springUpdate(self.x, self.targetX, self.velx, dt, 4, 0.8)
    self.y, self.vely = springUpdate(self.y, self.targetY, self.vely, dt, 4, 0.8)
end

function DiceFace2:calculateScale()
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
		self.highlightScale = AnimationUtils.osccilate(self.time, 5, 0.15)
	else
		self.highlightScale = 0
	end

    --Update targeted scale, rotation and position
    self.targetedScale = self.baseTargetedScale + self.selectionScale + self.hoverScale + self.highlightScale
    
end

function DiceFace2:calculateTriggerScale()
     local t = self.triggerTimer / self.triggerTime

    local s = math.sin(2*t * math.pi) -- varie de 0 à 1 à 0
    self.targetedScale = 1 + (1.5 - 1) * s
end

function DiceFace2:updateAngle(dt)
    self.rotation, self.velrotation = springUpdate(self.rotation, self.targetedRotation, self.velrotation, dt, 5, 0.4)
end

function DiceFace2:updateScale(dt)
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

return DiceFace2