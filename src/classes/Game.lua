local Run = require("src.classes.run")
local Dice = require("src.classes.dice")

local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")

local Game = { 
    currentScreen = 1,
    gamePaused = false
}
Game.__index = Game

local PAGES = {
    MAIN_MENU = 0,
    GAME = 1
}

function Game:start()
    local self = setmetatable({}, Game)
    self.currentScreen = PAGES.GAME
    
    dices = { -- On définit les 5 dés présents dans la partie
        Dice:new(),
        Dice:new(),
        Dice:new(),
        Dice:new(),
        Dice:new()
    }

    --Game dimmensions
    self.virtualWidth, self.virtualHeight = Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT
    self.gameCanvas = love.graphics.newCanvas(self.virtualWidth, self.virtualHeight)

    run = Run:new(dices, self.gameCanvas) -- start run
    

    return self
end

function Game:update(dt)
    if self.currentScreen == PAGES.GAME then
        run:update(dt)     
    end
end

function Game:draw()

    love.graphics.setCanvas(self.gameCanvas)
    love.graphics.clear()
    --Rendu du jeu--
    --love.graphics.rectangle("fill", 0, 0, self.gameCanvas:getWidth(), self.gameCanvas:getHeight())
    run:draw(self.gameCanvas)
    love.graphics.setCanvas()

    --Affichage du jeu--
    -- Calcule le scale pour garder le ratio
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = math.min(screenWidth / self.virtualWidth, screenHeight / self.virtualHeight)

    local scaledWidth = self.virtualWidth * scale
    local scaledHeight = self.virtualHeight * scale

    local offsetX = (screenWidth - scaledWidth) / 2
    local offsetY = (screenHeight - scaledHeight) / 2

    if self.currentScreen == PAGES.GAME then
        --
        love.graphics.draw(self.gameCanvas, offsetX, offsetY, 0, scale, scale)
    end
end

function Game:keypressed(key)
    run:keypressed(key)
end

function Game:mousepressed(x, y, button, istouch, presses)
    vx, vy = Inputs.getVirtualMousePosition(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    run:mousepressed(vx, vy, button, istouch, presses)
end

function Game:mousereleased(vx, vy, button, istouch, presses)
    vx, vy = Inputs.getVirtualMousePosition(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    run:mousereleased(vx, vy, button, istouch, presses)
end

function Game:mousemoved(x, y, dx, dy)
    vx, vy = Inputs.getVirtualMousePosition(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    
    scale = Inputs.getCanvasScale(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    
    vdx, vdy = dx / scale, dy / scale
    run:mousemoved(vx, vy, vdx, vdy)
end

return Game