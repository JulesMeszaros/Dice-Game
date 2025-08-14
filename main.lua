local Animator = require("src.utils.Animator")

G = {
    backgroundR = 40/255,
    backgroundG = 40/255,
    backgroundB = 43/255,
}

G.animator = Animator:new(G)

local Fonts = require("src.utils.Fonts")
local Game = require("src.classes.Game")

local delta = 0
local fpstext = nil -- Cache the FPS text object

local fpsLimit = nil -- nil = pas de limite
local fpsOptions = { nil, 60, 30, 15 , 5}
local currentFpsIndex = 1



function love.load()
    --bien randomiser le jeu
    math.randomseed(os.clock() * 1000000)
    for i=0,os.clock() * 1000000 do
        math.random()
    end

    love.graphics.setBackgroundColor(G.backgroundR, G.backgroundG, G.backgroundB)

    local sys = love.system.getOS()

    if(sys=="OS X" or sys=="Windows")then
        cursor = love.mouse.newCursor("src/assets/sprites/ui/cursor.png", 0, 0)
        love.mouse.setCursor(cursor)
    end

    game = Game:start()
    
    -- Create the FPS text object once
    fpstext = love.graphics.newText(Fonts.soraSmall, "fps:0")
end

function love.update(dt)
    if love.timer.getTime() % 5 < dt then -- toutes les 5 secondes
        print("Memory: " .. math.floor(collectgarbage("count")) .. " KB")
    end
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
    love.graphics.setCanvas()
    love.graphics.clear(G.backgroundR, G.backgroundG, G.backgroundB)
    game:draw()
    -- Update the cached FPS text object
    fpstext:set("fps:"..delta)
    love.graphics.draw(fpstext, love.graphics.getWidth()-5, 5, 0, 1, 1, fpstext:getWidth(), 0)
    
    --dimtext = love.graphics.newText(Fonts.soraSmall, tostring(love.graphics.getWidth()).."x"..tostring(love.graphics.getHeight()))
    --love.graphics.draw(dimtext, love.graphics.getWidth()-5, 30, 0, 1, 1, dimtext:getWidth(), 0)

end

function love.keypressed(key)
    game:keypressed(key)

    if key == "f" then
        currentFpsIndex = currentFpsIndex % #fpsOptions + 1
        fpsLimit = fpsOptions[currentFpsIndex]
        if fpsLimit then
            print("FPS limité à " .. fpsLimit)
        else
            print("FPS illimité")
        end
    end
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