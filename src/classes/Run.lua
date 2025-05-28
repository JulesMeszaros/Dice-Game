local Round = require("src.classes.Round")
local AfterRound = require("src.screens.AfterRound")
local GameOverScreen = require("src.screens.GameOverScreen")


local runStates = {
    ROUND = 1,
    SHOP = 2,
    GAME_OVER = 3
}

local Run = {
    --Dices variables
    drawedDices = {}, --Current Drawed Dices

    --Drag variables (should rather be located in the Game class i guess...)
    isDragging = false,
    dragOriginX = nil,
    dragOriginY = nil,

    draggingTreshold = 10,

    --Gameplay variables
    usedRerolls = 0, --total rerolls used for this game

    --Run variables
    roundNumber = 1,
    totalScore = 0,

    --Run state
    currentState = runStates.ROUND,
    isInRound = true,
    isInShop = false
}

Run.__index = Run

--Get the cool ass font
local font = love.graphics.newFont("src/assets/fonts/joystix.otf", 20)

function Run:new(dices, gameCanvas, game)
    local self = setmetatable({}, Run)

    --The canvas the game is rendered on.
    self.gameCanvas = gameCanvas
    self.game = game

    --On attribue le set de dés
    self.dices = dices

    --Create the first Round of the run
    local round = Round.new(1, self.dices, self.gameCanvas, self)
    round:makeRoll(dices) --make first roll
    self.currentRound = round
    
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
function Run:startNewRound()
    local newRoundNumber = self.roundNumber + 1 --Increments the number of round
    self.roundNumber = newRoundNumber
    local newRound = Round.new(newRoundNumber, self.dices, self.gameCanvas, self) --Create a new round object
    newRound:makeRoll(self.dices) 
    self.currentRound = newRound

    self.currentState = runStates.ROUND
end

function Run:endRound()
    --checks if the goal was reached during round
    if(self.currentRound.roundScore >= self.currentRound.targetScore)then
        local afterRound = AfterRound:new(self, self.gameCanvas)
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
    self:drawTerrain()
    love.graphics.setCanvas(self.gameCanvas)

    --TODO: à déplacer dans la classe terrain
    local rerollText = love.graphics.newText(font, "Rerolls : " ..tostring(self.currentRound.availableRerolls))
    local scoreText = love.graphics.newText(font, 'Score : ' ..tostring(self.currentRound.roundScore))
    local targetScoreText = love.graphics.newText(font, 'Target : '..tostring(self.currentRound.targetScore))
    local currentHands = love.graphics.newText(font, 'Hands : '..tostring(self.currentRound.remainingHands))
    local currentRoundText = love.graphics.newText(font, 'Round : '..tostring(self.roundNumber))

    love.graphics.draw(rerollText, 10, 3)
    love.graphics.draw(currentHands, 10, 23)
    love.graphics.draw(targetScoreText, 10, 43)
    love.graphics.draw(scoreText, 10, 63)

    love.graphics.draw(currentRoundText, 10, self.gameCanvas:getHeight()-10, 0, 1, 1, 0, currentRoundText:getHeight())

    love.graphics.setCanvas(self.gameCanvas)


    --Show the currently hovered figure button
    if(self.currentRound.terrain.currentlyHoveredFigure)then
        -- Creates a text with the name of the figure and the text
        local figureHoveredText = love.graphics.newText(font, self.currentRound.terrain:getCurrentlyHoveredFigure()[1])
        love.graphics.draw(figureHoveredText, 20, 650, 0, 1, 1, 0, figureHoveredText:getHeight()/2)

        --Highlight the used dices
        local usedDices = self.currentRound.terrain:getCurrentlyHoveredFigure()[2]

        for key,diceface in next,self.currentRound.diceFaces do
            diceface:setHighlighted(false)
            for _, dice in next,usedDices do
                if self.currentRound.diceFaces[dice] == diceface then
                     diceface:setHighlighted(true)
                     break
                end
            end
        end
    else
        for key,diceface in next,self.currentRound.diceFaces do
            diceface:setHighlighted(false)
        end
    end

end

function Run:drawTerrain()
    --Dessine le terrain du round actuel
    love.graphics.draw(self.currentRound.terrain.terrainCanvas, 0, 0)
end

--==INPUTS FUNCTIONS==

function Run:keypressed(key)
    if(self.currentState==runStates.ROUND)then
        self.currentRound:keypressed(key)
    elseif(self.currentState==runStates.SHOP)then
        self.shop:keypressed(key)
    elseif(self.currentState==runStates.GAME_OVER)then
        self.shop:keypressed(key)
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