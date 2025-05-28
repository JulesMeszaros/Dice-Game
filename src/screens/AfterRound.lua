--Utils
local Fonts = require('src.utils.fonts')
local Inputs = require("src.utils.scripts.inputs")

local Button = require("src.classes.ui.Button")

--Temp class for the screen happening after the round
local AfterRound = {
    uiElements = {
        buttons = {}
    }
}
AfterRound.__index = AfterRound

function AfterRound:new(run, gameCanvas)
    local self = setmetatable({}, AfterRound)

    self.gameCanvas = gameCanvas
    --Link to the run/round
    self.run = run
    self.roundPlayed = self.run.currentRound

    self.uiElements.buttons["newRoundButton"] = Button:new(
        function()self.run:startNewRound()end,
        "src/assets/sprites/ui/buttons/next_round.png",
        self.gameCanvas:getWidth()/2,
        self.gameCanvas:getHeight()/2,
        300,
        125,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    return self
end

function AfterRound:draw()
    --Score
    local scoreText = love.graphics.newText(Fonts.pixelated, "Round score : "..self.roundPlayed.roundScore)
    --Texte fin du round
    local endRoundText = love.graphics.newText(Fonts.pixelated, 'End of round '..self.roundPlayed.nround)

    love.graphics.draw(endRoundText, self.gameCanvas:getWidth()/2, 40, 0, 1, 1, endRoundText:getWidth()/2, endRoundText:getHeight()/2)
    love.graphics.draw(scoreText, self.gameCanvas:getWidth()/2, 90, 0, 1, 1, scoreText:getWidth()/2, scoreText:getHeight()/2)


    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:draw()
    end
end

function AfterRound:update(dt)
    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end
end

--==KEYBOARD/MOUSE INPUTS==--

function AfterRound:keypressed(key)
    print("keypressed")
end

function AfterRound:mousepressed(x, y, button, istouch, presses)
   --Buttons
   for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end
end

function AfterRound:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end
end

function AfterRound:mousemoved(x, y, dx, dy, isDragging)
    --print("moved")
end

return AfterRound
