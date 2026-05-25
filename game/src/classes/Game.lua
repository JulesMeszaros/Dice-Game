local Fonts = require("src.utils.Fonts")
local Panel = require("src.classes.ui.Panel")
local Lion = require("src.classes.ui.Lion")
local CharacterCreation = require("src.screens.CharacterCreation")
local Run = require("src.classes.Run")
local MainMenu = require("src.screens.MainMenu")

--Utils
local GenerateRandom = require("src.utils.scripts.GenerateRandom")
local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local Shaders = require("src.utils.Shaders")
local Animations = require("src.utils.scripts.Animations")
--Dice Face Types
local DiceObject = require("src.classes.DiceObject")
local FaceTypes = require("src.classes.FaceTypes")

local Game = {}
Game.__index = Game

--Game dimmensions
local virtualWidth, virtualHeight = Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT

local gameCanvas = love.graphics.newCanvas(virtualWidth, virtualHeight)
--gameCanvas:setFilter("nearest", "nearest")

function Game:start()
  local self = setmetatable({}, Game)

  --Panel actif et queue de panels
  self.panelQueue = {}

  --New dice objects
  self.diceObjects = diceObjects

  self.currentScreen = Constants.PAGES.GAME
  self.run = nil

  self.gameCanvas = gameCanvas
  self.backgroundCanvas = love.graphics.newCanvas(self.gameCanvas:getWidth(), self.gameCanvas:getHeight())

  --Create a main menu
  --Si la save data ne contient pas de personnage à l'interieur, on réoriente dans un premier temps
  --Vers la création de personnage.
  self.mainMenu = MainMenu:new()

  if not G.saveManager.data.profile then
    self:goToCharacterCreation()
  else
    self.currentScreen = Constants.PAGES.MAIN_MENU
    G.playerName = G.saveManager.data.profile.name
    G.playerLion = Lion:new()
    G.playerLion:createFromIndexes(G.saveManager.data.profile.avatar)
  end

  self.dummyRun = self:createDummyRun()

  G.game = self

  return self
end

function Game:update(dt)
  if #self.panelQueue >= 1 then
    self.panelQueue[1]:update(dt)
  else
    if self.currentScreen == Constants.PAGES.MAIN_MENU then
      self.mainMenu:update(dt)
    elseif self.currentScreen == Constants.PAGES.GAME then
      self.run:update(dt)
    elseif self.currentScreen == Constants.PAGES.CHARACTER_CREATION then
      self.characterCreation:update(dt)
    end
  end

  --damped offset
  G.ox = Animations.dampLerp(G.ox, G.rx + G.waveX, 1.5, dt)
  G.oy = Animations.dampLerp(G.oy, G.ry + G.waveY, 1.5, dt) / 1.2

  self:updateCanvas(dt)
end
function Game:updateCanvas(dt)
  love.graphics.setCanvas(self.gameCanvas)
  love.graphics.clear()
  self:drawBackground()
  --Rendu du jeu dans le game canvas--
  if self.currentScreen == Constants.PAGES.MAIN_MENU then
    self.mainMenu:draw()
  elseif self.currentScreen == Constants.PAGES.GAME then
    self.run:draw(dt)
  elseif self.currentScreen == Constants.PAGES.CHARACTER_CREATION then
    self.characterCreation:draw()
  end

  if #self.panelQueue >= 1 then
    self.panelQueue[1]:updateCanvas()
    self.panelQueue[1]:draw()
  end

  love.graphics.setCanvas()
end
function Game:draw()
  --Affichage du jeu--
  -- Calcule le scale pour garder le ratio
  local screenWidth, screenHeight = love.graphics.getDimensions()
  local scale = math.min(screenWidth / virtualWidth, screenHeight / virtualHeight)

  local scaledWidth = virtualWidth * scale
  local scaledHeight = virtualHeight * scale

  local offsetX = (screenWidth - scaledWidth) / 2 --+ (G.ox*30)
  local offsetY = (screenHeight - scaledHeight) / 2 --+ (G.oy*30)

  -- Draw the game canvas using premultiplied alpha to prevent black halos around sprites
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.draw(self.gameCanvas, offsetX, offsetY, 0, scale, scale)
  -- Restore default blend mode (alpha blending)
  love.graphics.setBlendMode("alpha", "alphamultiply")
end

--==GAME FUNCTION==--

function Game:startNewRun(seedText, tutorial)
  -- Cleanup existing run if exists
  if G.saveManager.data.stats.runs then
    G.saveManager.data.stats.runs = G.saveManager.data.stats.runs + 1
  else
    G.saveManager.data.stats.runs = 1
  end
  G.saveManager:save()

  -- Cleanup main menu
  if self.mainMenu then
    self.mainMenu:cleanup()
    self.mainMenu = nil
  end

  --Creation de la seed
  if seedText and seedText ~= "" then
    local seed = GenerateRandom.stringToSeed(seedText)
    G.seedText = seedText
    G.seed = seed
    --On reset les random generator
    G.rngDices = love.math.newRandomGenerator(seed)
    G.rngShop = love.math.newRandomGenerator(seed)
    G.rngEnemies = love.math.newRandomGenerator(seed)
    G.rngGeneral = love.math.newRandomGenerator(seed)
  else
    local rndText = GenerateRandom.randomSeedText()
    local seed = GenerateRandom.stringToSeed(rndText)

    G.seed = seed
    G.seedText = rndText
    --On reset les random generator
    G.rngDices = love.math.newRandomGenerator(seed)
    G.rngShop = love.math.newRandomGenerator(seed)
    G.rngEnemies = love.math.newRandomGenerator(seed)
    G.rngGeneral = love.math.newRandomGenerator(seed)
  end

  local diceObjects = {} --liste des 6 dés blancs

  for i = 1, 5 do
    local fs = {}
    for j = 1, 6 do
      local f = FaceTypes.WhiteDice:new(j, 10)
      table.insert(fs, f)
    end
    table.insert(diceObjects, DiceObject:new(fs))
  end

  self.diceObjects = diceObjects

  self.currentScreen = Constants.PAGES.GAME
  self.run = Run:new(diceObjects, self.gameCanvas, self, self.diceObjects, tutorial)

  G.currentRun = self.run
