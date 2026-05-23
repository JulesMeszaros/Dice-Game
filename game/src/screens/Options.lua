local Fonts = require("src.utils.Fonts")
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

  --Options Audio
  local audioButton = Button:new(

    function()
      Options.audioOptions()
    end,
    "src/assets/sprites/ui/Audio Settings.png",
    630,
    250,
    660,
    100,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  optionPanel:addButton(audioButton)

  --Options Video
  local videoButton = Button:new(
    function()
      Options.videoOptions()
    end,
    "src/assets/sprites/ui/Video Settings.png",
    630,
    380,
    660,
    100,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  optionPanel:addButton(videoButton)

  --Options Game
  local gameOptions = Button:new(
    function()
      Options.gameOptions()
    end,
    "src/assets/sprites/ui/Game Settings.png",
    630,
    510,
    660,
    100,
    nil,
    function()
      return Inputs.getMouseInCanvas(0, 0)
    end
  )
  optionPanel:addButton(gameOptions)

  optionPanel:show()
end

Options.generalOptions = generalOptions

local function audioOptions()
  local optionPanel = Panel:new(1260, 800)
  --Label
  optionPanel:addImage(Sprites.AUDIO_LABEL, 630, 30, { cx = Sprites.AUDIO_LABEL:getWidth() / 2 })

  --Checkbox Mute
  optionPanel:addText(
    { color = { 1, 1, 1 }, font = Fonts.soraCredits, centered = false, text = "Mute Sounds" },
    250,
    200
  )
  optionPanel:addCheckbox({
    size = 80,
    defaultValue = G.sessionSettings.muteSounds,
    onChange = function(val)
      G.sessionSettings.muteSounds = val
      G.audio.mute = val
      G.saveSettings()
    end,
  }, 950, 230)

  --Slider FX
  optionPanel:addText(
    { color = { 1, 1, 1 }, font = Fonts.soraCredits, centered = false, text = "Audio FX level" },
    250,
    330
  )
  optionPanel:addSlider({
    width = 300,
    height = 50,
    defaultValue = G.sessionSettings.FXLevel,
    onChange = function(val)
      G.sessionSettings.FXLevel = val
      G.audio.sfxVolume = val
      G.saveSettings()
    end,
  }, 950, 360)

  --Bouton retour
  local backButton = Button:new(
    function()
      optionPanel:hide()
    end,
    "src/assets/sprites/ui/Retour.png",
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

  --todo
end

Options.audioOptions = audioOptions

local function videoOptions()
  local optionPanel = Panel:new(1260, 800)
  --Label
  optionPanel:addImage(Sprites.VIDEO_LABEL, 630, 30, { cx = Sprites.VIDEO_LABEL:getWidth() / 2 })

  --Bouton retour
  local backButton = Button:new(
    function()
      optionPanel:hide()
    end,
    "src/assets/sprites/ui/Retour.png",
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

  --Checkbox paralaxe
  optionPanel:addText(
    { color = { 1, 1, 1 }, font = Fonts.soraCredits, centered = false, text = "Screen Paralaxe" },
    250,
    200
  )
  optionPanel:addCheckbox({
    size = 80,
    defaultValue = G.sessionSettings.paralaxeEffect,
    onChange = function(val)
      G.sessionSettings.paralaxeEffect = val
      G.saveSettings()
    end,
  }, 950, 230)

  --Checkbox CRT
  optionPanel:addText({
    color = { 1, 1, 1 },
    font = Fonts.soraCredits,
    centered = false,
    text = "CRT Effect",
  }, 250, 350)

  optionPanel:addCheckbox({
    size = 80,
    defaultValue = G.sessionSettings.CRTEffect,
    onChange = function(val)
      G.sessionSettings.CRTEffect = val
      G.saveSettings()
    end,
  }, 950, 380)

  --Animated background CRT
  optionPanel:addText(
    { color = { 1, 1, 1 }, font = Fonts.soraCredits, centered = false, text = "Animated Backgroud" },
    250,
    500
  )
  optionPanel:addCheckbox({
    size = 80,
    defaultValue = G.sessionSettings.animateBG,
    onChange = function(val)
      G.sessionSettings.animateBG = val
      G.saveSettings()
    end,
  }, 950, 530)
  optionPanel:show()

  --todo
end
Options.videoOptions = videoOptions

local function gameOptions()
  local optionPanel = Panel:new(1260, 800)
  --Label
  optionPanel:addImage(Sprites.GAME_LABEL, 630, 30, { cx = Sprites.GAME_LABEL:getWidth() / 2 })
  --Bouton retour
  local backButton = Button:new(
    function()
      optionPanel:hide()
    end,
    "src/assets/sprites/ui/Retour.png",
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

  --todo
end
Options.gameOptions = gameOptions

return Options
