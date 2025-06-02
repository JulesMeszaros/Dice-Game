local DiceFace = require("src.classes.ui.DiceFace")
local RoundScreen = require("src.screens.RoundScreen")

local Inputs = require("src.utils.scripts.inputs")

local Round = {}
Round.__index = Round

function Round:new(n, gameCanvas, run, baseReward, target, diceObjects)
    local self = setmetatable({}, Round)

    self.drawedDices = {}
    self.drawedDices2 = {}

    self.selectedDices = {}
    self.selectedFaces = {}

    self.selectedDices2 = {}
    self.selectedFaces2 = {}

    self.dragOriginX = nil
    self.dragOriginY = nil
    self.remainingHands = 5
    self.roundScore = 0

    --==Triggering Phase==--
    self.triggeringPhase = false
    self.diceFacesOrder = {} --Base order when the hand is played. doenst get modified during the phase and is used to construct the queue
    self.dicesOrder = {} --Same but for the dice objects
    self.diceFacesTriggerQueue = {} --Dice queue for the triggers. get modified during the trigger phase
    self.dicesTriggerQueue = {}  --Same but for the dices
    self.currentlyTriggeredDice = nil
    self.diceFaces = {}
    self.diceFaces2 = {}
    self.baseReward = baseReward

    self.run = run
    self.gameCanvas = gameCanvas

    --Current Round Parameters
    self.nround = n
    self.availableRerolls = 3

    --Dices
    self.diceObjects = diceObjects
    self.targetScore = target or (0 + 20*(n-1)) --Calcul à revoir bien sur

    self.terrain = RoundScreen:new(self)

    --On créé des objets pour les nouveaux diceFaces
    for key,diceobject in next,self.diceObjects do

        local diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            diceobject, --Dice Object 
            1, --Face represented
            (key*80) - 30, --X Position (centerd)
            self.terrain.dice_tray:getHeight()-60, --Yposition (centerd)
            90*1.5, --Width/Height
            true, --is Selectable
            true, --isHoverable,
            function()return Inputs.getMouseInCanvas((self.gameCanvas:getWidth()-20)-self.terrain.dice_tray:getWidth(), 20)end,
            self
        )

        self.diceFaces2[diceobject] = diceFaceUI
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

function Round:keypressed(key) --(Mainly for debug)
    if(key=="u")then
        print(table.concat(self.selectedFaces, " "))
    end

    if(key=='h')then
        self.remainingHands = self.remainingHands + 10
    end

    if(key=="r") then
        self.availableRerolls = 10
    end
end

function Round:mousepressed(x, y, button, istouch, presses)
    --DiceFaces
    for key,uiFace in next,self.diceFaces do
        uiFace:clickEvent()
    end
    for key,uiFace in next,self.diceFaces2 do
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

    for key,diceface in next,self.diceFaces2 do
        local wasReleased = diceface:releaseEvent()
        if(wasReleased)then
            self:updateSelectedDices2(diceface)
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

        for key,diceui in next, self.diceFaces2 do
            if(diceui.isDraggable and diceui.isBeingClicked) then
                diceui.isBeingDragged = true
                diceui.dragXspeed = dx
                if(diceui.targetX+dx<self.terrain.dice_tray:getWidth()-diceui.size/2 and diceui.targetX+dx>0+diceui.size/2) then --Vérification qu'on ne dépasse par les limites horizontales
                    diceui.targetX = (diceui.targetX + dx) 
                end

                if(diceui.targetY+dy<self.terrain.dice_tray:getHeight()-diceui.size/2 and diceui.targetY+dy>0+diceui.size/2) then --Vérification qu'on ne dépasse pas les limites verticales
                    diceui.targetY = (diceui.targetY + dy) 
                end
            end
        end
    end
end

--==TRIGGERING PHASE==--
function Round:getDicesOrder(usedDices)
    --[[
    Cette fonction permet de récupèrer les dés dans l'ordre de trigger
    -> Retourne une liste des dés dans l'ordre à trigger
    L'ordre est le suivant : de gauche à droite et de bas en haut
    ]]

    -- Reset les listes précédentes
    self.diceFacesOrder = {} 
    self.dicesOrder = {} 
    self.diceFacesTriggerQueue = {}
    self.dicesTriggerQueue = {}
    
    --Créée deux listes
    local diceFaces = {}
    local dices = {}

    for i, dice in next,usedDices do
        print(dice)
        table.insert(diceFaces, self.diceFaces2[dice])
        table.insert(dices, dice)
    end
    
    local indexes = {} --Liste d'indexes servant de base pour le tri des dés et des dicefaces
    --Remplissage des indexes
    for i=1, table.getn(usedDices) do
        table.insert(indexes, i)
    end
    -- Trie des indexes
    table.sort(indexes, function(a, b)
        local da = diceFaces[a]
        local db = diceFaces[b]

        if(da.targetX ~= db.targetX)then
            return da.targetX < db.targetX
        elseif da.targetY ~= db.targetY then
            return da.targetY < db.targetY
        end
    end)

    -- Trie les dés à partir des indexes
    local sortedDices = {}
    for i,index in ipairs(indexes) do
        table.insert(sortedDices, dices[index])
    end

    -- Trie les DiceFaces à partir des dés triés
    local sortedDiceFaces = {}
    for k,d in next,sortedDices do
        table.insert(sortedDiceFaces, self.diceFaces2[d])
    end

    --Ajout aux attributs de classe
    for i, diceFace in next,sortedDiceFaces do
        table.insert(self.diceFacesOrder, diceFace)
    end

    for i, diceFace in next,sortedDices do
        table.insert(self.dicesOrder, diceFace)
    end

    for k,v in ipairs(sortedDiceFaces) do
        print(v.faceNumber)
    end

    return sortedDiceFaces, sortedDices
