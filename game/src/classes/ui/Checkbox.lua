local UIElement = require("src.classes.ui.UIElement")
local Animator = require("src.utils.Animator")

local Checkbox = setmetatable({}, { __index = UIElement })
Checkbox.__index = Checkbox

function Checkbox:new(x, y, opts, mousePosition)
  local self = setmetatable(UIElement.new(), Checkbox)
  opts = opts or {}

  self:setX(x)
  self:setY(y)
  self.size = opts.size or 60

  self.checked = opts.defaultValue or false
  self.onChange = opts.onChange or function() end
  self.mousePosition = mousePosition

  -- Visuel
  self.bgColor = opts.bgColor or { 0.2, 0.2, 0.2, 1 }
  self.checkColor = opts.checkColor or { 1, 1, 1, 1 }
  self.borderColor = opts.borderColor or { 1, 1, 1, 0.5 }
  self.label = opts.label
  self.font = opts.font or love.graphics.getFont()

  self.animator = Animator:new(self)
  self.checkScale = self.checked and 1 or 0

  return self
end

-- ─── Helpers ─────────────────────────────────────────────────────────────────

function Checkbox:isHovered()
  local mx, my = self.mousePosition().x, self.mousePosition().y
  local half = self.size / 2
  return mx > self.x - half and mx < self.x + half and my > self.y - half and my < self.y + half
end

-- ─── Update ──────────────────────────────────────────────────────────────────

function Checkbox:update(dt)
  self.animator:update(dt)
  local target = self.checked and 1 or 0
  self.checkScale = self:dampLerp(self.checkScale, target, 20, dt)
end

-- ─── Events ──────────────────────────────────────────────────────────────────

function Checkbox:clickEvent()
  if self:isHovered() then
    self.isBeingClicked = true
    return true
  end
  return false
end

function Checkbox:releaseEvent()
  if self.isBeingClicked and self:isHovered() then
    self.checked = not self.checked
    self.onChange(self.checked)
  end
  self.isBeingClicked = false
end

-- ─── Draw ────────────────────────────────────────────────────────────────────

function Checkbox:draw()
  local half = self.size / 2

  -- Background
  love.graphics.setColor(self.bgColor)
  love.graphics.rectangle("fill", self.x - half, self.y - half, self.size, self.size, 5)

  -- Bordure
  love.graphics.setColor(self.borderColor)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", self.x - half, self.y - half, self.size, self.size, 5)

  -- Checkmark avec scale animé
  if self.checkScale > 0.01 then
    local s = self.checkScale
    love.graphics.setColor(self.checkColor[1], self.checkColor[2], self.checkColor[3], s)
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(s, s)
    love.graphics.setLineWidth(3)
    love.graphics.line(-half * 0.5, 0, -half * 0.1, half * 0.4, half * 0.5, -half * 0.4)
    love.graphics.pop()
  end

  -- Label
  if self.label then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.print(self.label, self.x + half + 10, self.y - self.font:getHeight() / 2)
  end

  love.graphics.setColor(1, 1, 1, 1)
end

return Checkbox
