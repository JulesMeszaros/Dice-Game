--Classe servant à afficher une face de dé, avec ses propriétés et ses effets et ses interractions
local UIElement = require("src.classes.ui.UIElement")
--Utils
local AnimationUtils = require("src.utils.scripts.Animations")
local InputsUtils = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local Shaders = require("src.utils.Shaders")
local Animator = require("src.utils.Animator")

local Ciggie = setmetatable({}, { __index = UIElement })
Ciggie.__index = Ciggie

function Ciggie:new(ciggieObject, x, y, isSelectable, isHoverable, mousePosition, round)    
    local self = setmetatable(UIElement.new(), Ciggie)
    self.animator = Animator:new(self)

    --Parametres d'interractions
    self.mousePosition = mousePosition --The function returning the mousePosition for this dice.
    self.isSelectable = isSelectable
    self.isHoverable = isHoverable
    self.isDraggable = true
    self.dragXspeed = 0

    --Dice parameters
    self.representedObject = ciggieObject
    
    --Position
    self.targetX = x
    self.targetY = y
    self.anchorX ,self.anchorY = x, y
    self.x = x
    self.y = y

    --Rotation
    self.targetedRotation = 0 --Angle the dice is targeting
    self.baseRotation = 0 --Base angle for the calculation of targetedRotation (basically the targeted angle when nothing happens)
    self.dragRotation = 0 --Angle calculated based on the drag speed
    self.rotation = 0 --Angle the dice is actually showed at

    --Scale
    self.width, self.height = 340, 40
    self.scaleX = 1
    self.scaleY = 1
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

    self.canvas = self:createCanvas()

    self.sprite = ciggieObject.sprite

    return self
end

function Ciggie:update(dt)
    self.time=self.time+dt
    self.x, self.velx = AnimationUtils.springUpdate(self.x, self.targetX, self.velx, dt, 4, 0.8)
    self.y, self.vely = AnimationUtils.springUpdate(self.y, self.targetY, self.vely, dt, 4, 0.8)

    self:calculateAngleDrag()
    self.targetedRotation = self.baseRotation + self.dragRotation
    self:updateAngle(dt)

    self:updateCanvas(dt)
end

function Ciggie:draw()
    love.graphics.draw(self.canvas, self.x, self.y, self.rotation, 1, 1, self.canvas:getWidth()/2, self.canvas:getHeight()/2)
end

function Ciggie:createCanvas()
    local canvas = love.graphics.newCanvas(340, 40)

    love.graphics.setBlendMode("alpha")

    return canvas
end

function Ciggie:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    love.graphics.draw(self.sprite, 0, 0)

    love.graphics.setCanvas(currentCanvas)
end

--==Animations==--
function Ciggie:updateAngle(dt)
    if(self.animator.current == nil and table.getn(self.animator.queue) == 0)then
            self.rotation, self.velrotation = AnimationUtils.springUpdate(self.rotation, self.targetedRotation, self.velrotation, dt, 5, 0.4)
    else
        self.baseRotation = self.rotation
    end
end

function Ciggie:calculateAngleDrag()
    --Function used to calculate the target angle of the dice base on the drag speed
    local maxRotation = 0.2
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

--==INPUTS FUNCTIONS==--
function Ciggie:releaseEvent() --S'active lorsqu'un click est complété
    local wasReleased = false
    
    if(self:isHovered()==true and self.isBeingClicked == true and not self.isBeingDragged)then --s'active uniquement si la souris est encore sur l'objet et qu'elle etait en train d'appuyer dessus
        self:clickAction()
        wasReleased = true

    end

    

    self.isBeingClicked = false
    self.targetX = self.anchorX
    self.targetY = self.anchorY
    return wasReleased
end

function Ciggie:detectBelowCanvas(round)
    local wasReleasedOnCanvas = false
    if(round.run.currentState == Constants.RUN_STATES.ROUND) then
        --Dice mat
        if(self.x>500 and self.x<1440)and(self.y>491 and self.y<950)then
            --selfrepresentedObject:trigger(round)
            return Constants.CANVAS.DICE_MAT
        end
    end
end

return Ciggie