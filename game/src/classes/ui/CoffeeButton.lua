local Shaders = require("src.utils.Shaders")
local Fonts = require("src.utils.Fonts")
local Animator = require("src.utils.Animator")
local AnimationUtils = require("src.utils.scripts.Animations")
local Inputs = require("src.utils.scripts.Inputs")
local Button = require("src.classes.ui.Button")
local Sprites = require("src.utils.Sprites")
local Constants = require("src.utils.Constants")

local CoffeeButton = setmetatable({}, { __index = Button })
CoffeeButton.__index = CoffeeButton

function CoffeeButton:new(x, y, mousePosition, figureIndex, run)
  local self = setmetatable(
    Button:new(nil, "src/assets/sprites/coffee/Black.png", x, y, 350, 60, nil, mousePosition),
    CoffeeButton
  )

  --Spécifics
  self.used = false
  self.figureIndex = figureIndex
  self.sprite = Sprites.COFFEE_SPRITES[self.figureIndex]
  self.run = run

  self.representedObject = {
    name = Constants.COFFEE_NAMES[self.figureIndex],
    objectType = "Coffee",
    description = "Upgrades the figure "
      .. Constants.FIGURES_LABELS[self.figureIndex]
      .. " of one level (lvl."
      .. tostring(self.run.figuresInfos[self.figureIndex].level)
      .. " -> lvl."
      .. tostring(self.run.figuresInfos[self.figureIndex].level + 1)
      .. ")",
  }

  self.representedObject.getDescription = function()
    return "Upgrades the figure "
      .. Constants.FIGURES_LABELS[self.figureIndex]
      .. " of one level (lvl."
      .. tostring(self.run.figuresInfos[self.figureIndex].level)
      .. " -> lvl."
      .. tostring(self.run.figuresInfos[self.figureIndex].level + 1)
      .. ")"
  end

  self.absoluteX = 0
  self.absoluteY = 0

  --Oscillations
  self.oscillatingScale = false
  self.oscillatingAngle = false
  self.oscillatingY = false
  --Amplitude
  self.oscilYAmp = 0
  self.oscilAngleAmp = 0
  self.oscilScaleAmp = 0
  --Periode en secondes
  self.oscilYP = 1
  self.oscilAngleP = 1
  self.oscilScaleP = 1
  --Offsets
  self.oscilYO = math.random(1, 100)
  self.oscilAngleO = math.random(1, 100)
  self.oscilScaleO = math.random(1, 100)

  return self
end

function CoffeeButton:update(dt)
  self.animator:update(dt)

  if not self.animator:isAnimating("scale") then
    if self:isHovered() and self.used == false and self.isActivated == true then
      self.targetedScale = 1.03

      if love.mouse.isDown(1) and self.isActivated then
        self.targetedScale = 0.97
      end
    else
      self.targetedScale = 1
    end

    local speed = 30
    self.scale = self:dampLerp(self.scale, self.targetedScale, speed, dt)
  end

  --update the button canvas
  self:updateCanvas()
end

function CoffeeButton:updateCanvas()
  local currentCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.uiCanvas)
  love.graphics.clear()

  --If desactivated : grey the button
  if self.used == true then
    love.graphics.setShader(Shaders.grayscaleShader)
  elseif self:isHovered() then
    love.graphics.setShader(Shaders.glowShader)
    Shaders.glowShader:send("glow_strength", 0.4)
    Shaders.glowShader:send("glow_color", Constants.FIGURES_COLORS[self.figureIndex]) -- un jaune doré
  else
    love.graphics.setShader()
  end

  love.graphics.draw(self.sprite, 0, 0, 0, 1, 1)

  love.graphics.setShader()

  love.graphics.setCanvas(currentCanvas)
end

function CoffeeButton:draw()
  local layer = self.layer or 4
  local px, py = G.calculateParalaxeOffset(layer)
  local oy, oAngle, oScale = self:getOscillation(love.timer.getTime())

  if self.drawShadow == true then
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.draw(
      self.uiCanvas,
      self.x + px - 20,
      self.y + py + oy + 20,
      0 + oAngle,
      self.scale * oScale,
      self.scale * oScale,
      self.uiCanvas:getWidth() / 2,
      self.uiCanvas:getHeight() / 2
    )
    love.graphics.setColor(1, 1, 1, 1)
  end

  love.graphics.draw(
    self.uiCanvas,
    self.x + px,
    self.y + py + oy,
    0 + oAngle,
    self.scale * oScale,
    self.scale * oScale,
    self.uiCanvas:getWidth() / 2,
    self.uiCanvas:getHeight() / 2
  )
end

--Interaction functions
function CoffeeButton:clickAction()
  if self.run.money >= Constants.BASE_COFFEE_PRICE and self.used == false then
    --On s'assure que si on est dans une run tutorial, on a la possibilité d'acheter du caffé
    if not self.run.tutorial or self.run.shop.canBuyAnything == true then
      --Retirer l'argent

      self.run.money = self.run.money - Constants.BASE_COFFEE_PRICE
      self.run.totalspent = self.run.totalspent + Constants.BASE_COFFEE_PRICE

      --Level Up la figure
      self.run.totalUsedCoffees = self.run.totalUsedCoffees + 1
      self.run:levelUpFigure(self.figureIndex)

      --Desactiver le bouton
      self.used = true
      self.isActivated = false

      --Ajouter au save manager
      if G.saveManager.data.stats.coffees[self.figureIndex] then
        G.saveManager.data.stats.coffees[self.figureIndex] = G.saveManager.data.stats.coffees[self.figureIndex] + 1 + 1
      else
        G.saveManager.data.stats.coffees[self.figureIndex] = 1
      end
    end
  end
end

function CoffeeButton:getOscillation(time)
  local x = 0
  local angle = 0
  local scale = 1

  if self.oscillatingY then
    x = math.sin((time + self.oscilYO) * (2 * math.pi / self.oscilYP)) * self.oscilYAmp
  end

  if self.oscillatingAngle then
    angle = math.sin((time + self.oscilAngleO) * (2 * math.pi / self.oscilAngleP)) * self.oscilAngleAmp
  end

  if self.oscillatingScale then
    scale = 1 + math.sin((time + self.oscilScaleO) * (2 * math.pi / self.oscilScaleP)) * self.oscilScaleAmp
  end

  return x, angle, scale
end

return CoffeeButton
