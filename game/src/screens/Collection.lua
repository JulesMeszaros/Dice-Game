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

local Collection = setmetatable({}, { __index = Panel })
Collection.__index = Collection

function Collection:new(mainmenu)
  local self = setmetatable(Panel:new(1600, 1000), Collection)

  self.infoBubble = InfoBubble:new(self)
  self.infoBubble.overflowAllowed = 1000

  self.run = G.game.dummyRun

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
  self:addButton(backButton)

  self:show()

  return self
end

return Collection
