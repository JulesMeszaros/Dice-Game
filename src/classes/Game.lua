local Run = require("src.classes.run")

local Game = { currentScreen = 1}
Game.__index = Game

local PAGES = {
    MAIN_MENU = 0,
    GAME = 1
}

function Game:start()
    local self = setmetatable({}, Game)
    self.currentScreen = PAGES.GAME
    run = Run:new()

    return self
end

function Game:update(dt)
    if self.currentScreen == PAGES.GAME then
        run:update(dt)     
    end
end

function Game:draw()
    if self.currentScreen == PAGES.GAME then
        run:draw()
    end
end

function Game:keypressed(key)
    run:keypressed(key)
end

function Game:mousepressed(x, y, button, istouch, presses)
    run:mousepressed(x, y, button, istouch, presses)
end

return Game