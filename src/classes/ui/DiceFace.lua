--Classe servant à afficher une face de dé, avec ses propriétés et ses effets et ses interractions
local UIElement = require("src.classes.ui.UIElement")
--Utils
local AnimationUtils = require("src.utils.scripts.animationUtils")
local InputsUtils = require("src.utils.scripts.inputs")
local Constants = require("src.utils.constants")
local Shaders = require("src.utils.shaders")
local Animator = require("src.utils.Animator")

local DiceFace = setmetatable({}, { __index = UIElement })

DiceFace.__index = DiceFace

function DiceFace:new(diceObject, representedFace, x, y, size, isSelectable, isHoverable, mousePosition, round)    
    local self = setmetatable(UIElement.new(), DiceFace)
    self.animator = Animator:new(self)

    --Parametres d'interractions
    self.mousePosition = mousePosition --The function returning the mousePosition for this dice.
    self.isSelectable = isSelectable
    self.isHoverable = isHoverable
    self.isDraggable = true
    self.dragXspeed = 0
	self.isHighlighted = false

    --Dice parameters
    self.diceObject = diceObject -- link to the diceObject it represents
    self.representedFace = representedFace --Sets the represented face of the dice
    self:updateSprite() --Updates the sprite a first time with the given parameters
    
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

function DiceFace:update(dt)
    self.time=self.time+dt
    
    --Calculate targeted Scale and Rotation
    self:calculateAngleDrag()
    self.targetedRotation = self.baseRotation + self.dragRotation

    --Update scale, rotation and position
    self:updatePosition(dt)
    self:updateScale(dt)
    self:updateAngle(dt)
    self.animator:update(dt)

    --Selection state--
    if(self.isSelected)then
        self.isDraggable = false
    else
        self.isDraggable = true
    end

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

function DiceFace:draw()
    love.graphics.draw(self.diceCanvas, self.x, self.y, self.rotation, self.scale, self.scale, self.diceCanvas:getWidth()/2, self.diceCanvas:getHeight()/2)
end

--==INTERACTION==--
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
        print("Bello")
        self.isBeingClicked = true
        wasClicked = true
        self:resetBaseAngle()
    end

    return wasClicked
end

function DiceFace:clickAction()
    self:selectOrDeselect()
end

function DiceFace:selectOrDeselect()
    local newState = not self:getIsSelected()
    self:setSelected(newState)

    if(self.round and newState == false)then
        local randomXPos = math.random(100, self.round.terrain.dice_tray:getWidth()-100)
        local randomYPos = math.random(250, self.round.terrain.dice_tray:getHeight()-250)

        self.targetX = randomXPos ; self.targetY = randomYPos
    end
end

--==VISUAL FUNCTIONS==--

function DiceFace:createCanvas()
    local currentCanvas = love.graphics.getCanvas()
    local canvasSize = self.size --sets the base face of the canvas

    local ratio = canvasSize/self.dim --ratio between the image size and the canvas size
    local faceCanvas = love.graphics.newCanvas(canvasSize, canvasSize) -- create the canvas

    --General settings
    faceCanvas:setFilter("nearest", "nearest")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(faceCanvas)

    love.graphics.draw(self.spriteSheet, self.quad, 0, 0, 0, ratio, ratio) -- add the image
    
    love.graphics.setCanvas(currentCanvas)

    return faceCanvas
end

function DiceFace:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    
    local canvasSize = self.size --sets the base face of the canvas
    local ratio = canvasSize/self.dim --ratio between the image size and the canvas size

    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceCanvas)
    love.graphics.clear()

    love.graphics.draw(self.spriteSheet, self.quad, 0, 0, 0, ratio, ratio) -- add the image
    
    love.graphics.setShader()
    love.graphics.setCanvas(currentCanvas)
end

function DiceFace:updateSprite()
    self.spriteSheet = self.representedFace:getSpriteSheet()
    self.quad = self.representedFace:getQuad(self.representedFace.faceValue)
    self.dim = self.representedFace:getFaceDim()
end

function DiceFace:setRepresentedFace(face)
    self.representedFace = face
end

