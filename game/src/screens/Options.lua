local Inputs = require("src.utils.scripts.Inputs")
local Button = require("src.classes.ui.Button")
local Sprites = require("src.utils.Sprites")
local Panel = require("src.classes.ui.Panel")

local Options = {}

local function generalOptions()
  local optionPanel = Panel:new(1260, 800)
  --Label
  optionPanel:addImage(Sprites.OPTIONS_LABEL, 630, 30, { cx = Sprites.OPTIONS_LABEL:getWidth() / 2 })
  --Bouton retour
  local backButton = Button:new(
    function()
      optionPanel:hide()
    end,
    "src/assets/sprites/ui/Home Button.png",
    630,
    720,
    660,
    100,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  optionPanel:addButton(backButton)
  optionPanel:show()
end

Options.generalOptions = generalOptions

local function audioOptions()
  --todo
end

local function videoOptions()
  --todo
end

return Options
