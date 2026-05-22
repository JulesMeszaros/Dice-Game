local Button = require("src.classes.ui.Button")
local Sprites = require("src.utils.Sprites")
local Panel = require("src.classes.ui.Panel")
local Credits = {}

function Credits.show()
  local creditsPanel = Panel:new(1230, 750)
  creditsPanel:addImage(Sprites.CREDITS_LABEL, 630, 30, { cx = Sprites.OPTIONS_LABEL:getWidth() / 2 })
  --Bouton retour
  local backButton = Button:new(
    function()
      creditsPanel:hide()
    end,
    "src/assets/sprites/ui/Home Button.png",
    630,
    670,
    660,
    100,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  creditsPanel:addButton(backButton)

  creditsPanel:show()
end

return Credits
