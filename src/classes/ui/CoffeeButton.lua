local Shaders = require("src.utils.Shaders")
local Fonts = require("src.utils.Fonts")
local Animator = require("src.utils.Animator")
local AnimationUtils = require("src.utils.scripts.Animations")
local Inputs = require("src.utils.scripts.Inputs")
local Button = require("src.classes.ui.Button")
local Sprites = require("src.utils.Sprites")
local Constants = require("src.utils.Constants")

local CoffeeButton = setmetatable({}, {__index = Button})
CoffeeButton.__index = CoffeeButton

function CoffeeButton:new(
    x, 
    y,  
    mousePosition,
    figureIndex,
    run)

    local self = setmetatable(Button:new(
        nil, 
        "src/assets/sprites/coffee/Black.png", 
        x, 
        y, 
        350,
        60,
        nil, 
        mousePosition
    ), CoffeeButton)

    --Spécifics
    self.used = false
    self.figureIndex = figureIndex
    self.sprite = Sprites.COFFEE_SPRITES[self.figureIndex]
    self.run = run
    
    return self

end

function CoffeeButton:update(dt)
    self.animator:update(dt)
    
    if(self:isHovered())then
        if(love.mouse.isDown(1) and self.isActivated) then
            self.targetedScale = 0.90
        end
    else
        self.targetedScale = 1
    end

    local speed = 30
    self.scale = self:dampLerp(self.scale, self.targetedScale, speed, dt)

    --update the button canvas
    self:updateCanvas()
end

function CoffeeButton:updateCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.uiCanvas)
    love.graphics.clear()

    --If desactivated : grey the button
    if self.used==true then
        love.graphics.setShader(Shaders.grayscaleShader)
    else
        love.graphics.setShader()
    end

    love.graphics.draw(self.sprite, 0, 0, 0, 1, 1)

    love.graphics.setShader()

    love.graphics.setCanvas(currentCanvas)
end

--Interaction functions
function CoffeeButton:clickAction()
    if(self.run.money >= Constants.BASE_COFFEE_PRICE and self.used==false) then
        --Retirer l'argent
        self.run.money = self.run.money - Constants.BASE_COFFEE_PRICE

        --Level Up la figure
        self.run:levelUpFigure(self.figureIndex)

        --Desactiver le bouton
        self.used=true
        self.isActivated=false

        print(self.figureIndex, "utilisé")
    end
end

return CoffeeButton