local Game = require("src.classes.Game")

function love.load()
    game = Game:start()
    love.graphics.setBackgroundColor(26/255, 79/255, 37/255)
end

function love.update(dt)
    game:update(dt)
    
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    game:keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    game:mousepressed(x, y, button, istouch, presses)
end