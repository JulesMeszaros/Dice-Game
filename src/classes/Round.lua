local DiceFace = require("src.classes.ui.DiceFace")
local RoundScreen = require("src.screens.RoundScreen")

local Inputs = require("src.utils.scripts.inputs")

local Round = {
    diceFaces = {},
    drawedDices = {},
    selectedDices = {},
    selectedFaces = {},

    dragOriginX = nil,
    dragOriginY = nil,

    remainingHands = 5,

    roundScore = 0
}
Round.__index = Round

function Round.new(n, dices, gameCanvas, run)
    local self = setmetatable({}, Round)

    self.run = run
    self.gameCanvas = gameCanvas

    --Current Round Parameters
    self.nround = n
    self.availableRerolls = 3
    self.dices = dices
    self.targetScore = 80 + 20*(n-1) --Calcul à revoir bien sur

    self.terrain =  RoundScreen:new(self)

    --On créée une première fois les faces à afficher
    for key,dice in next,self.dices do

        local diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            dice, --Dice Object 
            1, --Face represented
            (key*80) - 30, --X Position (centerd)
            self.terrain.dice_tray:getHeight()-60, --Yposition (centerd)
            64*1.5, --Width/Height
            true, --is Selectable
            true, --isHoverable,
            function()return Inputs.getMouseInCanvas((self.gameCanvas:getWidth()-20)-self.terrain.dice_tray:getWidth(), 20)end,
            self.terrain.dice_tray
        )

        self.diceFaces[dice] = diceFaceUI
    end

    return self
end

function Round:update(dt)
    self.terrain:update(dt)
end

--==ROUND FUNCTION==--
function Round:endRound()
    self.run:endRound()
end

--==MOUSE/KEYBOARD FUNCTIONS==--

function Round:keypressed(key)
    if(key=="u")then
        print(table.concat(self.selectedFaces, " "))
    end

    if(key=='h')then
        self.remainingHands = self.remainingHands + 10
    end

    if(key=="r") then
        self.availableRerolls = 10
    end

    if(key=="t") then --trigger the trigger animation of the dicefaces
        for j,df in next,self.diceFaces do
            df:trigger()
        end
    end
end

function Round:mousepressed(x, y, button, istouch, presses)
    --DiceFaces
    for key,uiFace in next,self.diceFaces do
        uiFace:clickEvent()
    end

    --Round Buttons
    for key,button in next,self.terrain.uiElements.roundButtons do
        button:clickEvent()
    end

    --Figure Buttons
    for key,button in next,self.terrain.figureButtons do
        button:clickEvent()
    end
end

function Round:mousereleased(x, y, button, istouch, presses)
    --release event for dice faces
    for key,diceface in next,self.diceFaces do
        local wasReleased = diceface:releaseEvent()
        if(wasReleased)then
            self:updateSelectedDices(diceface)
        end
        diceface.isBeingDragged = false
    end

    --release event on UI elements (buttons)
    for key,button in next,self.terrain.uiElements.roundButtons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    --release event on UI elements (figure buttons)
    for key,button in next,self.terrain.figureButtons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end
end

function Round:mousemoved(x, y, dx, dy, isDragging)
    --Drag and drop dice
    if(isDragging == true)then 
        for key,diceui in next, self.diceFaces do
            if(diceui.isDraggable and diceui.isBeingClicked) then
                diceui.isBeingDragged = true
                diceui.dragXspeed = dx
                if(diceui.targetX+dx<diceui.renderCanvas:getWidth()-diceui.size/2 and diceui.targetX+dx>0+diceui.size/2) then --Vérification qu'on ne dépasse par les limites horizontales
                    diceui.targetX = (diceui.targetX + dx) 
                end

                if(diceui.targetY+dy<diceui.renderCanvas:getHeight()-diceui.size/2 and diceui.targetY+dy>0+diceui.size/2) then --Vérification qu'on ne dépasse pas les limites verticales
                    diceui.targetY = (diceui.targetY + dy) 
                end
            end
        end
    end
end

--==DICE FUNCTIONS==--

function Round:updateSelectedDices(uiFace)
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

--==REROLL FUNCTIONS==--

function Round:rerollDices() --Triggers the makeRoll function after clicking the reroll button
    if(self.availableRerolls > 0) then
        self:makeRoll(self.selectedDices)
        self.availableRerolls = self.availableRerolls-1
    end
end

function Round:makeRoll(dices)
    local draw = self:drawDices(dices) --draw the dices
    self:setDrawedDices(draw) --stores the draw
    self:resetSelectedDices() --reset the previously selected dices (ui)

    for key,dice in next,self.dices do
        self.diceFaces[dice]:setFace(self.drawedDices[dice]) --update the ui
    end

    for key,dice in next,dices do --Creates the roll animation for the rerolled dices

        local randomXPos = math.random(100, self.diceFaces[dice].renderCanvas:getWidth()-100)
        local randomYPos = math.random(100, self.diceFaces[dice].renderCanvas:getHeight()-100)
        local randomR = ((math.random(0,1000)/1000)*2.5)-1.25 --(1001 angles possibles entre -1.25 et 1.25 radians)

        --Set initial position (random X axis, under the terrain)
        self.diceFaces[dice]:setX(randomXPos)
        self.diceFaces[dice]:setY(1000)
        self.diceFaces[dice].rotation = 0

        --Change their target position to make them slide
        self.diceFaces[dice].targetX = randomXPos
        self.diceFaces[dice].targetY = randomYPos
        self.diceFaces[dice].baseRotation = randomR

    end

end

function Round:drawDices(dices)
    --Tire uniquement les dés donnés en paramètre et retourne une table avec comme clé les dés et en valeur le numéro de face tiré.

    local faceNumbers = self.drawedDices --On récupère les dés précédemment tirés.

    for key,dice in next,dices do
        local n = math.random(1, dice:getNbFaces())
        faceNumbers[dice] = n
    end

    return faceNumbers
end

function Round:setDrawedDices(draw)
    self.drawedDices = draw
end

--==FIGURE FUNCTIONS==--
function Round:playFigure(points) --Function that triggers the hand
    self.roundScore = self.roundScore + points -- On ajoute les points au score
    
    if(self.remainingHands>=1)then
        self.remainingHands = self.remainingHands - 1 -- On retire une main aux mains disponibles
        self:makeRoll(self.dices) -- On effectue un reroll
        self.availableRerolls = 3
    end

    if(self.roundScore >= self.targetScore or self.remainingHands == 0) then
        self:endRound()
    end
end

--==UTILS==--

function Round:resetSelectedDices()
    self.selectedDices = {} --remove the dices
    self.selectedFaces = {} --remove the face numbers
    for key,uiFace in next,self.diceFaces do --unselect the UI Faces
        uiFace:setSelected(false)
    end
end

function Round:containsDice(diceList, targetDice)
    --Fonction pour vérifier qu'un élément est dans une liste
  for _, dice in ipairs(diceList) do
    if dice == targetDice then
      return true
    end
  end
  return false
end

return Round