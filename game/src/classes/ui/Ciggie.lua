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
  self.baseHorizontal = false
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
  self.anchorX, self.anchorY = x, y
  self.x = x
  self.y = y
  self.absoluteX = 0
  self.absoluteY = 0

  --Rotation
  self.targetedRotation = 0 --Angle the dice is targeting
  self.baseRotation = 0 --Base angle for the calculation of targetedRotation (basically the targeted angle when nothing happens)
  self.dragRotation = 0 --Angle calculated based on the drag speed
  self.rotation = 0 --Angle the dice is actually showed at

  --Scale
  self.width, self.height = 350, 50
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

  self.topY = 0

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

function Ciggie:update(dt)
  self.animator:update(dt)

  self.time = self.time + dt
  self.x, self.velx = AnimationUtils.springUpdate(self.x, self.targetX, self.velx, dt, 4, 0.8)
  self.y, self.vely = AnimationUtils.springUpdate(self.y, self.targetY, self.vely, dt, 4, 0.8)

  --Update base angle based on its position onscreen
  if (self.x > 1670 and self.y > 590) or (self.baseHorizontal == false and self.isBeingClicked == false) then
    self.baseRotation = -1.57
  else
    self.baseRotation = 0
  end

  self:calculateAngleDrag()
  self.targetedRotation = self.baseRotation + self.dragRotation
  self:updateAngle(dt)

  self.topY = self.y
    - (self.canvas:getHeight() / 2) * (1 - self.rotation / -1.57)
    - math.abs(self.canvas:getWidth() / 2 * (self.rotation / -1.57))
  self.bottomY = self.y
    + (self.canvas:getHeight() / 2) * (1 - self.rotation / -1.57)
    - math.abs(self.canvas:getWidth() / 2 * (self.rotation / -1.57))

  self:updateCanvas(dt)
end

function Ciggie:draw()
  local layer = self.layer or 1
  local px, py = G.calculateParalaxeOffset(layer)

  local oy, oAngle, oScale = self:getOscillation(love.timer.getTime())

  if self.isBeingDragged or self.drawShadow then
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.draw(
      self.canvas,
      self.x + px - 20,
      self.y + py + 20 + oy,
      self.rotation + oAngle,
      self.scaleX * oScale,
      self.scaleY * oScale,
      self.canvas:getWidth() / 2,
      self.canvas:getHeight() / 2
    )
    love.graphics.setColor(1, 1, 1, 1)
  end

  love.graphics.draw(
    self.canvas,
    self.x + px,
    self.y + py + oy,
    self.rotation + oAngle,
    self.scaleX * oScale,
    self.scaleY * oScale,
    self.canvas:getWidth() / 2,
    self.canvas:getHeight() / 2
  )
end

function Ciggie:createCanvas()
  local canvas = love.graphics.newCanvas(self.width, self.height)

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
  if self.animator.current == nil and table.getn(self.animator.queue) == 0 then
    self.rotation, self.velrotation =
      AnimationUtils.springUpdate(self.rotation, self.targetedRotation, self.velrotation, dt, 5, 0.4)
  else
    self.baseRotation = self.rotation
  end
end

function Ciggie:calculateAngleDrag()
  --Function used to calculate the target angle of the dice base on the drag speed
  local maxRotation = 0.2
  if self.isBeingDragged then --Rotation pendant le drag
    self.dragRotation = 0.02 * self.dragXspeed
  else
    self.dragRotation = 0
  end

  if self.dragRotation < 0 - maxRotation then
    self.dragRotation = 0 - maxRotation
  end

  if self.dragRotation > maxRotation then
    self.dragRotation = maxRotation
  end
end

--==INPUTS FUNCTIONS==--
function Ciggie:isHovered()
  if not self.isHoverable then
    return false
  end

  local layer = self.layer or 1
  local pos = self.mousePosition()

  local vx, vy = pos.x, pos.y -- Décale les coordonnées souris par rapport au centre de rotation
  local dx = vx - self.x
  local dy = vy - self.y

  -- Applique une rotation inverse (pour annuler la rotation de l'objet)
  local angle = -self.baseRotation
  local cosA = math.cos(angle)
  local sinA = math.sin(angle)

  local rx = dx * cosA - dy * sinA
  local ry = dx * sinA + dy * cosA

  -- Test dans l'espace local (non rotationné)
  return (rx > -self.width / 2 and rx < self.width / 2 and ry > -self.height / 2 and ry < self.height / 2)
end

function Ciggie:releaseEvent() --S'active lorsqu'un click est complété
  local wasReleased = false

  if self:isHovered() == true and self.isBeingClicked == true and not self.isBeingDragged then --s'active uniquement si la souris est encore sur l'objet et qu'elle etait en train d'appuyer dessus
    self:clickAction()
    wasReleased = true
  end

  self.isBeingClicked = false
  if self.anchorX and self.anchorY then
    self.targetX = self.anchorX
    self.targetY = self.anchorY
  end
  return wasReleased
end

function Ciggie:getOscillation(time)
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

return Ciggie
