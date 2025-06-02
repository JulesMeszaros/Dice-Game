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

function DiceFace2:draw()
    love.graphics.draw(self.diceCanvas, self.x, self.y, self.rotation, self.scale, self.scale, self.diceCanvas:getWidth()/2, self.diceCanvas:getHeight()/2)
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


return DiceFace2