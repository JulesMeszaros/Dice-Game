local UI = require("src.utils.scripts.UI")
local Slider = require("src.classes.ui.Slider")
local Checkbox = require("src.classes.ui.Checkbox")
local Sprites = require("src.utils.Sprites")
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

  self.x = Constants.VIRTUAL_GAME_WIDTH / 2
  if #G.game.panelQueue == 0 then
    self.y = Constants.VIRTUAL_GAME_HEIGHT + self.height

    self.animator:add("y", self.y, Constants.VIRTUAL_GAME_HEIGHT / 2, 0.1)
  else
    self.y = Constants.VIRTUAL_GAME_HEIGHT / 2
  end
  -- Background
  self.bgColor = opts.bgColor or { 0.1, 0.1, 0.1, 1 }
  self.borderColor = opts.borderColor or { 1, 1, 1, 0.3 }
  self.borderWidth = opts.borderWidth or 2
  self.cornerRadius = opts.cornerRadius or 10

  self.baseSprite = Sprites.PANEL_BG
  self.gridDim = 70

  self.quads = {
    love.graphics.newQuad(0, 0, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Coin superieur gauche
    love.graphics.newQuad(self.gridDim * 2, 0, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Coin superieur droit
    love.graphics.newQuad(0, self.gridDim * 2, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Coin inferieur gauche
    love.graphics.newQuad(
      self.gridDim * 2,
      self.gridDim * 2,
      self.gridDim,
      self.gridDim,
      self.baseSprite:getDimensions()
    ), --Coin inferieur droit
    love.graphics.newQuad(self.gridDim, 0, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Bordure haute
    love.graphics.newQuad(self.gridDim * 2, self.gridDim, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Bordure droite
    love.graphics.newQuad(0, self.gridDim, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Bordure gauche
    love.graphics.newQuad(self.gridDim, self.gridDim * 2, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Bordure basse
    love.graphics.newQuad(self.gridDim, self.gridDim, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Centre
  }

  --Calcul de la taille/ratio des sprites à afficher
  self.hr = (self.height - 2 * self.gridDim) / self.gridDim --ratio de la taille pour les sprites de coté
  self.wr = (self.width - 2 * self.gridDim) / self.gridDim --ratio de la taille pour les sprites superieurs et inferieurs

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
function Panel:addButton(button)
  button.mousePosition = function()
    return Inputs.getMouseInCanvas(
      Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2,
      Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2
    )
  end
  table.insert(self.elements, { type = "button", obj = button })
end

function Panel:addText(opts, ox, oy)
  -- opts : { text, font, color, maxWidth, centered }
  table.insert(self.elements, { type = "text", opts = opts, ox = ox, oy = oy })
end

function Panel:addImage(sprite, x, y, opts)
  table.insert(self.elements, { type = "image", sprite = sprite, opts = opts, ox = x, oy = y })
end

function Panel:addSlider(opts, x, y)
  local slider = Slider:new(x, y, opts.width or 50, opts, function()
    return Inputs.getMouseInCanvas(
      Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2,
      Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2
    )
  end)
  table.insert(self.elements, { type = "slider", opts = opts, obj = slider })
end

function Panel:addCheckbox(opts, x, y)
  local checkbox = Checkbox:new(x, y, opts, function()
    return Inputs.getMouseInCanvas(
      Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2,
      Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2
    )
  end)
  table.insert(self.elements, { type = "checkbox", opts = opts, obj = checkbox })
end

-- ─── Affichage / masquage ────────────────────────────────────────────────────

function Panel:show()
  table.insert(G.game.panelQueue, 1, self)
end

function Panel:hide()
  table.remove(G.game.panelQueue, 1)
end

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
    if el.type == "checkbox" then
      el.obj:update(dt)
    end

    if el.type == "slider" then
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

  self:drawBG()

  -- Textes
  for _, el in next, self.elements do
    if el.type == "text" then
      local o = el.opts
      local tx = el.ox
      local ty = el.oy
      UI.Text.drawFormattedText(o.text, tx, ty, o.font, o.maxWidth, o.centered ~= false, { color = o.color })
    end

    if el.type == "image" then
      local o = el.opts or {}
      love.graphics.draw(el.sprite, el.ox, el.oy, o.r or 0, o.rx or 1, o.ry or 1, o.cx or 0, o.cy or 0)
    end
    if el.type == "button" then
      love.graphics.setColor(1, 1, 1, 1)
      el.obj:draw()
    end
    if el.type == "checkbox" then
      el.obj:draw()
    end
    if el.type == "slider" then
      el.obj:draw()
    end
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas(currentCanvas)
end

-- ─── Draw ─────────────────────────────────────────────────────────────────────

function Panel:draw()
  if not self.visible then
    return
  end

  local cx = self.x
  local cy = self.y

  -- Panel
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.uiCanvas, cx, cy, 0, 1, 1, self.width / 2, self.height / 2)

  for _, el in next, self.elements do
  end

  love.graphics.setColor(1, 1, 1, 1)
end

-- ─── Events ──────────────────────────────────────────────────────────────────

function Panel:mousepressed(vx, vy, button, istouch, presses)
  if not self.visible then
    return
  end
  for _, el in next, self.elements do
    if el.type == "button" then
      el.obj:clickEvent()
    elseif el.type == "checkbox" then
      el.obj:clickEvent()
    elseif el.type == "slider" then
      el.obj:clickEvent()
    end
  end
end

function Panel:mousereleased(vx, vy, button, istouch, presses)
  if not self.visible then
    return
  end
  for _, el in next, self.elements do
    if el.type == "button" then
      local wasReleased = el.obj:releaseEvent()
      if wasReleased then --Si le click a été complété
        el.obj:getCallback()()
      end
    elseif el.type == "checkbox" then
      el.obj:releaseEvent()
    elseif el.type == "slider" then
      -- le slider gère son état dans update
    end
  end
end

function Panel:mousemoved(vx, vy, dx, dy)
  if not self.visible then
    return
  end
  -- rien pour le moment, le slider gère son drag dans update
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

function Panel:drawBG()
  --Dessin du background
  --	--On dessine les angles
  love.graphics.draw(self.baseSprite, self.quads[1], 0, 0)
  love.graphics.draw(self.baseSprite, self.quads[2], self.uiCanvas:getWidth() - self.gridDim, 0)
  love.graphics.draw(self.baseSprite, self.quads[3], 0, self.uiCanvas:getHeight() - self.gridDim)
  love.graphics.draw(
    self.baseSprite,
    self.quads[4],
    self.uiCanvas:getWidth() - self.gridDim,
    self.uiCanvas:getHeight() - self.gridDim
  )

  --On dessine les cotés
  love.graphics.draw(self.baseSprite, self.quads[6], self.width - self.gridDim, self.gridDim, 0, 1, self.hr)
  love.graphics.draw(self.baseSprite, self.quads[7], 0, self.gridDim, 0, 1, self.hr)

  love.graphics.draw(self.baseSprite, self.quads[5], self.gridDim, 0, 0, self.wr, 1)
  love.graphics.draw(self.baseSprite, self.quads[8], self.gridDim, self.height - self.gridDim, 0, self.wr, 1)

  love.graphics.draw(self.baseSprite, self.quads[9], self.gridDim, self.gridDim, 0, self.wr, self.hr)
end

return Panel
