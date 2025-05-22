local Dice = require("src.classes.Dice")
local DiceFace = require("src.classes.ui.DiceFace")
local UIElement = require("src.classes.ui.UIElement")
local Button = require("src.classes.ui.Button")
local Terrain = require("src.classes.ui.Terrain")

local Inputs = require("src.utils.scripts.inputs")

local Run = {
    --Dices variables
    dices = {}, --Dices used id the run
    drawedDices = {}, --Current Drawed Dices
    selectedDices = {}, -- Stores the currently selected dices
    selectedFaces = {}, -- Stores the currently selected faces

    --UI
    uiElements = { -- Stores the UI Elements of the Run
        diceFaces = {},
        buttons = {}
    },
    
    --Drag variables (should rather be located in the Game class i guess...)
    isDragging = false,
    dragOriginX = nil,
    dragOriginY = nil,
    dragDX = 0,
    dragDY = 0,
    draggingTreshold = 10,

    --Gameplay variables
    usedRerolls = 0,
    availableRerolls = 3,

    
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
    self.terrain = Terrain:new()

    print((self.gameCanvas:getWidth()))

    --On créée une première fois les faces à afficher
    for key,dice in next,self.dices do

        diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            dice, --Dice Object 
            1, --Face represented
            key*120 - 40, --X Position (centerd)
            self.terrain.dice_tray:getHeight()-60, --Yposition (centerd)
            80, --Width/Height
            true, --is Selectable
            true, --isHoverable,
            function()return Inputs.getMouseInCanvas((self.gameCanvas:getWidth()-20)-self.terrain.dice_tray:getWidth(), 20)end
        )

        self.uiElements.diceFaces[dice] = diceFaceUI
    end
    
    --Add a button
    self.uiElements.buttons["resetButton"] = Button:new(function()self:resetSelectedDices()end, "src/assets/sprites/ui/buttons/reset.png", love.graphics.getWidth()-125, love.graphics.getHeight()-70, 200, 84)
    self.uiElements.buttons["rerollButton"] = Button:new(function()self:rerollDices()end, "src/assets/sprites/ui/buttons/reroll.png", love.graphics.getWidth()-350, love.graphics.getHeight()-70, 200, 84)

    return self
end

function Run:update(dt)
    --Update Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end

    --Update dices UI
    for key,dice in next,self.uiElements.diceFaces do
        dice:update(dt)
    end

    self.uiElements.buttons["rerollButton"]:setActivated(self.availableRerolls>0 and table.getn(self.selectedDices)>0)
    self.uiElements.buttons["resetButton"]:setActivated(table.getn(self.selectedDices)>0)
end

function Run:draw(gameCanvas) --Render the game into the Game Canvas.
    --Set the right canvas
    self:drawTerrain()
    love.graphics.setCanvas(gameCanvas)
    self:drawUIElements(gameCanvas) --Draw the UI Elements into the canvas

    --Some text //TODO: Move the text later
    rerollText = love.graphics.newText(font, "Rerolls : " ..tostring(self.availableRerolls))
    scoreText = love.graphics.newText(font, 'Score : ' ..tostring(0))
    love.graphics.draw(rerollText, 10, 10)
    love.graphics.draw(scoreText, 10, 40)
    love.graphics.setCanvas(gameCanvas)

    --Debug Text
    mpos = Inputs.getMouseInCanvas((love.graphics.getCanvas():getWidth()-20)-self.terrain.dice_tray:getWidth(), 20)
    xtext = love.graphics.newText(font, 'Position: '..tostring(mpos.x)..'/'..tostring(mpos.y))
    love.graphics.draw(xtext, 10, 90)
end

--==DRAW FUNCTIONS==--

