local CiggieTypes = require("src.classes.CiggieTypes")
local CoffeeButton = require("src.classes.ui.CoffeeButton")
local Ciggie = require("src.classes.ui.Ciggie")
local Sticker = require("src.classes.ui.Sticker")
local StickerTypes = require("src.classes.StickerTypes")
local AnimationUtils = require("src.utils.scripts.Animations")
local InfoBubble = require("src.classes.ui.InfoBubble")
local Constants = require("src.utils.Constants")
local DiceFace = require("src.classes.ui.DiceFace")
local Facetypes = require("src.classes.FaceTypes")
local UI = require("src.utils.scripts.UI")
local Panel = require("src.classes.ui.Panel")
local Fonts = require("src.utils.Fonts")
local Sprites = require("src.utils.Sprites")
local Button = require("src.classes.ui.Button")
local Inputs = require("src.utils.scripts.Inputs")

function get_sorted_keys(dict)
  local keys = {}

  -- extraction des clés
  for k in pairs(dict) do
    keys[#keys + 1] = k
  end

  -- tri numérique (important si les clés sont des strings d'IDs)
  table.sort(keys, function(a, b)
    return tonumber(a) < tonumber(b)
  end)

  return keys
end

function slice(t, i, j)
  local result = {}

  i = i or 1
  j = j or #t

  for k = i, j do
    result[#result + 1] = t[k]
  end

  return result
end

local Collection = setmetatable({}, { __index = Panel })
Collection.__index = Collection

function Collection:new(mainmenu)
  local self = setmetatable(Panel:new(1600, 1000), Collection)

  self.infoBubble = InfoBubble:new(self)
  self.infoBubble.overflowAllowed = 1000

  self.run = G.game.dummyRun
  self.pageNumber = 1

  self.dicePerRow = 8
  self.dicePerCol = 3
  --Récupération des ID des dés dans l'ordre
  self.sortedIDs = get_sorted_keys(G.faceIds)
  self.nPages = math.ceil(#self.sortedIDs / (self.dicePerRow * self.dicePerCol))
  print(self.nPages)
  --Récupération des id des dés

  self.pageNumberText = love.graphics.newText(Fonts.soraCredits, tostring(self.pageNumber) .. "/" .. self.nPages)
  --Ajout des elements d'UI
  self:addImage(Sprites.COLLECTION_LABEL, 800, 95, { cx = 250, cy = 65 })

  --Bouton retour
  local backButton = Button:new(
    function()
      self:hide()
    end,
    "src/assets/sprites/ui/Home Button.png",
    800,
    925,
    660,
    100,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )

  --Bouton precedent
  local previousButton = Button:new(
    function()
      self:changePage(-1)
    end,
    "src/assets/sprites/ui/Arrow Button L.png",
    800 - 200,
    800,
    106,
    116,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )

  --Bouton precedent
  local nextButton = Button:new(
    function()
      self:changePage(1)
    end,
    "src/assets/sprites/ui/Arrow Button.png",
    800 + 200,
    800,
    106,
    116,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )

  self:addButton(backButton)
  self:addButton(nextButton)
  self:addButton(previousButton)

  --Init des dés à afficher
  self:initDices(1)

  self:show()
  return self
end

function Collection:draw()
  Panel.draw(self)
  if self.currentlyHoveredObject and not self.dragAndDroppedObject then
    self.infoBubble:draw()
  end
end

function Collection:update(dt)
  --Update de la classe mère
  Panel.update(self, dt)

  for i, df in next, self.displayedDices do
    df:update(dt)
  end
end

function Collection:updateCanvas()
  Panel.updateCanvas(self)

  local currentCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.uiCanvas)

  --Numero de page
  love.graphics.draw(
    self.pageNumberText,
    800,
    800,
    0,
    1,
    1,
    self.pageNumberText:getWidth() / 2,
    self.pageNumberText:getHeight() / 2
  )

  --Dessin des dés
  for i, df in next, self.displayedDices do
    df:draw()
  end

  love.graphics.setCanvas(currentCanvas)
end

function Collection:changePage(i)
  self.pageNumber = self.pageNumber + i
  if self.pageNumber > self.nPages then
    self.pageNumber = 1
  end
  if self.pageNumber < 1 then
    self.pageNumber = self.nPages
  end
  self.pageNumberText = love.graphics.newText(Fonts.soraCredits, tostring(self.pageNumber) .. "/" .. self.nPages)
  self:initDices(self.pageNumber)
end

function Collection:initDices(p)
  local page = p or 1
  local xPos = UI.spaceBetween(1300, self.dicePerRow, 800)
  local yPos = UI.spaceBetween(360, self.dicePerCol, 500)

  local idsToDisplay = slice(
    self.sortedIDs,
    1 + (page - 1) * self.dicePerCol * self.dicePerRow,
    1 + page * self.dicePerCol * self.dicePerRow
  )
  local i = 1

  self.displayedDices = {}

  --Fonction locale pour calculer le décalage en arc de cercle
  local function yOffset(x)
    return math.sin(x / 500) * 70
  end

  local function aOffset(x)
    return -math.cos(x / 500) * 0.2
  end

  for __, y in next, yPos do
    for _, x in next, xPos do
      local fo = Facetypes[G.faceIds[idsToDisplay[i]]]:new(1, 10)
      local df = DiceFace:new(nil, fo, x, y - yOffset(x), 120, false, true, function()
        return Inputs.getMouseInCanvas(
          Constants.VIRTUAL_GAME_WIDTH / 2 - self.width / 2,
          Constants.VIRTUAL_GAME_HEIGHT / 2 - self.height / 2
        )
      end, nil, 0, 0)

      df.drawShadow = true

      df.oscillatingScale, df.oscillatingY, df.oscillatingAngle = true, false, false
      df.oscilScaleAmp, df.oscilYAmp, df.oscilAngleAmp = 0.05, 3, 0.01
      df.oscilScaleP, df.oscilYP, df.oscilAngleP = 30, 40, 45

      df.baseRotation = aOffset(x)

      table.insert(self.displayedDices, df)
      i = i + 1
      --On stop si jamais on a plus de dé à afficher
      if not idsToDisplay[i] then
        return
      end
    end
  end
end

return Collection
