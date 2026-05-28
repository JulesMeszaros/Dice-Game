local CiggieTypes = require("game.src.classes.CiggieTypes")
local CoffeeButton = require("game.src.classes.ui.CoffeeButton")
local Ciggie = require("game.src.classes.ui.Ciggie")
local Sticker = require("game.src.classes.ui.Sticker")
local StickerTypes = require("game.src.classes.StickerTypes")
local AnimationUtils = require("game.src.utils.scripts.Animations")
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

function Stats:new(mainmenu)
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

  self.run = G.game.dummyRun

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

function getTopDices(n)
  if not G.saveManager.data.stats.dices then
    return {}
  end
  n = n or 5
  local sorted = {}
  for id, count in pairs(G.saveManager.data.stats.dices) do
    if id ~= 1 then
      table.insert(sorted, { id = id, count = count })
    end
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

function Stats:getTopStat(stats)
  if not stats or not next(stats) then
    return nil, nil
  end
  local bestId, bestCount = nil, -math.huge
  for id, count in pairs(stats) do
    if count > bestCount then
      bestCount = count
      bestId = id
    end
  end
  return bestId, bestCount
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
  elseif self.category == 3 then
    self:updateObjectsStats(dt)
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
    self:drawObjectStats()
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

    df.oscillatingScale, df.oscillatingY, df.oscillatingAngle = true, true, true
    df.oscilScaleAmp, df.oscilYAmp, df.oscilAngleAmp = 0.05, 10, 0.1
    df.oscilScaleP, df.oscilYP, df.oscilAngleP = 5, 10, 12
    --df.oscilScale0, df.oscilYO, df.oscilAngleO = 3, 1, 0

    df.scaleX = 0
    df.scaleY = 0
    df.drawShadow = true
    self:animateDiceFaceAppear(df, 0.1 * (i - 1))

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

function Stats:resetDiceStats()
  self.faceObjects = {}
  self.uiFaces = {}
  self.positionTexts = {}
  self.triggerTexts = {}
end

--Update de l'écran
function Stats:updateDiceStats(dt)
  for i, face in next, self.uiFaces do
    face:update(dt)
    self.positionTexts[i]:update(dt)
    self.triggerTexts[i]:update(dt)
  end
end

--Affichage de l'écran de stats des dés
function Stats:drawDiceStats()
  UI.Text.drawFormattedText("Most triggered dices", 700, 300, Fonts.soraCredits, 1000, true, { color = { 1, 1, 1, 1 } })

  for i, face in next, self.uiFaces do
    face:draw()
    self.positionTexts[i]:draw()
    self.triggerTexts[i]:draw()
  end
end

--Ecran des objets

function Stats:createObjectStats()
  --TODO :
  --Oscillation des objets
  --Ombres
  --Info bulles

  self.objectTexts = {}
  --Creation des objets
  --Sticker
  local id, count = self:getTopStat(G.saveManager.data.stats.stickers)
  print(id, count)
  if id then
    local stickerTest = StickerTypes[G.stickerIds[tostring(id)]]:new()
    self.uiSticker = Sticker:new(stickerTest, 275, 525, 150, false, true, function()
      return Inputs.getMouseInCanvas(
        Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2,
        Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2
      )
    end, Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2, Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2)
    self.uiSticker.scaleX = 0
    self.uiSticker.scaleY = 0
    Stats:animateDiceFaceAppear(self.uiSticker, 0.1)

    local textTriggers = UI.Text.TextWavy:new(
      tostring(count) .. "x",
      275,
      675,
      { centered = true, speed = 1, revealSpeed = 0, time = -0.1, font = Fonts.soraMedium }
    )
    table.insert(self.objectTexts, textTriggers)

    local text =
      UI.Text.TextWavy:new("Sticker", 275, 390, { centered = true, speed = 1, revealSpeed = 0.3, time = -0.1 })
    table.insert(self.objectTexts, text)
  end
  --Ciggie
  local id, count = self:getTopStat(G.saveManager.data.stats.wands)
  if id then
    print(G.wandIds[tostring(id)])
    local ciggieTest = CiggieTypes[G.wandIds[tostring(id)]]:new()
    self.uiCiggie = Ciggie:new(ciggieTest, 700, 530, false, true, function()
      return Inputs.getMouseInCanvas(
        Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2,
        Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2
      )
    end, nil)
    self.uiCiggie.layer = 4
    self.uiCiggie.baseHorizontal = true
    self.uiCiggie.scaleX = 0
    self.uiCiggie.scaleY = 0
    self.uiCiggie.absoluteX, self.uiCiggie.absoluteY =
      Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2, Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2

    Stats:animateDiceFaceAppear(self.uiCiggie, 0.3)

    local textTriggers = UI.Text.TextWavy:new(
      tostring(count) .. "x",
      700,
      675,
      { centered = true, speed = 1, revealSpeed = 0, time = -0.3, font = Fonts.soraMedium }
    )
    table.insert(self.objectTexts, textTriggers)
  end

  --Coffee
  local id, count = self:getTopStat(G.saveManager.data.stats.coffees)
  if id then
    self.coffeeButton = CoffeeButton:new(960 + 330 / 2, 530, function()
      return Inputs.getMouseInCanvas(
        Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2,
        Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2
      )
    end, id, G.game.dummyRun)

    self.coffeeButton.absoluteX, self.coffeeButton.absoluteY =
      Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2, Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2

    self.coffeeButton.scale = 0
    self.coffeeButton.animator:addDelay(0.5)
    self.coffeeButton.animator:addGroup({
      {
        property = "scale",
        from = 0,
        targetValue = 1,
        duration = 0.4,
        easing = AnimationUtils.Easing.easeOutBack,
      },
    })

    local textTriggers = UI.Text.TextWavy:new(
      tostring(count) .. "x",
      960 + 330 / 2,
      675,
      { centered = true, speed = 1, revealSpeed = 0, time = -0.5, font = Fonts.soraMedium }
    )
    table.insert(self.objectTexts, textTriggers)
  end

  --Texts

  --Sticker

  local text =
    UI.Text.TextWavy:new("Magic Wand", 700, 390, { centered = true, speed = 1, revealSpeed = 0.3, time = -0.3 })
  table.insert(self.objectTexts, text)

  local text =
    UI.Text.TextWavy:new("Coffee", 960 + 330 / 2, 390, { centered = true, speed = 1, revealSpeed = 0.3, time = -0.5 })
  table.insert(self.objectTexts, text)
