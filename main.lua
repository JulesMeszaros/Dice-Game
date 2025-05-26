local Game = require("src.classes.Game")

local delta = 0

function love.load()
    --bien randomiser le jeu
    math.randomseed(os.clock() * 1000000)
    for i=0,os.clock() * 1000000 do
        math.random()
    end

    game = Game:start()
    love.graphics.setBackgroundColor(26/255, 79/255, 37/255)
end

function love.update(dt)
    game:update(dt)
    delta = love.timer.getFPS()
    
end

function love.draw()
    --love.graphics.clear(26/255, 79/255, 37/255)
    game:draw()
    love.graphics.draw(love.graphics.newText(love.graphics.newFont("src/assets/fonts/joystix.otf"), "fps:"..delta), love.graphics.getWidth()-100, 30)
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