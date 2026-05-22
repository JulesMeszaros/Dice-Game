local UIElement = require("src.classes.ui.UIElement")
local Animator = require("src.utils.Animator")
local Inputs = require("src.utils.scripts.Inputs")

local Slider = setmetatable({}, { __index = UIElement })
Slider.__index = Slider

function Slider:new(x, y, width, opts, mousePosition)
  local self = setmetatable(UIElement.new(), Slider)
  opts = opts or {}

  self:setX(x)
  self:setY(y)
  self.width = width
  self.height = opts.height or 20

  self.value = opts.defaultValue or 0.5
  self.onChange = opts.onChange or function() end
  self.mousePosition = mousePosition

  -- Visuel
  self.trackColor = opts.trackColor or { 0.3, 0.3, 0.3, 1 }
  self.fillColor = opts.fillColor or { 1, 1, 1, 1 }
  self.knobRadius = opts.knobRadius or 12
  self.knobColor = opts.knobColor or { 1, 1, 1, 1 }

  self.isDragging = false
  self.animator = Animator:new(self)
  self.knobScale = 1

  return self
end

-- ─── Helpers ─────────────────────────────────────────────────────────────────

function Slider:getKnobX()
  return self.x - self.width / 2 + self.value * self.width
end

function Slider:isKnobHovered()
  local mx, my = self.mousePosition().x, self.mousePosition().y
  local kx = self:getKnobX()
  local ky = self.y
  local r = self.knobRadius
  return (mx - kx) ^ 2 + (my - ky) ^ 2 <= (r * 1.5) ^ 2
end

function Slider:isTrackHovered()
  local mx, my = self.mousePosition().x, self.mousePosition().y
  return mx > self.x - self.width / 2
    and mx < self.x + self.width / 2
    and my > self.y - self.knobRadius
    and my < self.y + self.knobRadius
end

-- ─── Update ──────────────────────────────────────────────────────────────────

function Slider:update(dt)
  self.animator:update(dt)

  local targetKnobScale = self:isKnobHovered() and 1.2 or 1
  self.knobScale = self:dampLerp(self.knobScale, targetKnobScale, 20, dt)

  if self.isDragging then
    if not love.mouse.isDown(1) then
      self.isDragging = false
    else
      local mx = self.mousePosition().x
      local raw = (mx - (self.x - self.width / 2)) / self.width
      local newValue = math.max(0, math.min(1, raw))
      if newValue ~= self.value then
        self.value = newValue
        self.onChange(self.value)
      end
    end
  end
end

-- ─── Events ──────────────────────────────────────────────────────────────────

function Slider:clickEvent()
  if self:isTrackHovered() then
    self.isDragging = true
    -- Mise à jour immédiate au click
    local mx = self.mousePosition().x
    self.value = math.max(0, math.min(1, (mx - (self.x - self.width / 2)) / self.width))
    self.onChange(self.value)
    return true
  end
  return false
end

-- ─── Draw ────────────────────────────────────────────────────────────────────

function Slider:draw()
  local trackH = self.height / 3
  local trackX = self.x - self.width / 2
  local trackY = self.y - trackH / 2
  local kx = self:getKnobX()
  local r = self.knobRadius * self.knobScale

  -- Track fond
  love.graphics.setColor(self.trackColor)
  love.graphics.rectangle("fill", trackX, trackY, self.width, trackH, trackH / 2)

  -- Track rempli
  love.graphics.setColor(self.fillColor)
  love.graphics.rectangle("fill", trackX, trackY, self.value * self.width, trackH, trackH / 2)

  -- Knob
  love.graphics.setColor(self.knobColor)
  love.graphics.circle("fill", kx, self.y, r)

  love.graphics.setColor(1, 1, 1, 1)
end

return Slider
