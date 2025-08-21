--Classe servant à afficher une face de dé, avec ses propriétés et ses effets et ses interractions
local UIElement = require("src.classes.ui.UIElement")
--Utils
local AnimationUtils = require("src.utils.scripts.Animations")
local InputsUtils = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local Shaders = require("src.utils.Shaders")
local Animator = require("src.utils.Animator")
local Sprites = require("src.utils.Sprites")

local DiceFace = setmetatable({}, { __index = UIElement })

DiceFace.__index = DiceFace

function DiceFace:new(diceObject, representedFace, x, y, size, isSelectable, isHoverable, mousePosition, round, absoluteX, absoluteY)    
    local self = setmetatable(UIElement.new(), DiceFace)
    self.animator = Animator:new(self)

    --Parametres d'interractions
    self.mousePosition = mousePosition --The function returning the mousePosition for this dice.
    self.isSelectable = isSelectable
    self.isSelectableAll = isSelectable
    self.isHoverable = isHoverable
    self.isDraggable = true
    self.dragXspeed = 0
	self.isHighlighted = false

    --Dice parameters
    self.diceObject = diceObject -- link to the diceObject it represents
    self.representedObject = representedFace --Sets the represented face of the dice
    self:updateSprite() --Updates the sprite a first time with the given parameters
    
    --Position
    self.targetX = x
    self.targetY = y
    self.x = x
    self.y = y
	self.z = 0 --Détermine l'ordre de dessin des dés sur le terrain
    self.absoluteX = absoluteX or 0
    self.absoluteY = absoluteY or 0

    --Size
    self.baseSize = size
    self.size = self.baseSize

    --Rotation
    self.targetedRotation = 0 --Angle the dice is targeting
    self.baseRotation = 0 --Base angle for the calculation of targetedRotation (basically the targeted angle when nothing happens)
    self.dragRotation = 0 --Angle calculated based on the drag speed
    self.rotation = 0 --Angle the dice is actually showed at

    --Scale
    self.scaleX = 1
    self.scaleY = 1
    self.targetedScale = 1
	self.highlightScale = 0
    self.baseTargetedScale = 1
    self.selectionScale = 0
    self.hoverScale = 0
    self.reduceOnHover = true
    self.shadowOnDrag = false

    --Animations variables
    self.velx = 0
    self.vely = 0
    self.velrotation = 0
    self.velscale = 0
    self.displayedNumber = nil

    --The canvas to be rendred in
    self.round = round

    --Clock
    self.time = 0

    --Create canvas and shadow canvas
    self.diceCanvas = self:createCanvas()
    --self.shadowCanvas = self:createShadow()

    --Triggering variables
    self.isTriggering = false
    return self
end

function DiceFace:update(dt)
    self.time=self.time+dt
    --Rolling animation
    if(self.displayedNumber)then
        self:updateSprite(math.floor(self.displayedNumber))
    end


    --Calculate targeted Scale and Rotation
    self:calculateAngleDrag()
    self.targetedRotation = self.baseRotation + self.dragRotation

    --Update scale, rotation and position
    self:updatePosition(dt)
    self:updateScale(dt)
    self:updateAngle(dt)
    self.animator:update(dt)

    --Selection state--
    --[[ if(self.isSelected)then
        self.isDraggable = false
    else
        self.isDraggable = true
    end ]]

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
    --Si activé : ombre au drag and drop
    --[[ love.graphics.setShader(Shaders.black)

    love.graphics.setColor(1, 1, 1, 0.7)
    
    love.graphics.draw(self.diceCanvas, self.x-self.hoverScale*100, self.y+self.hoverScale*100, self.rotation, self.scaleX, self.scaleY, self.diceCanvas:getWidth()/2, self.diceCanvas:getHeight()/2)
    
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1) ]]

    -- Draw the dice canvas with premultiplied alpha to avoid black halo on edges
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(
        self.diceCanvas,
        self.x, self.y,
        self.rotation,
        self.scaleX, self.scaleY,
        self.diceCanvas:getWidth() / 2,
        self.diceCanvas:getHeight() / 2
    )
    -- Restore default blend mode
    love.graphics.setBlendMode("alpha", "alphamultiply")
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
        self.isBeingClicked = true
        wasClicked = true
        self:resetBaseAngle()
    end

    return wasClicked
end

function DiceFace:clickAction()
    if(self.isSelectableAll == true) then
        self:selectOrDeselect()
    end
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
    
    --If disabled, draw the red sign
    if(self.representedObject.disabled==true) then
        love.graphics.draw(Sprites.DISABLED, 0, 0, 0, 1, 1)
    end

    love.graphics.setShader()
    love.graphics.setCanvas(currentCanvas)
end

function DiceFace:updateSprite(n)
    local representedFace = self.representedObject
    
    if(n) then
        representedFace = self.representedObject.diceObject:getAllFaces()[n]
    end
    
    self.spriteSheet = representedFace:getSpriteSheet()
    self.quad = representedFace:getQuad(representedFace.faceValue)
    self.dim = representedFace:getFaceDim()
