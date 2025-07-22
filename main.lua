local Fonts = require("src.utils.Fonts")

local Game = require("src.classes.Game")

local delta = 0

local fpsLimit = nil -- nil = pas de limite
local fpsOptions = { nil, 60, 30, 15 , 5}
local currentFpsIndex = 1

function love.load()
    --bien randomiser le jeu
    math.randomseed(os.clock() * 1000000)
    for i=0,os.clock() * 1000000 do
        math.random()
    end

    love.graphics.setBackgroundColor(40/255, 40/255, 43/255)

    --cursor = love.mouse.newCursor("src/assets/sprites/ui/cursor.png", 0, 0)
    --love.mouse.setCursor(cursor)

    game = Game:start()
end

function love.update(dt)
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
    love.graphics.clear(40/255, 40/255, 43/255)
    game:draw()
    fpstext = love.graphics.newText(Fonts.soraSmall, "fps:"..delta)
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