function DiceFace:calculateScale()
    --Calculate scale
    if(self:isHovered())then
        self.hoverScale = -0.1 --Si hovered
        if(love.mouse.isDown(1)) then
            self.hoverScale = -0.15 --Si clicked
        end
    else
        self.hoverScale = 0
    end

	if(self.isHighlighted==true)then
		self.highlightScale = AnimationUtils.osccilate(self.time, 5, 0.15)
	else
		self.highlightScale = 0
	end

    --Update targeted scale, rotation and position
    self.targetedScale = self.baseTargetedScale + self.hoverScale + self.highlightScale
    
end

function DiceFace:calculateTriggerScale()
     local t = self.triggerTimer / self.triggerTime

    local s = math.sin(2*t * math.pi) -- varie de 0 à 1 à 0
    self.targetedScale = 1 + (1.5 - 1) * s
end

--==TRIGGER FUNCTIONS==--
function DiceFace:trigger() --Lance le trigger du dé
    self.triggerTimer = 0
    self.isTriggering = true
end

--==GET/SET FUNCTIONS==--
function DiceFace:resetBaseAngle()
    self.baseRotation = 0
end

function DiceFace:setSelected(state)
    self.isSelected = state
end

function DiceFace:getDiceObject()
    return self.diceObject
end

function DiceFace:setDiceObject(diceObject)
    self.diceObject = diceObject
end

function DiceFace:setHighlighted(state)
	self.isHighlighted = state
end

function DiceFace:setFaceObject(faceObject)
    self.representedFace = faceObject
    faceObject:setDiceObject(self)
    self:updateSprite()
end

--==UTILS==--

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
    --On check qu'il n'y ait pas d'animation en cours
    if(self.animator.current == nil and table.getn(self.animator.queue) == 0 )then
        if math.abs(self.x - self.targetX) < 3 then
            self.x = self.targetX
            self.y = self.targetY
        else
            self.x, self.velx = springUpdate(self.x, self.targetX, self.velx, dt, 4, 0.8)
            self.y, self.vely = springUpdate(self.y, self.targetY, self.vely, dt, 4, 0.8)
        end
    else
        self.targetX = self.x
        self.targetY = self.y
    end
end

function DiceFace:calculateScale()
    --Calculate scale
    if(self:isHovered())then
        self.hoverScale = -0.1 --Si hovered
        if(love.mouse.isDown(1)) then
            self.hoverScale = -0.15 --Si clicked
        end
    else
        self.hoverScale = 0
    end

	if(self.isHighlighted==true)then
		self.highlightScale = AnimationUtils.osccilate(self.time, 5, 0.15)
	else
		self.highlightScale = 0
	end

    --Update targeted scale, rotation and position
    self.targetedScale = self.baseTargetedScale + self.selectionScale + self.hoverScale + self.highlightScale
    
end

function DiceFace:calculateTriggerScale()
     local t = self.triggerTimer / self.triggerTime

    local s = math.sin(2*t * math.pi) -- varie de 0 à 1 à 0
    self.targetedScale = 1 + (1.5 - 1) * s
end

function DiceFace:updateAngle(dt)
    if(self.animator.current == nil and table.getn(self.animator.queue) == 0)then
        if math.abs(self.rotation - self.targetedRotation) < 0.001 then
            self.rotation = self.targetedRotation
        else
            self.rotation, self.velrotation = springUpdate(self.rotation, self.targetedRotation, self.velrotation, dt, 5, 0.4)
        end
    else
        self.baseRotation = self.rotation
    end
end

function DiceFace:updateScale(dt)
    if(self.animator.current == nil and table.getn(self.animator.queue) == 0)then
        if math.abs(self.scale - self.targetedScale) < 0.001 then
            self.scale = self.targetedScale
        else
            self.scale, self.velscale = springUpdate(self.scale, self.targetedScale, self.velscale, dt, 4, 0.6)
        end
    end
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

--==Animations==--
function DiceFace:shake(intensity, duration, steps)
    local stepDuration = duration/steps
    for i=1,steps do
        self.animator:add("x", self.x+math.random(-intensity, intensity), stepDuration)
        self.animator:add("y", self.y+math.random(-intensity, intensity), stepDuration)
    end
    self.animator:add("x", self.x, stepDuration)
    self.animator:add("y", self.y, stepDuration, nil, function()print("shaking over")end)
end

return DiceFace