end

function DiceFace:setRepresentedFace(face)
    self.representedObject = face
    self:updateSprite()
end

--==TRIGGER FUNCTIONS==--
function DiceFace:trigger(round) --Lance le trigger du dé
    self.animator:addDelay(0.2)

    --[[ self.animator:addGroup({
        {property="scaleX", from=1, targetValue=1.2, duration=0.1, easing=AnimationUtils.Easing.easeOutBack},
        {property="scaleY", from=1, targetValue=1.2, duration=0.1, easing=AnimationUtils.Easing.easeOutBack}
    }) ]]

    self.animator:addDelay(0.05, function() self.representedObject:trigger(round); round.terrain:animateHandScore() end) --On déclenche l'effet du dé ici

    self.animator:addGroup({
        {property="scaleX", from=1.5, targetValue=1, duration=0.3},
        {property="scaleY", from=1.5, targetValue=1, duration=0.3},
        {property="rotation", from=0.5, targetValue=0, duration=0.3, easing=AnimationUtils.Easing.easeOutBack}
    })

    self.animator:addDelay(0.0, function()self.targetedScale = 1 ; self.round:triggerNextDice()end)
end

function DiceFace:triggerBackup(round)
    self.animator:addDelay(0.3)

    self.animator:addGroup({
        {property="scaleX", from=1.6, targetValue=0.5, duration=0.05},
        {property="scaleY", from=0.8, targetValue=1.7, duration=0.05}
    })

    self.animator:addDelay(0.1, function() self.representedObject:triggerBackup(round, self); round.terrain:animateHandScore() end) --On déclenche l'effet du dé ici

    self.animator:addGroup({
        {property="scaleX", from=0.5, targetValue=1, duration=0.1},
        {property="scaleY", from=1.3, targetValue=1, duration=0.1}
    })

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
    self.representedObject = faceObject
    self:updateSprite()
end

--==UTILS==--

function DiceFace:disable(run)
    run.totalDisabled = run.totalDisabled + 1
    self.representedObject.disabled = true
end

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
        if(self.reduceOnHover == true)then
            self.hoverScale = -0.1 --Si hovered
            if(love.mouse.isDown(1)) then
                self.hoverScale = -0.15 --Si clicked
            end
        elseif(self.reduceOnHover==false) then
            self.hoverScale = 0.1 --Si hovered
            if(love.mouse.isDown(1)) then
                self.hoverScale = 0.15 --Si clicked
            end
        else
            
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
        if math.abs(self.scaleX - self.targetedScale) < 0.001 then --Update scaleX
            self.scaleX = self.targetedScale
        else
            self.scaleX, self.velscale = springUpdate(self.scaleX, self.targetedScale, self.velscale, dt, 4, 0.6)
        end

        if math.abs(self.scaleY - self.targetedScale) < 0.001 then --update scaleY
            self.scaleY = self.targetedScale
        else
            self.scaleY, self.velscale = springUpdate(self.scaleY, self.targetedScale, self.velscale, dt, 4, 0.6)
        end
    end
end

--==Animations==--
function springUpdate(current, target, velocity, dt, frequency, damping)
    --On met un cap sur le dt
    dt = math.min(dt, 1 / 30)

    local f = frequency * 2 * math.pi
    local g = damping
    local delta = target - current
    local accel = f * f * delta - 2 * g * f * velocity
    velocity = velocity + accel * dt
    current = current + velocity * dt
    return current, velocity
end

function DiceFace:flipChange(newFace)
    self.animator:addGroup({
        {property = "scaleX", from=self.scaleX, targetValue=1.2, duration=0.2},
        {property = "scaleY", from=self.scaleY, targetValue=1.2, duration=0.2}
    })
    self.animator:addDelay(0.1)
    self.animator:add("scaleX", 1.2, 0, 0.1, nil, function()self:setRepresentedFace(newFace)end)
    self.animator:add("scaleX", 0, 1.2, 0.1)
    self.animator:addDelay(0.1)
    self.animator:addGroup({
        {property = "scaleX", from=1.2, targetValue=self.scaleX, duration=0.2},
        {property = "scaleY", from=1.2, targetValue=self.scaleY, duration=0.2}
    })
end

function DiceFace:shake(xintensity, yintensity, duration)
    local shakeDuration = 0.01 --seconds
    local nIterations = duration/shakeDuration

    for i=1, nIterations do

        local xShake = math.random(-1*xintensity, xintensity)
        local yShake = math.random(-1*yintensity, yintensity)

        self.animator:addGroup({
            {property = "x", from=self.targetX, targetValue=xShake, duration=shakeDuration},
            {property = "y", from=self.targetY, targetValue=yShake, duration=shakeDuration},
        })
    end
    self.animator:addGroup({
            {property = "x", from=self.x, targetValue=self.targetX, duration=shakeDuration},
            {property = "y", from=self.y, targetValue=self.targetY, duration=shakeDuration},
        })

end

return DiceFace