local Run = require("src.classes.Run")
local MainMenu = require("src.classes.MainMenu")

--Import The Dices
local Dice = require("src.classes.Dices.Dice")
local ReverseDice = require("src.classes.Dices.ReverseDice")
local LuckyDice = require("src.classes.Dices.LuckyDice")
local PharmacyDice = require("src.classes.Dices.PharmacyDice")

--Utils
local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")
local Shaders = require("src.utils.shaders")

local applyCRT = false

local Game = { 
    currentScreen = 1,
    gamePaused = false,
    run = nil
}
Game.__index = Game

local PAGES = {
    MAIN_MENU = 0,
    GAME = 1
}
--Game dimmensions
local virtualWidth, virtualHeight = Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT

local gameCanvas = love.graphics.newCanvas(virtualWidth, virtualHeight)
gameCanvas:setFilter("nearest", "nearest")


local dices = { -- On définit les 5 dés présents dans la partie
        Dice:new(),
        Dice:new(),
        PharmacyDice:new(),
        LuckyDice:new(),
        ReverseDice:new()
    }

function Game:start()
    local self = setmetatable({}, Game)
    self.gameCanvas = gameCanvas

    self.currentScreen = PAGES.MAIN_MENU

    --Create a main menu
    self.mainMenu = MainMenu:new(self.gameCanvas, self)


    return self
end

function Game:update(dt)
    if self.currentScreen == PAGES.MAIN_MENU then
        self.mainMenu:update(dt)
    elseif self.currentScreen == PAGES.GAME then
        self.run:update(dt)     
    end
end

function Game:draw()

    love.graphics.setCanvas(self.gameCanvas)
    love.graphics.clear()
    --Rendu du jeu--
    if(self.currentScreen == PAGES.MAIN_MENU)then
        self.mainMenu:draw()
    elseif(self.currentScreen == PAGES.GAME)then
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
    self.currentScreen = PAGES.GAME
    self.run = Run:new(dices, self.gameCanvas, self)

end

--==INPUTS FUNCTIONS==--

function Game:keypressed(key)

    if(key=="c")then
        applyCRT = not applyCRT
    end

    if(key=="b")then
        self.currentScreen = PAGES.GAME
        self.run = Run:new(dices, self.gameCanvas, self)
    end

    if(key=="o")then
        self.currentScreen = PAGES.MAIN_MENU
    end

    if(self.currentScreen == PAGES.MAIN_MENU)then

    elseif(self.currentScreen == PAGES.GAME)then
        self.run:keypressed(key)
    end
end

function Game:mousepressed(x, y, button, istouch, presses)
    local vx, vy = Inputs.getVirtualMousePosition(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)

    if(self.currentScreen == PAGES.MAIN_MENU)then
        self.mainMenu:mousepressed(vx, vy, button, istouch, presses)
    elseif(self.currentScreen == PAGES.GAME)then
        self.run:mousepressed(vx, vy, button, istouch, presses)
    end
end

function Game:mousereleased(vx, vy, button, istouch, presses)
    local vx, vy = Inputs.getVirtualMousePosition(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    
    if(self.currentScreen == PAGES.MAIN_MENU)then
        self.mainMenu:mousereleased(vx, vy, button, istouch, presses)
    elseif(self.currentScreen == PAGES.GAME)then
        self.run:mousereleased(vx, vy, button, istouch, presses)
    end
end

function Game:mousemoved(x, y, dx, dy)
    local vx, vy = Inputs.getVirtualMousePosition(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    
    local scale = Inputs.getCanvasScale(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    
    local vdx, vdy = dx / scale, dy / scale
    
    if(self.currentScreen == PAGES.MAIN_MENU)then
        self.mainMenu:mousemoved(vx, vy, vdx, vdy)
    elseif(self.currentScreen == PAGES.GAME)then
        self.run:mousemoved(vx, vy, vdx, vdy)
    end
end

return Game