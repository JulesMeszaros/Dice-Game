local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")
local Fonts = require("src.utils.fonts")

local Button = require("src.classes.ui.Button")
local Round = require("src.classes.Round")

local RoundChoice = {}

RoundChoice.__index = RoundChoice

local choiceNumber = 4

function RoundChoice:new(previousRound, run)

    self.uiElements = {
        buttons = {},
        roundChoiceButtons = {}
    }
    self.possibleRounds = {}

    local self = setmetatable({}, RoundChoice)
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)

    self.previousRound = previousRound
    self.run = run

    --Création des différents rounds à jouer
    for i = 1, choiceNumber do
        table.insert(self.possibleRounds, self:generateNewRound())
    end

    --Création des différents canvas de choix de round
    self.choiceCanvas = {}
    --On calcule la largeur de chaque canvas sachant que : On vaut 50px de marge sur les cotés, et 20px entre chaque canvas
    self.choiceCanvasWidth = ((self.canvas:getWidth()-100)/(choiceNumber))-((20*(choiceNumber-1))/choiceNumber)
    self.choiceCanvasHeight = self.canvas:getHeight()-300
    for i = 1, choiceNumber do
        local c = love.graphics.newCanvas(self.choiceCanvasWidth, self.choiceCanvasHeight)
        table.insert(self.choiceCanvas, c)

        --Create the next round button
        local chooseButton = Button:new(
            function()self.run:startNewRound(self.possibleRounds[i])end,
            "src/assets/sprites/ui/buttons/next_round.png",
            self.choiceCanvasWidth/2,
            self.choiceCanvasHeight-50,
            300/2,
            125/2,
            self.canvas,
            function()return Inputs.getMouseInCanvas(50+(i-1)*(20+self.choiceCanvasWidth), 200)end
        )
        table.insert(self.uiElements.roundChoiceButtons, chooseButton)
    end

    return self
end

function RoundChoice:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    for i=1, table.getn(self.choiceCanvas) do
        self:updateChoiceCanvas(self.choiceCanvas[i], dt, i)
        love.graphics.draw(self.choiceCanvas[i], 50+(i-1)*(20+self.choiceCanvasWidth), 200)
    end

    local topText = love.graphics.newText(Fonts.nexaMedium, "Choisissez votre round...")
    love.graphics.draw(topText, self.canvas:getWidth()/2, 50, 0, 1, 1, topText:getWidth()/2, 0)


    love.graphics.setCanvas(currentCanvas)

end

function RoundChoice:draw()
    love.graphics.draw(self.canvas, 0, 0)
end

--==CHOICES==--
function RoundChoice:updateChoiceCanvas(c, dt, i)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(c)
    love.graphics.clear(49/256, 74/256, 50/256)

    love.graphics.rectangle("line", 0, 0, c:getWidth(), c:getHeight())

    local rewardText = love.graphics.newText(Fonts.nexaSmall, "Reward : "..tostring(self.possibleRounds[i].baseReward).."€")
    local targetText = love.graphics.newText(Fonts.nexaMedium, "Target : "..tostring(self.possibleRounds[i].targetScore).." pts")
    
    love.graphics.draw(rewardText, c:getWidth()/2, c:getHeight()-150, 0, 1, 1, rewardText:getWidth()/2, rewardText:getHeight()/2)
    love.graphics.draw(targetText, c:getWidth()/2, 50, 0, 1, 1, targetText:getWidth()/2, targetText:getHeight()/2)

    self.uiElements.roundChoiceButtons[i]:update(dt)
    self.uiElements.roundChoiceButtons[i]:draw()

    love.graphics.setCanvas(currentCanvas)
end

function RoundChoice:generateNewRound()
    local baseReward = 3 + math.random(0, 3)
    local targetScore = 0 + 20*(self.previousRound.nround) + (math.random(0, 5) * 10)

    local r = Round:new(self.previousRound.nround + 1, self.run.gameCanvas, self.run, baseReward, targetScore, self.run.diceObjects)
    return r
end

--==INPUT FUNCTIONS==--

function RoundChoice:keypressed(key)
    print("keypressed")
end

function RoundChoice:mousepressed(x, y, button, istouch, presses)
   --Buttons
   for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end

    --Buttons
   for key,button in next,self.uiElements.roundChoiceButtons do
        button:clickEvent()
    end
end

function RoundChoice:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    --release event on UI elements (choice buttons)
    for key,button in next,self.uiElements.roundChoiceButtons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end
end

function RoundChoice:mousemoved(x, y, dx, dy, isDragging)

end

return RoundChoice