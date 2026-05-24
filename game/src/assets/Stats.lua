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

function Stats:changeCategory(category)
  if self.category == category then
    return
  end

  self.category = category

  print(self.category)
end

return Stats
