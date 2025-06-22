local Constants = require("src.utils.constants")
local DiceFace = require("src.classes.ui.DiceFace")
local RoundScreen = require("src.screens.RoundScreen")
local AnimationUtils = require("src.utils.scripts.animationUtils")

local Inputs = require("src.utils.scripts.inputs")

local Round = {}
Round.__index = Round

function Round:new(n, floor, desk, gameCanvas, run, baseReward, target, diceObjects, roundType, faceRewards)
    local self = setmetatable({}, Round)

    self.selectedDices = {}
    self.drawedFaceObjects = {}

    self.dragOriginX = nil
    self.dragOriginY = nil
    self.remainingHands = 4
    self.roundScore = 0
    self.faceRewards = faceRewards

    --==Triggering Phase==--
    self.phase = Constants.ROUND_STATES.PLAYING
    self.diceFacesOrder = {} --Base order when the hand is played. doenst get modified during the phase and is used to construct the queue
    self.dicesOrder = {} --Same but for the dice objects
    self.diceFacesTriggerQueue = {} --Dice queue for the triggers. get modified during the trigger phase
    self.dicesTriggerQueue = {}  --Same but for the dices
    self.currentlyTriggeredDice = nil
    self.diceFaces = {}
    self.baseReward = baseReward
    self.triggerDiceHistory = {}
    self.triggerFaceHistory = {}

    self.run = run
    self.gameCanvas = gameCanvas

    --Current Round Parameters
    self.nround = n
    self.floorNumber = floor
    self.deskNumber = desk
    self.roundType = roundType
    self.availableRerolls = Constants.BASE_REROLLS

    --Ennemy metadata
    if(self.roundType == Constants.ROUND_TYPES.BASE) then
        self.enemyJob = Constants.EMPLOIS[math.random(#Constants.EMPLOIS)]
    else
        self.enemyJob = "Manager"
    end

    --Ciggies
    self.ciggiesObjects = self.run.ciggiesObjects

    --Dices
    self.diceObjects = diceObjects
    self.targetScore = target or (0 + 20*(n-1)) --Calcul à revoir bien sur

    self.terrain = RoundScreen:new(self)

    --On créé des objets pour les nouveaux diceFaces
    for key,diceobject in next,self.diceObjects do

        local diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            diceobject, --Dice Object 
            diceobject:getFace(1), --La face représentée
            self.terrain.canvas:getWidth()/2, --X Position (centerd)
            self.terrain.canvas:getHeight()+70, --Yposition (centerd)
            120, --Width/Height
            true, --is Selectable
            true, --isHoverable,
            function()return Inputs.getMouseInCanvas(510 , 320)end,
            self
        )

        self.diceFaces[diceobject] = diceFaceUI
    end



    return self
end

function Round:update(dt)
    self.terrain:update(dt)
end

--==ROUND FUNCTION==--
function Round:endRound()
    self.terrain:outAnimation()
end

--==MOUSE/KEYBOARD FUNCTIONS==--

function Round:keypressed(key) --(Mainly for debug)
    if(key=='h')then
        self.remainingHands = self.remainingHands + 10
    end

    if(key=="r") then
        self.availableRerolls = 10
    end

    if(key=="g")then
        for i,v in next,self.terrain.uiElements.ciggiesUI do
            print(i)
        end
    end

    if(key=='a')then
        self.roundScore = 10000000
        self.terrain:outAnimation()
    end
end

function Round:mousepressed(x, y, button, istouch, presses)
    --DiceFaces
    for key,uiFace in next,self.diceFaces do
        uiFace:clickEvent()
    end

    --Ciggies
    for key,ciggie in next,self.terrain.uiElements.ciggiesUI do
        ciggie:clickEvent()
    end

    --Round Buttons
    for key,button in next,self.terrain.uiElements.roundButtons do
        button:clickEvent()
    end

    --Figure buttons
    self.terrain.clickedFigure = self.terrain:getCurrentlyHoveredLine()
end

function Round:mousereleased(x, y, button, istouch, presses)
    --release event for dice faces

    for key,diceface in next,self.diceFaces do
        local wasReleased = diceface:releaseEvent()
        if(wasReleased)then
            self:updateselectedDices(diceface)
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

    --Figure buttons
    if(self.terrain.clickedFigure)then
        if(self.terrain.clickedFigure == self.terrain:getCurrentlyHoveredLine())then
            self.terrain.calculatePointsFunctions[self.terrain.clickedFigure]()
        end
    end

    --Ciggies
    for key,ciggie in next,self.terrain.uiElements.ciggiesUI do
        ciggie:releaseEvent()
        ciggie:detectBelowCanvas(self)
        ciggie.isBeingDragged = false
    end
end

function Round:mousemoved(x, y, dx, dy, isDragging)
    --Drag and drop dice
    if(isDragging == true)then 
        for key,diceui in next, self.diceFaces do
            if(diceui.isDraggable and diceui.isBeingClicked) then
                diceui.isBeingDragged = true
                diceui.dragXspeed = dx
                if(diceui.targetX+dx<self.terrain.dice_tray:getWidth()-diceui.size/2 and diceui.targetX+dx>0+diceui.size/2) then --Vérification qu'on ne dépasse par les limites horizontales
                    diceui.targetX = (diceui.targetX + dx) 
                end

                if(diceui.targetY+dy<self.terrain.dice_tray:getHeight()-diceui.size/2-85 and diceui.targetY+dy>165+diceui.size/2) then --Vérification qu'on ne dépasse pas les limites verticales
                    diceui.targetY = (diceui.targetY + dy) 
                end
            end
        end
    end
    --Drag and drop Ciggies
    if(isDragging == true)then 
        for key,ciggie in next, self.terrain.uiElements.ciggiesUI do
            if(ciggie.isDraggable and ciggie.isBeingClicked) then
                ciggie.isBeingDragged = true
                ciggie.dragXspeed = dx
                if(ciggie.targetX+dx<self.terrain.canvas:getWidth()-ciggie.width/2 and ciggie.targetX+dx>0+ciggie.width/2) then --Vérification qu'on ne dépasse par les limites horizontales
                    ciggie.targetX = (ciggie.targetX + dx) 
                end

                if(ciggie.targetY+dy<self.terrain.canvas:getHeight()-ciggie.height/2 and ciggie.targetY+dy>0+ciggie.height/2) then --Vérification qu'on ne dépasse pas les limites verticales
                    ciggie.targetY = (ciggie.targetY + dy) 
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
        table.insert(diceFaces, self.diceFaces[dice])
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
        table.insert(sortedDiceFaces, self.diceFaces[d])
    end

    --Ajout aux attributs de classe
    for i, diceFace in next,sortedDiceFaces do
        table.insert(self.diceFacesOrder, diceFace)
    end

    for i, diceFace in next,sortedDices do
        table.insert(self.dicesOrder, diceFace)
    end

    return sortedDiceFaces, sortedDices
end

function Round:startTriggeringPhase(usedDices)
    self.phase = Constants.ROUND_STATES.TRIGGERING
    self.triggerDiceHistory = {}
    self.triggerFaceHistory = {}
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
        --On déclenche le dé
        self.diceFacesTriggerQueue[1]:trigger(self)
        --self.dicesTriggerQueue[1]:trigger(self)
            
        --On ajoute à l'historique (en dernière position)
        table.insert(self.triggerDiceHistory, self.dicesTriggerQueue[1])
        table.insert(self.triggerFaceHistory, self.diceFacesTriggerQueue[1])

        --On retire de la file
        table.remove(self.diceFacesTriggerQueue, 1)
        table.remove(self.dicesTriggerQueue, 1) 

    else --ends the trigger phase
        --Recall the dices
        local j = 0
        for i,diceface in next,self.diceFaces do
            j = j+1
            print(j)
            if(j==5)then
                diceface.animator:add("y", diceface.y, diceface.y-20, 0.1)
                diceface.animator:add("y", diceface.y-20, 1000, 0.2)
                diceface.animator:addDelay(0.2, function()self:endTriggeringPhase()end)
            else
                diceface.animator:add("y", diceface.y, diceface.y-20, 0.1)
                diceface.animator:add("y", diceface.y-20, 1000, 0.2)
                diceface.animator:addDelay(0.2)
            end
        end        
    end
end

function Round:endTriggeringPhase()
    self.phase = Constants.ROUND_STATES.PLAYING
    print("done triggering!!!")

    if(self.remainingHands>=1)then
        self.remainingHands = self.remainingHands - 1 -- On retire une main aux mains disponibles
        self:resetselectedDices()
        self:makeRoll(self.diceObjects) -- On effectue un reroll
        self.availableRerolls = Constants.BASE_REROLLS
    end

    if(self.roundScore >= self.targetScore or self.remainingHands == 0) then
        self:endRound()
    end
end

--==DICE FUNCTIONS==--

function Round:updateselectedDices(uiFace)
    --si le dé donné en paramètre est sélectionné et pas encore dans la liste, on l'ajoute à la fin de la liste.
    --si il est sélectionné mais pas dans la liste, on le laisse
    --si il est désélectionné et dans la liste, on le retire.

    if(uiFace:getIsSelected())then -- Dé sélectionné
        if(not self:containsDice(self.selectedDices, uiFace:getDiceObject()))then
            table.insert(self.selectedDices, uiFace:getDiceObject()) -- Ajoute le dé à la fin-
        end
    else
        if(self:containsDice(self.selectedDices, uiFace:getDiceObject())) then -- Dé non sélectionné
            for i, dice in ipairs(self.selectedDices) do
                if dice == uiFace:getDiceObject() then
                    table.remove(self.selectedDices, i) --Trouve le dé dans la liste et le supprime
                    break
                end
            end
        end
    end

    --Update the selected dices position
    self.terrain:updateSelectedPosDices()
end

--==REROLL FUNCTIONS (NEW)==--
function Round:rerollDices() --Triggers the makeRoll function after clicking the reroll button
    local dicesToReroll = {}
    for k,d in next,self.diceObjects do
        if not self:containsDice(self.selectedDices, d) then
            table.insert(dicesToReroll, d)
        end
    end

    if(self.availableRerolls > 0) then
        self:makeRoll(dicesToReroll)
        self.availableRerolls = self.availableRerolls-1
    end
end

function Round:makeRoll(dices)
    local draw = self:drawDices(dices) --draw the dices
    for key,dice in next,self.diceObjects do
        dice:setCurrentFaceObject(self.drawedFaceObjects[dice])
        self.diceFaces[dice]:setFaceObject(self.drawedFaceObjects[dice]) --update the ui
    end

    local rerolledDiceFaces = {}
    for k,d in next,dices do
        rerolledDiceFaces[d] = self.diceFaces[d]
    end

    for key,dice in next,dices do --Creates the roll animation for the rerolled dices

        local randomXPos = math.random(80, self.terrain.dice_tray:getWidth()-80)
        local randomYPos = math.random(220, self.terrain.dice_tray:getHeight()-150)
        local randomR = ((math.random(0,1000)/1000)*5)-2.5 --(1001 angles possibles entre -2.5 et 5 radians)

        --Todo: remplacer le code suivant par une animation Animator

        --Set initial position (random X axis, under the terrain)
        self.diceFaces[dice]:setX(self.terrain.dice_tray:getWidth()/2)
        --self.diceFaces[dice].targetX = 2000
        self.diceFaces[dice]:setY(self.terrain.dice_tray:getHeight()+100)
        --self.diceFaces[dice].targetY = 2000
        self.diceFaces[dice].rotation = 0

        --Add an animation to make them roll
        self.diceFaces[dice].animator:addGroup({
            {property = "x", from=self.terrain.canvas:getWidth()/2, targetValue = randomXPos, duration = 0.5, onComplete=function()end, easing=AnimationUtils.Easing.outCubic},
            {property = "targetX", from=self.terrain.canvas:getWidth()/2, targetValue = randomXPos, duration = 0.5, onComplete=function()end},
            {property = "y", from=self.terrain.canvas:getHeight()+100, targetValue = randomYPos, duration = 0.5, onComplete=function()end, easing=AnimationUtils.Easing.outCubic},
            {property = "targetY", from=self.terrain.canvas:getHeight()+100, targetValue = randomYPos, duration = 0.5, onComplete=function()end},
            {property = "rotation", from=-0, targetValue = randomR, duration = 0.5, onComplete=function()end, easing=AnimationUtils.Easing.outCubic},
            {property = "baseRotation", from=-0, targetValue = randomR, duration = 0.5, onComplete=function()end, easing=AnimationUtils.Easing.outCubic},

        })

        self.diceFaces[dice].animator:addDelay(0.4, function()self.terrain:reorganiseDiceFaces(rerolledDiceFaces)end)
    end

end 

function Round:drawDices(dices)
    --Tire uniquement les dés donnés en paramètre et retourne une table avec comme clé les dés et en valeur le numéro de face tiré.

    local faceObjects = self.drawedFaceObjects

    for key,dice in next,dices do
        local n = math.random(1, dice:getNbFaces()) --Prend un index dans les faces du dé
        local faceObject = dice:getFace(n)
        faceObjects[dice] = faceObject
    end
    --Retourne les indexes des faces dans l'objet dé
    self.drawedFaceObjects = faceObjects--Sets the drawed face objects
end

--==FIGURE FUNCTIONS==--
function Round:playFigure(points, usedDices) --Function that triggers the hand
    self:startTriggeringPhase(usedDices)

    self.roundScore = self.roundScore + points -- On ajoute les points au score
end

--==UTILS==--
function Round:getUnSelectedDices()
    local unSelectedDices = {}
    for i,dice in next,self.diceObjects do
        local selected = false
        for d,diceFace in next,self.selectedDices do
            if(d==dice)then selected = true end
        end
        if(selected==false)then
            unSelectedDices[dice] = self.diceFaces[dice]
        end
    end 
    return unSelectedDices
end

function Round:addToScore(n)
    self.roundScore = self.roundScore + n
end

function Round:resetselectedDices()
    self.selectedDices = {} --remove the dices
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