end

function Stats:resetObjectStats() end

function Stats:updateObjectsStats(dt)
  if self.uiSticker then
    self.uiSticker:update(dt)
  end
  if self.uiCiggie then
    self.uiCiggie:update(dt)
  end
  if self.coffeeButton then
    self.coffeeButton:update(dt)
  end
  for i, text in next, self.objectTexts do
    text:update(dt)
  end
end

function Stats:drawObjectStats()
  UI.Text.drawFormattedText(
    "Most bought & used Objects",
    700,
    300,
    Fonts.soraCredits,
    1000,
    true,
    { color = { 1, 1, 1, 1 } }
  )

  if self.uiSticker then
    self.uiSticker:draw()
  end
  if self.uiCiggie then
    self.uiCiggie:draw()
  end
  if self.coffeeButton then
    self.coffeeButton:draw()
  end

  for i, text in next, self.objectTexts do
    text:draw()
  end
end

--UTILS--
function Stats:changeCategory(category)
  if self.category == category then
    return
  end

  self.category = category

  if self.category == 2 then
    self:createDiceStats()
  else
    self:resetDiceStats()
  end

  if self.category == 3 then
    self:createObjectStats()
  else
    self:resetObjectStats()
  end

  print(self.category)
end

function Stats:getCurrentlyHoveredDice()
  self.previouslyHoveredFace = self.currentlyHoveredObject
  self.currentlyHoveredObject = nil

  if self.category == 2 then
    for key, diceface in next, self.uiFaces do
      if diceface:isHovered() then
        self.currentlyHoveredObject = diceface
        break
      end
    end
  elseif self.category == 3 then
    if self.uiCiggie:isHovered() then
      self.currentlyHoveredObject = self.uiCiggie
    elseif self.uiSticker:isHovered() then
      self.currentlyHoveredObject = self.uiSticker
    elseif self.coffeeButton:isHovered() then
      self.currentlyHoveredObject = self.coffeeButton
    end
  end
end

function Stats:getCurrentlyHoveredObject()
  self.currentlyHoveredObject = nil

  if self.uiCiggie:isHovered() then
    self.currentlyHoveredObject = self.uiCiggie
  elseif self.uiSticker:isHovered() then
    self.currentlyHoveredObject = self.uiSticker
  elseif self.coffeeButton:isHovered() then
    self.currentlyHoveredObject = self.coffeeButton
  end
end

function Stats:animateDiceFaceAppear(diceface, timeOffset)
  diceface.animator:addDelay(timeOffset)
  diceface.animator:addGroup({
    {
      property = "scaleX",
      from = 0,
      targetValue = 1,
      duration = 0.4,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "scaleY",
      from = 0,
      targetValue = 1,
      duration = 0.4,
      easing = AnimationUtils.Easing.easeOutBack,
    },
    {
      property = "rotation",
      from = 0.4,
      targetValue = 0,
      duration = 0.4,
      easing = AnimationUtils.Easing.easeOutBack,
    },
  })
end

return Stats
