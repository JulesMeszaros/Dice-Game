local Run = require("src.classes.Run")
local MainMenu = require("src.screens.MainMenu")

--Utils
local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")
local Shaders = require("src.utils.shaders")

--Dice Face Types
local DiceObject = require("src.classes.DiceObject") 
local FaceTypes = require("src.classes.FaceTypes.FaceTypes")

local applyCRT = false

local Game = {}
Game.__index = Game

--Game dimmensions
local virtualWidth, virtualHeight = Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT

local gameCanvas = love.graphics.newCanvas(virtualWidth, virtualHeight)
gameCanvas:setFilter("linear", "linear")

--Creating the dices
local diceObjects = {} --liste des 6 dés blancs

for i=1, 5 do 
    local fs = {}
    for j=1,6 do
        local f = FaceTypes.WhiteFace:new(j, j)
        table.insert(fs,f)
    end
    table.insert(diceObjects, DiceObject:new(fs))
end

function Game:start()
    local self = setmetatable({}, Game)

    --New dice objects
    self.diceObjects = diceObjects

    self.currentScreen = Constants.PAGES.GAME
    self.gamePaused = false
    self.run = nil

    self.gameCanvas = gameCanvas

    self.currentScreen = Constants.PAGES.MAIN_MENU

    --Create a main menu
    self.mainMenu = MainMenu:new(self.gameCanvas, self)


    return self
end

function Game:update(dt)
    if self.currentScreen == Constants.PAGES.MAIN_MENU then
        self.mainMenu:update(dt)
    elseif self.currentScreen == Constants.PAGES.GAME then
        self.run:update(dt)     
    end
end

function Game:draw()
    love.graphics.setCanvas(self.gameCanvas)
    love.graphics.clear(40/255, 40/255, 43/255)
    --Rendu du jeu dans le game canvas--
    if(self.currentScreen == Constants.PAGES.MAIN_MENU)then
        self.mainMenu:draw()
    elseif(self.currentScreen == Constants.PAGES.GAME)then
        self.run:draw(self.gameCanvas)
    end

    love.graphics.setCanvas()
    

    --Affichage du jeu--
    -- Calcule le scale pour garder le ratio
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = math.min(screenWidth / virtualWidth, screenHeight / virtualHeight)

    local scaledWidth = virtualWidth * scale
    local scaledHeight = virtualHeight * scale

    local offsetX = (screenWidth - scaledWidth) / 2
    local offsetY = (screenHeight - scaledHeight) / 2
    
    if(applyCRT)then
        love.graphics.setShader(Shaders.crt)
    end
    love.graphics.draw(self.gameCanvas, offsetX, offsetY, 0, scale, scale)
    love.graphics.setShader()

end

--==GAME FUNCTION==--

function Game:startNewRun()
    self.currentScreen = Constants.PAGES.GAME
    self.run = Run:new(dices, self.gameCanvas, self, self.diceObjects)
end

--==INPUTS FUNCTIONS==--

function Game:keypressed(key)
    if(key=="c")then
        applyCRT = not applyCRT
    end

    if(self.currentScreen == Constants.PAGES.MAIN_MENU)then

    elseif(self.currentScreen == Constants.PAGES.GAME)then
        self.run:keypressed(key)
    end
end

function Game:mousepressed(x, y, button, istouch, presses)
    local vx, vy = Inputs.getVirtualMousePosition()

    if(self.currentScreen == Constants.PAGES.MAIN_MENU)then
        self.mainMenu:mousepressed(vx, vy, button, istouch, presses)
    elseif(self.currentScreen == Constants.PAGES.GAME)then
        self.run:mousepressed(vx, vy, button, istouch, presses)
    end
end

function Game:mousereleased(vx, vy, button, istouch, presses)
    local vx, vy = Inputs.getVirtualMousePosition()
    
    if(self.currentScreen == Constants.PAGES.MAIN_MENU)then
        self.mainMenu:mousereleased(vx, vy, button, istouch, presses)
    elseif(self.currentScreen == Constants.PAGES.GAME)then
        self.run:mousereleased(vx, vy, button, istouch, presses)
    end
end

function Game:mousemoved(x, y, dx, dy)
    local vx, vy = Inputs.getVirtualMousePosition()
    local scale = Inputs.getCanvasScale()
    local vdx, vdy = dx / scale, dy / scale
    
    if(self.currentScreen == Constants.PAGES.MAIN_MENU)then
        self.mainMenu:mousemoved(vx, vy, vdx, vdy)
    elseif(self.currentScreen == Constants.PAGES.GAME)then
        self.run:mousemoved(vx, vy, vdx, vdy)
    end
end

return Game