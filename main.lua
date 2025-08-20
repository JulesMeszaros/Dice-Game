local Animator = require("src.utils.Animator")
local Shaders = require("src.utils.Shaders")
local Inputs = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local SaveManager = require("src.utils.SaveManager")
local Fonts = require("src.utils.Fonts")
local Game = require("src.classes.Game")

G = {
    
    --Background color
    backgroundR = 40/255,
    backgroundG = 40/255,
    backgroundB = 43/255,

    --screen shake
    --Screen target position
    rx = 0,
    ry = 0,
    --Screen position (relative) 
    ox = 0,
    oy = 0,
    --Wave
    waveX = 0,
    waveY = 0

}

--Some stats for the session
local baseStats = {
    usedRerolls = 0,
    triggeredDices = 0,
    usedWands = 0,
    playedHands = 0,
    usedCoffees = 0,
    --Type specific stats
    triggeredDiceTypes = {},
    TriggeredCoffeeTypes = {},
    UsedCoffeeTypes = {}
}

--Stats for Dice Faces

--Stats for Wands

--Stats for coffees

G.animator = Animator:new(G)


-- Function to calculate parallax offset
function G.calculateParalaxeOffset(layer)
    local Constants = require("src.utils.Constants")
    return G.ox * Constants.PARALAXE_MAX_OFFSET[layer], G.oy * Constants.PARALAXE_MAX_OFFSET[layer]
end

local delta = 0
local fpstext = nil -- Cache the FPS text object

local fpsLimit = nil -- nil = pas de limite
local fpsOptions = { nil, 60, 30, 15 , 5}
local currentFpsIndex = 1

local backgroundCanvas = nil

function love.load()
    --Save Manager
    G.saveManager = SaveManager:new("save.lua", baseStats)
    G.runSaveManager = SaveManager:new("run.lua")
    
    --bien randomiser le jeu
    math.randomseed(os.clock() * 1000000)
    for i=0,os.clock() * 1000000 do
        math.random()
    end

    love.graphics.setBackgroundColor(G.backgroundR, G.backgroundG, G.backgroundB)

    local sys = love.system.getOS()

    if(sys=="OS X" or sys=="Windows")then
        local cursor = love.mouse.newCursor("src/assets/sprites/ui/cursor.png", 0, 0)
        love.mouse.setCursor(cursor)
    end

    game = Game:start()
    
    -- Create the FPS text object once
    fpstext = love.graphics.newText(Fonts.soraSmall, "fps:0")
    
    -- Create background canvas
    backgroundCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end

function love.update(dt)
    if love.timer.getTime() % 5 < dt then -- toutes les 5 secondes
        print("Memory: " .. math.floor(collectgarbage("count")) .. " KB")
    end

    local vx,vy = Inputs.getVirtualMousePosition()
    --relative x/y mouse position (0-1)
    G.rx, G.ry = (vx/Constants.VIRTUAL_GAME_WIDTH)-0.5, (vy/Constants.VIRTUAL_GAME_HEIGHT)-0.5
    

    G.animator:update(dt)
    game:update(dt)
    delta = love.timer.getFPS()
    
    -- Simulation de FPS faible
    if fpsLimit then
        local desiredFrameTime = 1 / fpsLimit
        local frameTime = love.timer.getDelta()
        local sleepTime = desiredFrameTime - frameTime
        if sleepTime > 0 then
            love.timer.sleep(sleepTime)
        end
    end

end

function love.draw()
    drawBackground()
    
    game:draw()
    -- Update the cached FPS text object
    fpstext:set("fps:"..delta)
    love.graphics.draw(fpstext, love.graphics.getWidth()-5, 5, 0, 1, 1, fpstext:getWidth(), 0)
end

function love.keypressed(key)
    game:keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    game:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    game:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy)
    game:mousemoved(x, y, dx, dy)
end

function love.resize(w, h)
    backgroundCanvas = love.graphics.newCanvas(w, h)
end

function drawBackground()
    -- Draw background to canvas with shader
    love.graphics.setCanvas(backgroundCanvas)
    love.graphics.clear(G.backgroundR, G.backgroundG, G.backgroundB)
    love.graphics.setColor(G.backgroundR, G.backgroundG, G.backgroundB)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    
    -- Set main canvas and draw background with shader
    love.graphics.setCanvas()
    love.graphics.setShader(Shaders.diagonalCircles)
    Shaders.diagonalCircles:send("time", love.timer.getTime())
    Shaders.diagonalCircles:send("circle_size", 0.05)
    Shaders.diagonalCircles:send("spacing", 0.2)
    Shaders.diagonalCircles:send("speed", 0.2)
    Shaders.diagonalCircles:send("darkness", -0.4)
    love.graphics.draw(backgroundCanvas, 0, 0)
    love.graphics.setShader()
end

function love.quit()
    G.saveManager:save()
end