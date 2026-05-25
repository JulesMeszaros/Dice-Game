local InfoBubble = require("src.classes.ui.InfoBubble")
local Constants = require("game.src.utils.Constants")
local DiceFace = require("game.src.classes.ui.DiceFace")
local Facetypes = require("game.src.classes.FaceTypes")
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

  self.infoBubble = InfoBubble:new(self)
  self.infoBubble.overflowAllowed = 1000
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

  --Création de l'écran de dice stats
  self:createDiceStats()

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

function getTopDices(n)
  if not G.saveManager.data.stats.dices then
    return {}
  end
  n = n or 5
  local sorted = {}
  for id, count in pairs(G.saveManager.data.stats.dices) do
    table.insert(sorted, { id = id, count = count })
  end
  table.sort(sorted, function(a, b)
    return a.count > b.count
  end)
  local result = {}
  for i = 1, math.min(n, #sorted) do
    table.insert(result, sorted[i])
  end
  return result
end

function Stats:update(dt)
  --Update de la classe mère
  Panel.update(self, dt)

  self:getCurrentlyHoveredDice()
  if self.currentlyHoveredObject and not self.dragAndDroppedObject then
    --Info bubble (wip)
    self.infoBubble.x, self.infoBubble.y =
      self.currentlyHoveredObject.x + self.currentlyHoveredObject.absoluteX,
      self.currentlyHoveredObject.y + self.currentlyHoveredObject.absoluteY

    self.infoBubble:update(dt)
  end

  if self.category == 2 then
    self:updateDiceStats(dt)
  end
end

function Stats:updateCanvas()
  Panel.updateCanvas(self)
  local currentCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.uiCanvas)

  if self.category == 1 then
    self:generalStats()
  elseif self.category == 2 then
    self:drawDiceStats()
  elseif self.category == 3 then
  end

  love.graphics.setCanvas(currentCanvas)
end

function Stats:draw()
  Panel.draw(self)
  if self.currentlyHoveredObject and not self.dragAndDroppedObject then
    self.infoBubble:draw()
  end
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

--Dice stats

--Creation de l'écran
function Stats:createDiceStats()
  local topDices = getTopDices(5)

  self.faceObjects = {}
  self.uiFaces = {}
  self.positionTexts = {}
  self.triggerTexts = {}
  print("///")
  for i, dice in next, topDices do
    local fo = Facetypes[G.faceIds[tostring(dice["id"])]]:new(math.random(1, 6), 10)
    local df = DiceFace:new(nil, fo, (127 + 75) + ((i - 1) * 249), 550, 120, false, true, function()
      return Inputs.getMouseInCanvas(
        Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2,
        Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2
      )
    end, nil, Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2, Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2)

    --Creation de la position en Wavy
    local text = UI.Text.TextWavy:new(
      "#" .. tostring(i),
      (127 + 75) + ((i - 1) * 249),
      425,
      { centered = true, speed = 1, revealSpeed = 0, time = -0.1 * (i - 1) }
    )

    local textTriggers = UI.Text.TextWavy:new(
      tostring(dice["count"]) .. "x",
      (127 + 75) + ((i - 1) * 249),
      675,
      { centered = true, speed = 1, revealSpeed = 0, time = -0.1 * i, font = Fonts.soraMedium }
    )

    table.insert(self.faceObjects, fo)
    table.insert(self.uiFaces, df)
    table.insert(self.positionTexts, text)
    table.insert(self.triggerTexts, textTriggers)
  end
end

--Update de l'écran
function Stats:updateDiceStats(dt)
  for i, face in next, self.uiFaces do
    face:update(dt)
    self.positionTexts[i]:update(dt)
    self.triggerTexts[i]:update(dt)
  end
end
--Affichage de l'écran
function Stats:drawDiceStats()
  UI.Text.drawFormattedText("Most triggered dices", 700, 300, Fonts.soraCredits, 1000, true, { color = { 1, 1, 1, 1 } })

  for i, face in next, self.uiFaces do
    face:draw()
    self.positionTexts[i]:draw()
    self.triggerTexts[i]:draw()
  end
end

function Stats:changeCategory(category)
  if self.category == category then
    return
  end

  self.category = category

  print(self.category)
end

function Stats:getCurrentlyHoveredDice()
  self.previouslyHoveredFace = self.currentlyHoveredObject
  self.currentlyHoveredObject = nil

  for key, diceface in next, self.uiFaces do
    if diceface:isHovered() then
      self.currentlyHoveredObject = diceface
      break
    end
  end
end

return Stats
