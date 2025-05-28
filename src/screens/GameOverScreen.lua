local Fonts = require("src.utils.fonts")
local Button = require("src.classes.ui.Button")
local Inputs = require("src.utils.scripts.inputs")

local GameOverScreen = {
    uiElements = {
        buttons = {}
    }
}
GameOverScreen.__index = GameOverScreen

function GameOverScreen:new(gameCanvas, run)
    local self = setmetatable({}, GameOverScreen)

    self.gameCanvas = gameCanvas
    self.run = run

    local gameoverCanvas = love.graphics.newCanvas(gameCanvas:getWidth(), gameCanvas:getHeight())
    self.gameoverCanvas = gameoverCanvas

    --Buttons
    self.uiElements.buttons["newRun"] = Button:new(
        function()self.run.game:startNewRun()end,
        "src/assets/sprites/ui/buttons/new_run.png",
        self.gameoverCanvas:getWidth()/2,
        self.gameoverCanvas:getHeight()/2,
        400,
        167,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    return self
end

function GameOverScreen:update(dt)
    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end
end

function GameOverScreen:draw()
    love.graphics.setCanvas(self.gameoverCanvas)
    love.graphics.clear()

    local text = love.graphics.newText(Fonts.pixelatedBig, "Game Over")
    local summarytext = love.graphics.newText(Fonts.pixelated, "Round : "..tostring(self.run.roundNumber).. ' - Score : '.. tostring(self.run.currentRound.roundScore) .. ' - Target : ' ..tostring(self.run.currentRound.targetScore))
    
    love.graphics.draw(text, self.gameoverCanvas:getWidth()/2, 50, 0, 1, 1, text:getWidth()/2, text:getHeight()/2)
    love.graphics.draw(summarytext, self.gameoverCanvas:getWidth()/2, 150, 0, 1, 1, summarytext:getWidth()/2, summarytext:getHeight()/2)

    --Draw the buttons
   for key,button in next,self.uiElements.buttons do
        button:draw()
    end

    love.graphics.setCanvas(self.gameCanvas)

    love.graphics.draw(self.gameoverCanvas, 0, 0)
end

--==INPUT FUNCTIONS==--

function GameOverScreen:keypressed(key)
    print("keypressed")
end

function GameOverScreen:mousepressed(x, y, button, istouch, presses)
   --Buttons
   for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end
end

function GameOverScreen:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end
end

function GameOverScreen:mousemoved(x, y, dx, dy, isDragging)

end

return GameOverScreen 