function Run:drawTerrain()
    currentCanvas = love.graphics.getCanvas()
    --Dessine le terrain (temporaire j'imagine, on verra...)

    --Espace de dés
    self.terrain:drawDiceTray(love.graphics.getCanvas():getWidth()-20, 20, self.uiElements.diceFaces)
    --self:drawDrawedDices()

    --love.graphics.draw(self.terrain.dice_tray, love.graphics.getCanvas():getWidth()-20, 20, 0, 1, 1, self.terrain.dice_tray:getWidth(), 0)

end

function Run:drawDrawedDices()
    --Dessine les dés tirés
    if(self.uiElements.diceFaces) then --check si il y a des dés à afficher
        for key,uiFace in next,self.uiElements.diceFaces do
            --currentCanvas = love.graphics.getCanvas()
            --love.graphics.setCanvas(self.terrain.dice_tray)
            uiFace:draw()
            --love.graphics.setCanvas(currentCanvas)
        end
    end
end

function Run:drawButtons(gameCanvas)
    for key,button in next,self.uiElements.buttons do
        button:draw(gameCanvas)
    end
end

function Run:drawUIElements(gameCanvas)
    --Fonction pour afficher les différents élément d'interface graphique
    --self:drawDrawedDices()--Les dés tirés
    self:drawButtons(gameCanvas)--Les boutons
end

--==Inputs functions==

function Run:keypressed(key)
    if(key=="u")then
        print(table.concat(self.selectedFaces, " "))
    end

    if(key=="r") then
        self.availableRerolls = 10
    end
end

function Run:mousepressed(x, y, button, istouch, presses)
    --Met les coordonnées de drag à 0
    self.dragOriginX = x ; self.dragOriginY = y

    --Active les actions relatives aux UIElements
    --DiceFaces
    if(self.uiElements.diceFaces) then --check si il y a des dés à afficher
        for key,uiFace in next,self.uiElements.diceFaces do
            uiFace:clickEvent()
        end
    end

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end
end

function Run:mousereleased(x, y, button, istouch, presses)
    
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    --release event for dice faces
    for key,diceface in next,self.uiElements.diceFaces do
        wasReleased = diceface:releaseEvent()
        if(wasReleased)then
            self:updateSelectedDices(diceface)
        end
        diceface.isBeingDragged = false
    end

    --Deactivate dragging
    self.isDragging = false
end

function Run:mousemoved(x, y, dx, dy)
    --x et y sont la position, dx et dy sont la vitesse.

    if(love.mouse.isDown(1) and self.dragOriginX and self.dragOriginY) then

        if( --sets dragging state
        math.abs(love.mouse.getX() - self.dragOriginX) > self.draggingTreshold
        or math.abs(love.mouse.getY() - self.dragOriginY) > self.draggingTreshold) then
            self.isDragging = true
        end
    end

    --Drag and drop dice
    if(self.isDragging == true)then 
        for key,diceui in next, self.uiElements.diceFaces do
            if(diceui.isDraggable and diceui.isBeingClicked) then
                diceui.isBeingDragged = true
                diceui.dragXspeed = dx
                diceui:setX(diceui:getX() + dx)
                diceui:setY(diceui:getY() + dy)
            end
        end
    end

end


--==Dices Functions==

function Run:setDrawedDices(draw)
    self.drawedDices = draw
end

function Run:rerollDices() --Triggers the makeRoll function after clicking the reroll button
    if(self.availableRerolls > 0) then
        self:makeRoll(self.selectedDices)
        self.availableRerolls = self.availableRerolls-1
    end
end

function Run:drawDices(dices)
    --Tire uniquement les dés donnés en paramètre et retourne une table avec comme clé les dés et en valeur le numéro de face tiré.

    local faceNumbers = self.drawedDices --On récupère les dés précédemment tirés.

    for key,dice in next,dices do
        if self:containsDice(dices, dice) then
            n = math.random(1, dice:getNbFaces())
            faceNumbers[dice] = n
        end
    end

    return faceNumbers
end

function Run:updateSelectedDices(uiFace)
    --si le dé donné en paramètre est sélectionné et pas encore dans la liste, on l'ajoute à la fin de la liste.
    --si il est sélectionné mais pas dans la liste, on le laisse
    --si il est désélectionné et dans la liste, on le retire.

    if(uiFace:getIsSelected())then -- Dé sélectionné
        if(not self:containsDice(self.selectedDices, uiFace:getDice()))then
            table.insert(self.selectedDices, uiFace:getDice()) -- Ajoute le dé à la fin-
            table.insert(self.selectedFaces, uiFace:getFace()) -- Ajoute le numéro de face
        end
    else
        if(self:containsDice(self.selectedDices, uiFace:getDice())) then -- Dé non sélectionné
            for i, dice in ipairs(self.selectedDices) do
                if dice == uiFace:getDice() then
                    table.remove(self.selectedDices, i) --Trouve le dé dans la liste et le supprime
                    table.remove(self.selectedFaces, i)
                    break
                end
            end
        end
    end
end

function Run:containsDice(diceList, targetDice)
    --Fonction pour vérifier qu'un élément est dans une liste
  for _, dice in ipairs(diceList) do
    if dice == targetDice then
      return true
    end
  end
  return false
end

function Run:resetSelectedDices()
    self.selectedDices = {} --remove the dices
    self.selectedFaces = {} --remove the face numbers
    for key,uiFace in next,self.uiElements.diceFaces do --unselect the UI Faces
        uiFace:setSelected(false)
    end
end

function Run:makeRoll(dices)
    draw = self:drawDices(dices) --draw the dices
    self:setDrawedDices(draw) --stores the draw
    self:resetSelectedDices() --reset the previously selected dices (ui)

    for key,dice in next,self.dices do
        self.uiElements.diceFaces[dice]:setFace(self.drawedDices[dice]) --update the ui
    end
end

return Run