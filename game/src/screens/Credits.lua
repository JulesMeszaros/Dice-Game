local Fonts = require("src.utils.Fonts")
local Button = require("src.classes.ui.Button")
local Sprites = require("src.utils.Sprites")
local Panel = require("src.classes.ui.Panel")
local Credits = {}

function Credits.show()
  local creditsPanel = Panel:new(1230, 1000)
  --Label
  creditsPanel:addImage(Sprites.CREDITS_LABEL, 630, 30, { cx = Sprites.OPTIONS_LABEL:getWidth() / 2 })
  --Bouton retour
  local backButton = Button:new(
    function()
      creditsPanel:hide()
    end,
    "src/assets/sprites/ui/Home Button.png",
    630,
    920,
    660,
    100,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  creditsPanel:addButton(backButton)

  local creditText = [[
      Development
      **n8scape** — Programming, Game Design, Audio FX & Music
      ++M1KU42O++ — Art, Game Design

     Font : Sora
    Copyright 2019 The Sora Project Authors
    github.com/sora-xor/sora-font
    Licensed under the SIL Open Font License 1.1
    openfontlicense.org

      Engine
      LÖVE ((2D)) — love2d.org
    ]]

  creditsPanel:addText({
    color = { 1, 1, 1, 1 },
    text = creditText,
    maxWidth = 1100,
    centered = true,
    font = Fonts.soraCredits,
  }, 615, 170)

  creditsPanel:show()
end

return Credits
