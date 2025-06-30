local Fonts = require("src.utils.Fonts")

local Game = require("src.classes.Game")

local delta = 0

function love.load()
    --bien randomiser le jeu
    math.randomseed(os.clock() * 1000000)
    for i=0,os.clock() * 1000000 do
        math.random()
    end
    love.graphics.setBackgroundColor(40/255, 40/255, 43/255)

    game = Game:start()
end

function love.update(dt)
    game:update(dt)
    delta = love.timer.getFPS()
    
end

function love.draw()
    love.graphics.setCanvas()
    love.graphics.clear()
    game:draw()
    fpstext = love.graphics.newText(Fonts.soraSmall, "fps:"..delta)
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