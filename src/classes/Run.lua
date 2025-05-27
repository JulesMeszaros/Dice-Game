local Dice = require("src.classes.Dices.Dice")
local DiceFace = require("src.classes.ui.DiceFace")
local UIElement = require("src.classes.ui.UIElement")
local Button = require("src.classes.ui.Button")
local Terrain = require("src.classes.ui.Terrain")

local Round = require("src.classes.Round")
local AfterRound = require("src.classes.AfterRound")

local Inputs = require("src.utils.scripts.inputs")

local Run = {
    --Dices variables
    drawedDices = {}, --Current Drawed Dices

    --UI
    uiElements = { -- Stores the UI Elements of the Run
        roundButtons = {}
    },

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
    runStates = {"round", "shop"},
    currentState = "round",
    isInRound = true,
    isInShop = false
}

Run.__index = Run

--Get the cool ass font
local font = love.graphics.newFont("src/assets/fonts/joystix.otf", 20)

function Run:new(dices, gameCanvas)
    local self = setmetatable({}, Run)

    --The canvas the game is rendered on.
    self.gameCanvas = gameCanvas

    --On attribue le set de dés
    self.dices = dices

    --Add a button
    self.uiElements.roundButtons["resetButton"] = Button:new(
        function()self.currentRound:resetSelectedDices()end, 
        "src/assets/sprites/ui/buttons/reset.png", 
        self.gameCanvas:getWidth()-125, 
        self.gameCanvas:getHeight()-70, 
        200, 
        84,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
        )
        

    self.uiElements.roundButtons["rerollButton"] = Button:new(
        function()self.currentRound:rerollDices()end, 
        "src/assets/sprites/ui/buttons/reroll.png", 
        self.gameCanvas:getWidth()-350, 
        self.gameCanvas:getHeight()-70, 
        200, 
        84,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.roundButtons["reorganiserButton"] = Button:new(
        function()self.currentRound.terrain:reorganiseDiceFaces(self.currentRound.diceFaces)end, 
        "src/assets/sprites/ui/buttons/reorganiser.png", 
        self.gameCanvas:getWidth()-570, 
        self.gameCanvas:getHeight()-70, 
        200, 
        84,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    --Create the first Round of the run
    local round = Round.new(1, self.dices, self.gameCanvas, self)
    round:makeRoll(dices) --make first roll
    self.currentRound = round
    
    return self
end

function Run:update(dt)

    if(self.currentState=="round")then
        --update Round
        self.currentRound:update(dt)

        --Update round Buttons
        for key,button in next,self.uiElements.roundButtons do
            button:update(dt)
        end

        --Update dices UI
        for key,dice in next,self.currentRound.diceFaces do
            dice:update(dt)
        end

        --TODO: à déplacer dans la classe Round 
        self.uiElements.roundButtons["rerollButton"]:setActivated(self.currentRound.availableRerolls>0 and table.getn(self.currentRound.selectedDices)>0)
        self.uiElements.roundButtons["resetButton"]:setActivated(table.getn(self.currentRound.selectedDices)>0)

    elseif(self.currentState=="shop")then
        --update shop
        self.shop:update(dt)
    end
end

function Run:draw(gameCanvas) --Render the game into the Game Canvas.
    --==DRAW THE ROUND==--
    if(self.currentState=="round")then --check if we are in round
        self:drawRound() --Draw the round
    elseif(self.currentState == "shop")then --check if we are in shop
        self.shop:draw() --Draw the shop
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

    self.currentState = "round"
end

function Run:endRound()
    local afterRound = AfterRound:new(self, self.gameCanvas)
    self.shop = afterRound

    self.currentState = "shop" --Change d'état de Run
end

--==DRAW FUNCTIONS==--

function Run:drawRound()
    --Set the right canvas
    self:drawTerrain()
    love.graphics.setCanvas(self.gameCanvas)
    self:drawUIElements(self.gameCanvas) --Draw the UI Elements into the canvas

    --Some informational text //TODO: Move the text to a dedicated function later
    local rerollText = love.graphics.newText(font, "Rerolls : " ..tostring(self.currentRound.availableRerolls))
    local scoreText = love.graphics.newText(font, 'Score : ' ..tostring(self.currentRound.roundScore))
    local targetScoreText = love.graphics.newText(font, 'Target : '..tostring(self.currentRound.targetScore))
    local currentHands = love.graphics.newText(font, 'Hands : '..tostring(self.currentRound.remainingHands))
    local currentRoundText = love.graphics.newText(font, 'Round : '..tostring(self.roundNumber))
    
    love.graphics.draw(rerollText, 10, 3)
    love.graphics.draw(currentHands, 10, 23)
    love.graphics.draw(targetScoreText, 10, 43)
    love.graphics.draw(scoreText, 10, 63)

    love.graphics.draw(currentRoundText, 10, love.graphics:getHeight()-10, 0, 1, 1, 0, currentRoundText:getHeight())

    love.graphics.setCanvas(gameCanvas)

    --Show the currently hovered figure button
    if(self.currentRound.terrain.currentlyHoveredFigure)then
        local figureHoveredText = love.graphics.newText(font, self.currentRound.terrain:getCurrentlyHoveredFigure())
        love.graphics.draw(figureHoveredText, 20, 650, 0, 1, 1, 0, figureHoveredText:getHeight()/2)
    end

end

function Run:drawTerrain()
    --Dessine le terrain du round actuel(temporaire j'imagine, on verra...)

    --Espace de dés
    self.currentRound.terrain:drawDiceTray(love.graphics.getCanvas():getWidth()-20, 20, self.currentRound.diceFaces)

    --Boutons de figures
    self.currentRound.terrain:drawFigureButtons(20, 102)

end

function Run:drawButtons(gameCanvas)
    for key,button in next,self.uiElements.roundButtons do
        button:draw(gameCanvas)
    end
end

function Run:drawUIElements(gameCanvas)
    --Fonction pour afficher les différents élément d'interface graphique
    self:drawButtons(gameCanvas)--Les boutons
end

--==INPUTS FUNCTIONS==

function Run:keypressed(key)
    if(self.currentState=="round")then
        self.currentRound:keypressed(key)
    elseif(self.currentState=="shop")then
        self.shop:keypressed(key)
    end
end

function Run:mousepressed(x, y, button, istouch, presses)
    --Met les coordonnées de drag à 0
    self.dragOriginX = x ; self.dragOriginY = y

    if(self.currentState == "round")then
        self.currentRound:mousepressed(x, y, button, istouch, presses)

        --Buttons
        for key,button in next,self.uiElements.roundButtons do
            button:clickEvent()
        end
    elseif(self.currentState=="shop")then
        self.shop:mousepressed(x, y, button, istouch, presses)
    end
end

function Run:mousereleased(x, y, button, istouch, presses)
    if(self.currentState=="round")then
        self.currentRound:mousereleased(x, y, button, istouch, presses)

        --release event on UI elements (buttons)
        for key,button in next,self.uiElements.roundButtons do
            local wasReleased = button:releaseEvent()
            if(wasReleased) then --Si le click a été complété
                button:getCallback()()
            end
        end
    elseif(self.currentState=='shop')then
        self.shop:mousereleased(x, y, button, istouch, presses)
    end

    --Deactivate dragging
    self.isDragging = false
end

function Run:mousemoved(x, y, dx, dy)
    if(self.currentState=="round")then
        self.currentRound:mousemoved(x, y, dx, dy, self.isDragging)
    elseif(self.currentState=="shop")then
        self.shop:mousemoved(x, y, dx, dy, self.isDragging)
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