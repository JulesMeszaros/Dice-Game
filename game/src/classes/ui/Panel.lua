local Constants = require("src.utils.Constants")
local UIElement = require("src.classes.ui.UIElement")
local Animator = require("src.utils.Animator")
local Inputs = require("src.utils.scripts.Inputs")

local Panel = setmetatable({}, { __index = UIElement })
Panel.__index = Panel

function Panel:new(width, height, opts)
  local self = setmetatable(UIElement.new(), Panel)
  opts = opts or {}

  self.width = width or 200
  self.height = height or 200
  self.animator = Animator:new(self)

  -- Position centrée sur l'écran
  self:setX(Constants.VIRTUAL_GAME_WIDTH / 2)
  self:setY(Constants.VIRTUAL_GAME_HEIGHT / 2)

  -- Background
  self.bgColor = opts.bgColor or { 0.1, 0.1, 0.1, 0.95 }
  self.borderColor = opts.borderColor or { 1, 1, 1, 0.3 }
  self.borderWidth = opts.borderWidth or 2
  self.cornerRadius = opts.cornerRadius or 10

  -- Contenu
  self.elements = {} -- { type = "button"|"text", obj = ..., ox = ..., oy = ... }

  -- Canvas
  self.uiCanvas = love.graphics.newCanvas(self.width, self.height)

  -- Visibilité
  self.visible = true

  return self
end

-- ─── Ajout d'éléments ────────────────────────────────────────────────────────

-- ox, oy : offset depuis le centre du panel
function Panel:addButton(button, ox, oy)
  button:setX(self.x + ox)
  button:setY(self.y + oy)
  table.insert(self.elements, { type = "button", obj = button, ox = ox, oy = oy })
end

function Panel:addText(opts, ox, oy)
  -- opts : { text, font, color, maxWidth, centered }
  table.insert(self.elements, { type = "text", opts = opts, ox = ox, oy = oy })
end

-- ─── Affichage / masquage ────────────────────────────────────────────────────

function Panel:show()
  self.visible = true
end

function Panel:hide() end

-- ─── Update ──────────────────────────────────────────────────────────────────

function Panel:update(dt)
  if not self.visible then
    return
  end

  self.animator:update(dt)

  -- Update des boutons
  for _, el in next, self.elements do
    if el.type == "button" then
      el.obj:update(dt)
    end
  end

  self:updateCanvas()
end

-- ─── Canvas ──────────────────────────────────────────────────────────────────

function Panel:updateCanvas()
  local currentCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.uiCanvas)
  love.graphics.clear()

  -- Background arrondi
  love.graphics.setColor(self.bgColor)
  love.graphics.rectangle("fill", 0, 0, self.width, self.height, self.cornerRadius)

  -- Bordure
  love.graphics.setColor(self.borderColor)
  love.graphics.setLineWidth(self.borderWidth)
  love.graphics.rectangle("line", 0, 0, self.width, self.height, self.cornerRadius)

  -- Textes
  for _, el in next, self.elements do
    if el.type == "text" then
      local o = el.opts
      local tx = self.width / 2 + el.ox
      local ty = self.height / 2 + el.oy
      drawFormattedText(o.text, tx, ty, o.font, o.maxWidth, o.centered ~= false)
    end
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas(currentCanvas)
end

-- ─── Draw ─────────────────────────────────────────────────────────────────────

function Panel:draw()
  print(self.visible)
  if not self.visible then
    return
  end

  local cx = self.x
  local cy = self.y

  -- Panel
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.uiCanvas, cx, cy, 0, 1, 1, self.width / 2, self.height / 2)

  for _, el in next, self.elements do
    if el.type == "button" then
      love.graphics.setColor(1, 1, 1, 1)
      el.obj:draw()
    end
  end

  love.graphics.setColor(1, 1, 1, 1)
end

-- ─── Events ──────────────────────────────────────────────────────────────────

function Panel:clickEvent()
  if not self.visible then
    return
  end
  for _, el in next, self.elements do
    if el.type == "button" then
      el.obj:clickEvent()
    end
  end
end

function Panel:cleanup()
  if self.uiCanvas then
    self.uiCanvas:release()
    self.uiCanvas = nil
  end
  for _, el in next, self.elements do
    if el.type == "button" and el.obj.cleanup then
      el.obj:cleanup()
    end
  end
end

return Panel
