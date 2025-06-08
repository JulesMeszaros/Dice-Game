local Round = require("src.classes.Round")
local GameOverScreen = require("src.screens.GameOverScreen")
local Constants = require("src.utils.constants")
local Floor = require("src.classes.Floor")
local DeskChoice = require("src.screens.DeskChoice")

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

    self.roundNumber = 0 --Représente le numéro de round total
    --Run state
    self.currentState = Constants.RUN_STATES.ROUND

    --Money
    self.money = 5

    --The canvas the game is rendered on.
    self.gameCanvas = gameCanvas
    self.game = game

    --On attribue le set de dés
    self.diceObjects = diceObjects

    --Sets the number of time we can play a figure
    self.availableFigures = {}
    for k,f in next, Constants.FIGURES do
        self.availableFigures[f] = 2
    end

    --Floor variables
    --Create the first floor of the game
    self.currentFloor = Floor:new(1, self)
    self.floorNumber = 1 --Représente l'étage (augmente de 1 après un boss)
    self.floorDeskNumber = 1 --Représente le numéro de bureau dans l'étage actuel (retourne à 1 après un boss)
    self.deskChoice = DeskChoice:new(self.currentFloor, self)
    self.currentState = Constants.RUN_STATES.ROUND_CHOICE
    return self
end

function Run:update(dt)
    if(self.currentState==Constants.RUN_STATES.ROUND)then
        --update Round
        self.currentRound:update(dt)

        --Update dices UI
        for key,dice2 in next,self.currentRound.diceFaces2 do
            dice2:update(dt)
        end

    elseif(self.currentState==Constants.RUN_STATES.SHOP)then
        --update shop
        self.shop:update(dt)
    elseif(self.currentState==Constants.RUN_STATES.ROUND_CHOICE)then
        --update shop
        self.deskChoice:update(dt)
    elseif(self.currentState==Constants.RUN_STATES.GAME_OVER)then
        self.gameOver:update(dt)
    end
end

function Run:draw(gameCanvas) --Render the game into the Game Canvas.
    --==DRAW THE ROUND==--
    if(self.currentState==Constants.RUN_STATES.ROUND)then --check if we are in round
        self:drawRound() --Draw the round
    elseif(self.currentState == Constants.RUN_STATES.SHOP)then --check if we are in shop
        self.shop:draw() --Draw the shop
    elseif(self.currentState == Constants.RUN_STATES.ROUND_CHOICE)then --check if we are in shop
        self.deskChoice:draw() --Draw the shop
    elseif(self.currentState == Constants.RUN_STATES.GAME_OVER)then
        self.gameOver:draw()
    end

    --==DRAW THE AFTER ROUND==-- (plus tard le shop)
end

--==ROUND FUNCTIONS==--
function Run:createNewFloor()
    local floorNumber = self.currentFloor.floorNumber + 1
    local newFloor = Floor:new(floorNumber, self)
    return newFloor
end

function Run:startNewRound(round, roundtype)
    --Sets the round number
    self.roundNumber = self.roundNumber + 1
    --Makes the first roll
    round:makeRoll(self.diceObjects)
    --Sets the run's current round
    self.currentRound = round
    --Resets the available hands
    self:resetAvailableFigures()
    --Changes the screen to the round screen
    self.currentState = Constants.RUN_STATES.ROUND
end

function Run:endRound()
    --checks if the goal was reached during round
    if(self.currentRound.roundScore >= self.currentRound.targetScore)then
        --Calculate the money earned, based on the number of hands remaining
        local moneyEarned = self.currentRound.remainingHands + self.currentRound.baseReward
        self.money = self.money + moneyEarned
        --Increments the desk, and goes to the next floor if the desk rank is >3
        self.floorDeskNumber = self.floorDeskNumber + 1
        if(self.floorDeskNumber>4)then--Si le rank de desktop est superieur à 4 (donc que le bosse vient d'etre battu) on créée un nouvel étage
            self.currentFloor = self:createNewFloor()
            self.floorDeskNumber = 1
            print('New floor created')
        end

        self.deskChoice = DeskChoice:new(self.currentFloor, self)

        self.currentState = Constants.RUN_STATES.ROUND_CHOICE --Change d'état de Run
    else --gameover case
        local gameOver = GameOverScreen:new(self.gameCanvas, self)
        self.gameOver = gameOver
        self.currentState = Constants.RUN_STATES.GAME_OVER
    end
end
--==DRAW FUNCTIONS==--

function Run:drawRound()
    --Set the right canvas
    love.graphics.draw(self.currentRound.terrain.terrainCanvas, 0, 0)

end

--==INPUTS FUNCTIONS==

function Run:keypressed(key)
    if(self.currentState==Constants.RUN_STATES.ROUND)then
        self.currentRound:keypressed(key)
    elseif(self.currentState==Constants.RUN_STATES.SHOP)then
        self.shop:keypressed(key)
    elseif(self.currentState==Constants.RUN_STATES.ROUND_CHOICE)then
        self.deskChoice:keypressed(key)
    elseif(self.currentState==Constants.RUN_STATES.GAME_OVER)then
        self.gameOver:keypressed(key)
    end
end

function Run:mousepressed(x, y, button, istouch, presses)
    --Met les coordonnées de drag à 0
    self.dragOriginX = x ; self.dragOriginY = y

    if(self.currentState == Constants.RUN_STATES.ROUND)then
        self.currentRound:mousepressed(x, y, button, istouch, presses)
    elseif(self.currentState==Constants.RUN_STATES.SHOP)then
        self.shop:mousepressed(x, y, button, istouch, presses)
    elseif(self.currentState==Constants.RUN_STATES.ROUND_CHOICE)then
        self.deskChoice:mousepressed(x, y, button, istouch, presses)
    elseif(self.currentState==Constants.RUN_STATES.GAME_OVER)then
        self.gameOver:mousepressed(x, y, button, istouch, presses)
    end
end

function Run:mousereleased(x, y, button, istouch, presses)
    if(self.currentState==Constants.RUN_STATES.ROUND)then
        self.currentRound:mousereleased(x, y, button, istouch, presses)
    elseif(self.currentState==Constants.RUN_STATES.SHOP)then
        self.shop:mousereleased(x, y, button, istouch, presses)
    elseif(self.currentState==Constants.RUN_STATES.ROUND_CHOICE)then
        self.deskChoice:mousereleased(x, y, button, istouch, presses)
    elseif(self.currentState==Constants.RUN_STATES.GAME_OVER)then
        self.gameOver:mousereleased(x, y, button, istouch, presses)
    end

    --Deactivate dragging
    self.isDragging = false
end

function Run:mousemoved(x, y, dx, dy)
    if(self.currentState==Constants.RUN_STATES.ROUND)then
        self.currentRound:mousemoved(x, y, dx, dy, self.isDragging)
    elseif(self.currentState==Constants.RUN_STATES.SHOP)then
        self.shop:mousemoved(x, y, dx, dy, self.isDragging)
    elseif(self.currentState==Constants.RUN_STATES.ROUND_CHOICE)then
        self.deskChoice:mousemoved(x, y, dx, dy, self.isDragging)
    elseif(self.currentState==Constants.RUN_STATES.GAME_OVER)then
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

function Run:resetAvailableFigures()
    self.availableFigures = {}
    for k,f in next, Constants.FIGURES do
        self.availableFigures[f] = 2
    end
end

return Run