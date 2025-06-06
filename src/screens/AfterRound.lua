--Utils
local Fonts = require('src.utils.fonts')
local Inputs = require("src.utils.scripts.inputs")

local Button = require("src.classes.ui.Button")

--Temp class for the screen happening after the round
local AfterRound = {}
AfterRound.__index = AfterRound

function AfterRound:new(run, gameCanvas, moneyEarned)
    local self = setmetatable({}, AfterRound)

    self.uiElements = {
        buttons = {}
    }

    --Represents the money earned during the round played
    self.moneyEarned = moneyEarned

    self.gameCanvas = gameCanvas
    self.afterRoundCanvas = love.graphics.newCanvas(gameCanvas:getWidth(), gameCanvas:getHeight())
    
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
    love.graphics.draw(self.afterRoundCanvas, 0, 0)
end

function AfterRound:update(dt)
    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end

    self:updateCanvas(dt)
end

function AfterRound:updateCanvas(dt)
    love.graphics.setCanvas(self.afterRoundCanvas)
    love.graphics.clear()

    --Score
    local scoreText = love.graphics.newText(Fonts.nexaSmall, "Round score : "..self.roundPlayed.roundScore)
    --Texte fin du round
    local endRoundText = love.graphics.newText(Fonts.nexaSmall, 'End of round '..self.roundPlayed.nround)
    --Argent gagné
    local moneyText = love.graphics.newText(Fonts.nexaSmall, 'Money earned : '..self.moneyEarned)

    love.graphics.draw(endRoundText, self.gameCanvas:getWidth()/2, 40, 0, 1, 1, endRoundText:getWidth()/2, endRoundText:getHeight()/2)
    love.graphics.draw(scoreText, self.gameCanvas:getWidth()/2, 90, 0, 1, 1, scoreText:getWidth()/2, scoreText:getHeight()/2)
    love.graphics.draw(moneyText, self.gameCanvas:getWidth()/2, 150, 0, 2, 2, scoreText:getWidth()/2, scoreText:getHeight()/2)


    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:draw()
    end

    love.graphics.setCanvas(self.gameCanvas)

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

end

return AfterRound