end

--==INPUTS FUNCTIONS==--

function Game:keypressed(key)
  if key == "m" then
    local panel = Panel:new(500, 500)
  end
  if key == "k" then
    if #self.panelQueue >= 1 then
      self.panelQueue[1]:hide()
    end
  end
  if self.currentScreen == Constants.PAGES.MAIN_MENU then
    self.mainMenu:keypressed(key)
  elseif self.currentScreen == Constants.PAGES.GAME then
    self.run:keypressed(key)
  elseif self.currentScreen == Constants.PAGES.CHARACTER_CREATION then
    self.characterCreation:keypressed(key)
  end
end

function Game:textinput(t)
  if self.currentScreen == Constants.PAGES.MAIN_MENU then
    self.mainMenu:textinput(t)
  elseif self.currentScreen == Constants.PAGES.GAME then
  elseif self.currentScreen == Constants.PAGES.CHARACTER_CREATION then
    self.characterCreation:textinput(t)
  end
end

function Game:mousepressed(x, y, button, istouch, presses)
  local vx, vy = Inputs.getVirtualMousePosition()

  if #self.panelQueue >= 1 then
    self.panelQueue[1]:mousepressed(x, y, button, istouch, presses)
    return
  end

  if self.currentScreen == Constants.PAGES.MAIN_MENU then
    self.mainMenu:mousepressed(vx, vy, button, istouch, presses)
  elseif self.currentScreen == Constants.PAGES.GAME then
    self.run:mousepressed(vx, vy, button, istouch, presses)
  elseif self.currentScreen == Constants.PAGES.CHARACTER_CREATION then
    self.characterCreation:mousepressed(vx, vy, button, istouch, presses)
  end
end

function Game:mousereleased(vx, vy, button, istouch, presses)
  local vx, vy = Inputs.getVirtualMousePosition()

  if #self.panelQueue >= 1 then
    self.panelQueue[1]:mousereleased(vx, vy, button, istouch, presses)
    return
  end

  if self.currentScreen == Constants.PAGES.MAIN_MENU then
    self.mainMenu:mousereleased(vx, vy, button, istouch, presses)
  elseif self.currentScreen == Constants.PAGES.GAME then
    self.run:mousereleased(vx, vy, button, istouch, presses)
  elseif self.currentScreen == Constants.PAGES.CHARACTER_CREATION then
    self.characterCreation:mousereleased(vx, vy, button, istouch, presses)
  end
end

function Game:mousemoved(x, y, dx, dy)
  local vx, vy = Inputs.getVirtualMousePosition()
  local scale = Inputs.getCanvasScale()
  local vdx, vdy = dx / scale, dy / scale

  if #self.panelQueue >= 1 then
    self.panelQueue[1]:mousemoved(x, y, dx, dy)
    return
  end

  if self.currentScreen == Constants.PAGES.MAIN_MENU then
    self.mainMenu:mousemoved(vx, vy, vdx, vdy)
  elseif self.currentScreen == Constants.PAGES.GAME then
    self.run:mousemoved(vx, vy, vdx, vdy)
  elseif self.currentScreen == Constants.PAGES.CHARACTER_CREATION then
    self.characterCreation:mousemoved(vx, vy, vdx, vdy)
  end
end

function Game:drawBackground()
  local currentCanvas = love.graphics.getCanvas()
  -- Draw background to canvas with shader
  love.graphics.setCanvas(self.backgroundCanvas)
  love.graphics.clear()
  love.graphics.clear(G.backgroundR, G.backgroundG, G.backgroundB)
  love.graphics.setColor(G.backgroundR, G.backgroundG, G.backgroundB)
  love.graphics.rectangle("fill", 0, 0, self.gameCanvas:getWidth(), self.gameCanvas:getHeight())

  local bgtimer = love.timer.getTime()
  if G.sessionSettings.animateBG == false then
    bgtimer = 0
  end
  -- Set main canvas and draw background with shader
  love.graphics.setCanvas(currentCanvas)
  love.graphics.setShader(Shaders.diagonalCircles)
  Shaders.diagonalCircles:send("time", bgtimer)
  Shaders.diagonalCircles:send("base_size", 0.05)
  Shaders.diagonalCircles:send("amplitude", 0.03)
  Shaders.diagonalCircles:send("spacing", 0.15)
  Shaders.diagonalCircles:send("speed", 0.8)
  Shaders.diagonalCircles:send("waveScale", 5.0)
  Shaders.diagonalCircles:send("moveSpeed", 0.03)
  if G.sessionSettings.animateBG == true then
    Shaders.diagonalCircles:send("darkness", 0.3)
  else
    Shaders.diagonalCircles:send("darkness", 0.0)
  end
  love.graphics.draw(self.backgroundCanvas, 0, 0)
  love.graphics.setShader()
  -- Restore default blend mode
  love.graphics.setBlendMode("alpha", "alphamultiply")
  love.graphics.setColor(1, 1, 1)
end

function Game:goToCharacterCreation()
  self.characterCreation = CharacterCreation:new()
  self.currentScreen = Constants.PAGES.CHARACTER_CREATION
end

function Game:cleanup() end

function Game:createDummyRun()
  local run = Run:new({}, nil, self, {}, nil)

  return run
end

return Game