end

function Round:startTriggeringPhase(usedDices)
    self.triggeringPhase = true --Start triggering phase
    --Creates the list of dices to trigger, sorted according to their position on the terrain
    local sortedDiceFaces, sortedDices = self:getDicesOrder(usedDices)

    --Create the dice face trigger queue
    for k,df in next,sortedDiceFaces do
        table.insert(self.diceFacesTriggerQueue, df) --Copie la liste dans trigger Queue
    end

    --Create the dice trigger queue
    for k,d in next,sortedDices do
        table.insert(self.dicesTriggerQueue, d) --Copie la liste dans trigger Queue
    end

    --Triggers the first dice
    self:triggerNextDice()
end

function Round:triggerNextDice()
    if(table.getn(self.dicesTriggerQueue)>=1) then
        self.diceFacesTriggerQueue[1]:trigger()
        self.dicesTriggerQueue[1]:trigger(self)
        table.remove(self.diceFacesTriggerQueue, 1)
        table.remove(self.dicesTriggerQueue, 1)
    else --ends the trigger phase
        self:endTriggeringPhase()
    end
end

function Round:endTriggeringPhase()
    self.triggeringPhase = false
    print("done triggering!!!")

    if(self.remainingHands>=1)then
        self.remainingHands = self.remainingHands - 1 -- On retire une main aux mains disponibles
        self:makeRoll2(self.diceObjects) -- On effectue un reroll
        self.availableRerolls = 3
    end

    if(self.roundScore >= self.targetScore or self.remainingHands == 0) then
        self:endRound()
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

function Round:updateSelectedDices2(uiFace)
    --si le dé donné en paramètre est sélectionné et pas encore dans la liste, on l'ajoute à la fin de la liste.
    --si il est sélectionné mais pas dans la liste, on le laisse
    --si il est désélectionné et dans la liste, on le retire.

    if(uiFace:getIsSelected())then -- Dé sélectionné
        if(not self:containsDice(self.selectedDices2, uiFace:getDiceObject()))then
            table.insert(self.selectedDices2, uiFace:getDiceObject()) -- Ajoute le dé à la fin-
            table.insert(self.selectedFaces2, uiFace:getDiceObject()) -- Ajoute le numéro de face
        end
    else
        if(self:containsDice(self.selectedDices2, uiFace:getDiceObject())) then -- Dé non sélectionné
            for i, dice in ipairs(self.selectedDices2) do
                if dice == uiFace:getDiceObject() then
                    table.remove(self.selectedDices2, i) --Trouve le dé dans la liste et le supprime
                    table.remove(self.selectedFaces2, i)
                    break
                end
            end
        end
    end
end

--==REROLL FUNCTIONS (NEW)==--
function Round:rerollDices2() --Triggers the makeRoll function after clicking the reroll button
    if(self.availableRerolls > 0) then
        self:makeRoll2(self.selectedDices2)
        self.availableRerolls = self.availableRerolls-1
    end
end

function Round:makeRoll2(dices)
    local draw = self:drawDices2(dices) --draw the dices
    self:setDrawedDices2(draw) --stores the draw
    self:resetSelectedDices2() --reset the previously selected dices (ui)

    for key,dice in next,self.diceObjects do
        dice:setCurrentActiveFace(self.drawedDices2[dice])
        self.diceFaces2[dice]:setFace(self.drawedDices2[dice]) --update the ui
    end

    for key,dice in next,dices do --Creates the roll animation for the rerolled dices

        local randomXPos = math.random(100, self.terrain.dice_tray:getWidth()-100)
        local randomYPos = math.random(100, self.terrain.dice_tray:getHeight()-100)
        local randomR = ((math.random(0,1000)/1000)*2.5)-1.25 --(1001 angles possibles entre -1.25 et 1.25 radians)

        --Set initial position (random X axis, under the terrain)
        self.diceFaces2[dice]:setX(randomXPos)
        self.diceFaces2[dice]:setY(1000)
        self.diceFaces2[dice].rotation = 0

        --Change their target position to make them slide
        self.diceFaces2[dice].targetX = randomXPos
        self.diceFaces2[dice].targetY = randomYPos
        self.diceFaces2[dice].baseRotation = randomR
    end
end 

function Round:drawDices2(dices)
    --Tire uniquement les dés donnés en paramètre et retourne une table avec comme clé les dés et en valeur le numéro de face tiré.

    local faceNumbers = self.drawedDices2 --On récupère les dés précédemment tirés.
    
    for key,dice in next,dices do
        local n = math.random(1, dice:getNbFaces())
        faceNumbers[dice] = n 
    end
    --Retourne les indexes des faces dans l'objet dé
    return faceNumbers
end

function Round:setDrawedDices2(draw)
    self.drawedDices2 = draw
end

--==FIGURE FUNCTIONS==--
function Round:playFigure(points, usedDices) --Function that triggers the hand
    self:startTriggeringPhase(usedDices)

    self.roundScore = self.roundScore + points -- On ajoute les points au score
end

--==UTILS==--
function Round:addToScore(n)
    self.roundScore = self.roundScore + n
end

function Round:resetSelectedDices()
    self.selectedDices = {} --remove the dices
    self.selectedFaces = {} --remove the face numbers
    for key,uiFace in next,self.diceFaces do --unselect the UI Faces
        uiFace:setSelected(false)
    end
end

function Round:resetSelectedDices2()
    self.selectedDices2 = {} --remove the dices
    self.selectedFaces2 = {} --remove the face numbers
    for key,uiFace in next,self.diceFaces2 do --unselect the UI Faces
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