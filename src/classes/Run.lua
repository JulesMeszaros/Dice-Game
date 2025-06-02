local Round = require("src.classes.Round")
local AfterRound = require("src.screens.AfterRound")
local GameOverScreen = require("src.screens.GameOverScreen")
local RoundChoice = require("src.screens.RoundChoice")

local Dice = require("src.classes.Dices.Dice")

local runStates = {
    ROUND = 1,
    SHOP = 2,
    GAME_OVER = 3
}

local Run = {}

Run.__index = Run

--Get the cool ass font
local font = love.graphics.newFont("src/assets/fonts/joystix.otf", 20)

function Run:new(dices, gameCanvas, game, diceObjects)
    local self = setmetatable({}, Run)

    --Dices variables
    self.drawedDices = {} --Current Drawed Dices
    --Drag variables (should rather be located in the Game class i guess...)
    self.isDragging = false
    self.dragOriginX = nil
    self.dragOriginY = nil
    self.draggingTreshold = 10
    --Gameplay variables
    self.usedRerolls = 0 --total rerolls used for this game
    --Run variables
    self.roundNumber = 1
    self.totalScore = 0
    --Run state
    self.currentState = runStates.ROUND
    self.isInRound = true
    self.isInShop = false
    --Money
    self.money = 5

    --The canvas the game is rendered on.
    self.gameCanvas = gameCanvas
    self.game = game

    --On attribue le set de dés
    self.dices = dices
    self.diceObjects = diceObjects
    --Create the first Round of the run
    local round = Round:new(1, self.dices, self.gameCanvas, self, 0, 0, self.diceObjects)

    self:startNewRound(round)
    
    return self
end

function Run:update(dt)
    if(self.currentState==runStates.ROUND)then
        --update Round
        self.currentRound:update(dt)

        --Update dices UI
        for key,dice in next,self.currentRound.diceFaces do
            dice:update(dt)
        end
    elseif(self.currentState==runStates.SHOP)then
        --update shop
        self.shop:update(dt)
    elseif(self.currentState==runStates.GAME_OVER)then
        self.gameOver:update(dt)
    end
end

function Run:draw(gameCanvas) --Render the game into the Game Canvas.
    --==DRAW THE ROUND==--
    if(self.currentState==runStates.ROUND)then --check if we are in round
        self:drawRound() --Draw the round
    elseif(self.currentState == runStates.SHOP)then --check if we are in shop
        self.shop:draw() --Draw the shop
    elseif(self.currentState == runStates.GAME_OVER)then
        self.gameOver:draw()
    end

    --==DRAW THE AFTER ROUND==-- (plus tard le shop)
end

--==ROUND FUNCTIONS==--
function Run:startNewRound(round)
    print("----")
    self.roundNumber = round.nround
    round:makeRoll(self.dices)

    self.currentRound = round

    self.currentState = runStates.ROUND
end

function Run:endRound()
    --checks if the goal was reached during round
    if(self.currentRound.roundScore >= self.currentRound.targetScore)then
        --Triggers the next round
        --Calculate the money earned, based on the number of hands remaining
        local moneyEarned = self.currentRound.remainingHands + self.currentRound.baseReward
        self.money = self.money + moneyEarned

        --Make a local copy of the round to pass in the after round sequence
        local playedRound = self.currentRound
        local afterRound = RoundChoice:new(playedRound, self)
        self.shop = afterRound

        self.currentState = runStates.SHOP --Change d'état de Run
    else --gameover case
        local gameOver = GameOverScreen:new(self.gameCanvas, self)
        self.gameOver = gameOver
        self.currentState = runStates.GAME_OVER
    end
end
--==DRAW FUNCTIONS==--

function Run:drawRound()
    --Set the right canvas
    love.graphics.draw(self.currentRound.terrain.terrainCanvas, 0, 0)

end

--==INPUTS FUNCTIONS==

function Run:keypressed(key)
    if(self.currentState==runStates.ROUND)then
        self.currentRound:keypressed(key)
    elseif(self.currentState==runStates.SHOP)then
        self.shop:keypressed(key)
    elseif(self.currentState==runStates.GAME_OVER)then
        self.gameOver:keypressed(key)
    end
end

function Run:mousepressed(x, y, button, istouch, presses)
    --Met les coordonnées de drag à 0
    self.dragOriginX = x ; self.dragOriginY = y

    if(self.currentState == runStates.ROUND)then
        self.currentRound:mousepressed(x, y, button, istouch, presses)
    elseif(self.currentState==runStates.SHOP)then
        self.shop:mousepressed(x, y, button, istouch, presses)
    elseif(self.currentState==runStates.GAME_OVER)then
        self.gameOver:mousepressed(x, y, button, istouch, presses)
    end
end

function Run:mousereleased(x, y, button, istouch, presses)
    if(self.currentState==runStates.ROUND)then
        self.currentRound:mousereleased(x, y, button, istouch, presses)
    elseif(self.currentState==runStates.SHOP)then
        self.shop:mousereleased(x, y, button, istouch, presses)
    elseif(self.currentState==runStates.GAME_OVER)then
        self.gameOver:mousereleased(x, y, button, istouch, presses)
    end

    --Deactivate dragging
    self.isDragging = false
end

function Run:mousemoved(x, y, dx, dy)
    if(self.currentState==runStates.ROUND)then
        self.currentRound:mousemoved(x, y, dx, dy, self.isDragging)
    elseif(self.currentState==runStates.SHOP)then
        self.shop:mousemoved(x, y, dx, dy, self.isDragging)
    elseif(self.currentState==runStates.GAME_OVER)then
        self.gameOver:mousemoved(x, y, dx, dy, self.isDragging)
    end
    --x et y sont la position, dx et dy sont la vitesse.

    if(love.mouse.isDown(1) and self.dragOriginX and self.dragOriginY) then

        if( --sets dragging state
        math.abs(love.mouse.getX() - self.dragOriginX) > self.draggingTreshold
        or math.abs(love.mouse.getY() - self.dragOriginY) > self.draggingTreshold) then
            self.isDragging = true
        end
    end
end

return Run