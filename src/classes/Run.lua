local Dice = require("src.classes.Dice")
local DiceFace = require("src.classes.ui.DiceFace")
local UIElement = require("src.classes.ui.UIElement")
local Button = require("src.classes.ui.Button")
local Terrain = require("src.classes.ui.Terrain")
local Round = require("src.classes.Round")

local Inputs = require("src.utils.scripts.inputs")

local Run = {
    --Dices variables
    drawedDices = {}, --Current Drawed Dices

    --UI
    uiElements = { -- Stores the UI Elements of the Run
        buttons = {}
    },

    --Drag variables (should rather be located in the Game class i guess...)
    isDragging = false,
    dragOriginX = nil,
    dragOriginY = nil,

    draggingTreshold = 10,

    --Gameplay variables
    usedRerolls = 0, --total rerolls used for this game

    roundNumber = 1,
}

Run.__index = Run

--Get the cool ass font
local font = love.graphics.newFont("src/assets/fonts/joystix.otf", 25)

function Run:new(dices, gameCanvas)
    local self = setmetatable({}, Run)

    --The canvas the game is rendered on.
    self.gameCanvas = gameCanvas

    --On attribue le set de dés
    self.dices = dices

    --Terrain setup
    local terrain = Terrain:new()

    --Add a button
    self.uiElements.buttons["resetButton"] = Button:new(function()self.currentRound:resetSelectedDices()end, "src/assets/sprites/ui/buttons/reset.png", love.graphics.getWidth()-125, love.graphics.getHeight()-70, 200, 84)
    self.uiElements.buttons["rerollButton"] = Button:new(function()self.currentRound:rerollDices()end, "src/assets/sprites/ui/buttons/reroll.png", love.graphics.getWidth()-350, love.graphics.getHeight()-70, 200, 84)

    --Create the first Round of the run
    round = Round.new(1, self.dices, terrain, self.gameCanvas)
    round:makeRoll(dices) --make first roll
    self.currentRound = round
    
    return self
end

function Run:update(dt)
    --Update Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end

    --Update dices UI
    for key,dice in next,self.currentRound.diceFaces do
        dice:update(dt)
    end

    self.uiElements.buttons["rerollButton"]:setActivated(self.currentRound.availableRerolls>0 and table.getn(self.currentRound.selectedDices)>0)
    self.uiElements.buttons["resetButton"]:setActivated(table.getn(self.currentRound.selectedDices)>0)
end

function Run:draw(gameCanvas) --Render the game into the Game Canvas.
    --Set the right canvas
    self:drawTerrain()
    love.graphics.setCanvas(gameCanvas)
    self:drawUIElements(gameCanvas) --Draw the UI Elements into the canvas

    --Some text //TODO: Move the text later
    rerollText = love.graphics.newText(font, "Rerolls : " ..tostring(self.currentRound.availableRerolls))
    scoreText = love.graphics.newText(font, 'Score : ' ..tostring(0))
    love.graphics.draw(rerollText, 10, 10)
    love.graphics.draw(scoreText, 10, 40)
    love.graphics.setCanvas(gameCanvas)
end

--==ROUND FUNCTIONS==--
function Run:startNewRound()

end

--==DRAW FUNCTIONS==--

function Run:drawTerrain()
    --Dessine le terrain du round actuel(temporaire j'imagine, on verra...)

    --Espace de dés
    self.currentRound.terrain:drawDiceTray(love.graphics.getCanvas():getWidth()-20, 20, self.currentRound.diceFaces)

end

function Run:drawButtons(gameCanvas)
    for key,button in next,self.uiElements.buttons do
        button:draw(gameCanvas)
    end
end

function Run:drawUIElements(gameCanvas)
    --Fonction pour afficher les différents élément d'interface graphique
    self:drawButtons(gameCanvas)--Les boutons
end

--==Inputs functions==

function Run:keypressed(key)
    self.currentRound:keypressed(key)
end

function Run:mousepressed(x, y, button, istouch, presses)
    self.currentRound:mousepressed(x, y, button, istouch, presses)

    --Met les coordonnées de drag à 0
    self.dragOriginX = x ; self.dragOriginY = y

    --Active les actions relatives aux UIElements
    

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end
end

function Run:mousereleased(x, y, button, istouch, presses)
    self.currentRound:mousereleased(x, y, button, istouch, presses)

    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    --Deactivate dragging
    self.isDragging = false
end

function Run:mousemoved(x, y, dx, dy)
    self.currentRound:mousemoved(x, y, dx, dy, self.isDragging)

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