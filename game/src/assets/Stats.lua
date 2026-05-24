local Constants = require("game.src.utils.Constants")
local UI = require("src.utils.scripts.UI")
local Panel = require("game.src.classes.ui.Panel")
local Fonts = require("game.src.utils.Fonts")
local Sprites = require("game.src.utils.Sprites")
local Button = require("game.src.classes.ui.Button")
local Inputs = require("game.src.utils.scripts.Inputs")

local Stats = setmetatable({}, { __index = Panel })
Stats.__index = Stats

function Stats:new()
  local self = setmetatable(Panel:new(1400, 1000), Stats)

  --[[
	Catégories possibles = 
	1 : Stats générales
	2 : Dés
	3 : Cafés, Wands, Stickers
	--]]
  self.category = 1

  --Bouton retour
  local backButton = Button:new(
    function()
      self:hide()
    end,
    "src/assets/sprites/ui/Home Button.png",
    700,
    925,
    660,
    100,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  self:addButton(backButton)

  --Label
  self:addImage(Sprites.STATS_LABEL, 700, 95, { cx = 250, cy = 65 })

  --Categories buttons
  --General
  local generalButton = Button:new(
    function()
      self:changeCategory(1)
    end,
    "src/assets/sprites/ui/General Stats.png",
    275,
    230,
    350,
    90,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  self:addButton(generalButton)

  --Dices Stats
  local dicesButton = Button:new(
    function()
      self:changeCategory(2)
    end,
    "src/assets/sprites/ui/Dices Stats.png",
    700,
    230,
    350,
    90,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  self:addButton(dicesButton)

  --Objects Stats
  local dicesButton = Button:new(
    function()
      self:changeCategory(3)
    end,
    "src/assets/sprites/ui/Objects Stats.png",
    1125,
    230,
    350,
    90,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  self:addButton(dicesButton)

  self:show()

  return self
end

local function getBestFigure()
  if not G.saveManager.data.stats.figures or #G.saveManager.data.stats.figures == 0 then
    return "None"
  end
  local bestIndex, bestValue = nil, -math.huge
  for index, value in pairs(G.saveManager.data.stats.figures) do
    if value > bestValue then
      bestValue = value
      bestIndex = index
    end
  end
  return Constants.FIGURES_LABELS[bestIndex]
end

function Stats:update(dt)
  --Update de la classe mère
  Panel.update(self, dt)
end

function Stats:updateCanvas()
  Panel.updateCanvas(self)
  local currentCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.uiCanvas)

  if self.category == 1 then
    self:generalStats()
  elseif self.category == 2 then
  elseif self.category == 3 then
  end

  love.graphics.setCanvas(currentCanvas)
end

--Draw General stats
function Stats:generalStats()
  --Total Runs
  UI.Text.drawFormattedText("Runs played :", 700, 300, Fonts.soraCredits, 1000, true, { color = { 1, 1, 1, 1 } })

  UI.Text.drawFormattedText(
    tostring(G.saveManager.data.stats.runs),
    700,
    350,
    Fonts.soraCredits,
    1000,
    true,
    { color = { 1, 1, 1, 1 } }
  )
  --Wins
  UI.Text.drawFormattedText(tostring("Runs won :"), 700, 425, Fonts.soraCredits, 1000, true, { color = { 1, 1, 1, 1 } })

  UI.Text.drawFormattedText(
    tostring(G.saveManager.data.stats.wins),
    700,
    475,
    Fonts.soraCredits,
    1000,
    true,
    { color = { 1, 1, 1, 1 } }
  )
  --Best Hand
  UI.Text.drawFormattedText(
    tostring("Highest hand :"),
    700,
    550,
    Fonts.soraCredits,
    1000,
    true,
    { color = { 1, 1, 1, 1 } }
  )

  UI.Text.drawFormattedText(
    tostring(G.saveManager.data.stats.bestHand or 0),
    700,
    600,
    Fonts.soraCredits,
    1000,
    true,
    { color = { 1, 1, 1, 1 } }
  )
  --Most played Figure
  UI.Text.drawFormattedText(
    tostring("Most played figure :"),
    700,
    675,
    Fonts.soraCredits,
    1000,
    true,
    { color = { 1, 1, 1, 1 } }
  )

  UI.Text.drawFormattedText(
    tostring(getBestFigure()),
    700,
    725,
    Fonts.soraCredits,
    1000,
    true,
    { color = { 1, 1, 1, 1 } }
  )
end

function Stats:changeCategory(category)
  if self.category == category then
    return
  end

  self.category = category

  print(self.category)
end

return Stats
