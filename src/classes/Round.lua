local Constants = require("src.utils.Constants")
local DiceFace = require("src.classes.ui.DiceFace")
local RoundScreen = require("src.screens.RoundScreen")
local AnimationUtils = require("src.utils.scripts.Animations")
local Inputs = require("src.utils.scripts.Inputs")
local Animator = require("src.utils.Animator")
local EndRound = require("src.classes.ui.EndRound")
local GameOverScreen = require("src.screens.GameOverScreen")
local Lion = require("src.classes.ui.Lion")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")


local Round = {}
Round.__index = Round

function Round:new(n, floor, desk, gameCanvas, run, baseReward, target, diceObjects, roundType, faceRewards)
    local self = setmetatable({}, Round)

    self.animator = Animator:new(self)
    self.selectedDices = {}
    self.drawedFaceObjects = {}

    self.dragOriginX = nil
    self.dragOriginY = nil
    self.remainingHands = Constants.BASE_TURNS
    self.roundScore = 0
    self.faceRewards = faceRewards

    --==Triggering Phase==--
    self.handScore = 0
    self.phase = Constants.ROUND_STATES.PLAYING
    self.diceFacesOrder = {} --Base order when the hand is played. doenst get modified during the phase and is used to construct the queue
    self.dicesOrder = {} --Same but for the dice objects
    self.diceFacesTriggerQueue = {} --Dice queue for the triggers. get modified during the trigger phase
    self.dicesTriggerQueue = {}  --Same but for the dices
    self.diceFacesBackupQueue = {} --Dice queue for the triggers. get modified during the trigger phase
    self.dicesBackupQueue = {}  --Same but for the dices
    
    self.currentlyTriggeredDice = nil
    self.diceFaces = {}
    self.baseReward = baseReward
    self.ciggieReward = GenerateRandom.CiggieObject()
    self.triggerDiceHistory = {}
    self.triggerFaceHistory = {}

    self.run = run
    self.gameCanvas = gameCanvas

    --Current Round Parameters
    self.firstRoll = false
    self.nround = n
    self.floorNumber = floor
    self.deskNumber = desk
    self.roundType = roundType
    self.availableRerolls = Constants.BASE_REROLLS

    --Choix du type de manager
    if(self.roundType == Constants.ROUND_TYPES.BOSS)then
        self.bossType = Constants.BOSS_TYPES.CHEF_COMPTABLE
    end

    if(self.bossType==Constants.BOSS_TYPES.CHEF_RD) then
        self.remainingHands = self.remainingHands + self.availableRerolls
        self.availableRerolls = 0
    end

    --Ennemy metadata
    self.enemyCharacter = Lion:new()
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

    return self
end

function Round:update(dt)
    self.animator:update(dt)

    --update le terrain
    self.terrain:update(dt)

end

--==ROUND FUNCTION==--
function Round:endRound()
    for i,d in next,self.diceObjects do
        for j,f in next,d:getAllFaces() do
            f:resetStats()
        end
    end
        
    if(self.roundScore >= self.targetScore)then
        --CREATE A END ROUND SCREEN
        self.terrain.endRoundPopUp = EndRound:new(self.run, self)
        
        self.phase = Constants.ROUND_STATES.END_ROUND
    else
        local gameOver = GameOverScreen:new(self.run.gameCanvas, self.run)
        self.run.gameOver = gameOver
        self.run.currentState = Constants.RUN_STATES.GAME_OVER
    end

    --self.terrain:outAnimation()
end

--==MOUSE/KEYBOARD FUNCTIONS==--

function Round:keypressed(key) --(Mainly for debug)
    if(key=='h')then --add 10 hands
        self.remainingHands = self.remainingHands + 10
    end

    if(key=="r") then --set rerolls to 10
        self.availableRerolls = 10
    end

    if(key=='a')then --skip round
        self.roundScore = 10000000
        self:endRound()
    end

    if(key=="s")then
        AnimationUtils.shake(self.terrain, 30, 3, 0.2)
    end

    if(key=="u")then
        self.terrain.addingAvailableHand = not self.terrain.addingAvailableHand
    end
end

--==TRIGGERING PHASE==--
function Round:getDicesOrder(usedDices)
    --[[
    Cette fonction permet de récupèrer les dés dans l'ordre de trigger
    -> Retourne une liste des dés dans l'ordre à trigger
    L'ordre est le suivant : de gauche à droite et de bas en haut
    ]]

    self.diceFacesOrder = {} --Base order when the hand is played. doenst get modified during the phase and is used to construct the queue
    self.dicesOrder = {} --Same but for the dice objects

    --Créée deux listes
    local diceFaces = {}
    local dices = {}

    for i, dice in next,usedDices do
        table.insert(diceFaces, self.terrain.diceFaces[dice])
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
        table.insert(sortedDiceFaces, self.terrain.diceFaces[d])
    end

    return sortedDiceFaces, sortedDices
end

function Round:startTriggeringPhase(usedDices, figure)
    self.phase = Constants.ROUND_STATES.TRIGGERING
    self.triggerDiceHistory = {}
    self.triggerFaceHistory = {}
    self.usedDices = usedDices
    self.playedFigure = figure
    --Creates the list of dices to trigger, sorted according to their position on the terrain

    local sortedDiceFaces = {}
    for i,k in next,self.selectedDices do
        for j,d in next,usedDices do
            if(d==k) then
                table.insert(sortedDiceFaces, self.terrain.diceFaces[k])
            end
        end
    end
    local sortedDices = {}
    for i,d in next,self.selectedDices do
        for j,k in next,usedDices do
            if(k==d) then
                table.insert(sortedDices, d)
            end
        end
    end

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
    if(table.getn(self.dicesTriggerQueue)>=1) then --S'il reste des dés dans la liste de triggers
        if(self.diceFacesTriggerQueue[1].representedObject.disabled == false) then --On vérifie que la face n'est pas désactivée avant de la jouer
            --On déclenche le dé
            self.diceFacesTriggerQueue[1]:trigger(self)
                
            --On ajoute à l'historique (en dernière position)
            table.insert(self.triggerDiceHistory, self.dicesTriggerQueue[1])
            table.insert(self.triggerFaceHistory, self.diceFacesTriggerQueue[1])

            --On retire de la file
            table.remove(self.diceFacesTriggerQueue, 1)
            table.remove(self.dicesTriggerQueue, 1) 
        else
            --On retire de la file
            table.remove(self.diceFacesTriggerQueue, 1)
            table.remove(self.dicesTriggerQueue, 1) 

            self:triggerNextDice()
        end


    else --ends the trigger phase, starts the backup triggers (TODO)
        self:startBackupPhase()
    end
end

function Round:startBackupPhase()
    self.backupDiceHistory = {}
    self.backupFaceHistory = {}

    --Get the list of dices to use
    local unselectedDices = self:getUnSelectedDices()
    local dices = {}

    for i,b in next,unselectedDices do
        table.insert(dices, i)
    end

    --On récupère l'ordre à la fois des objets UI et des dés associés
    local facesOrder, dicesOrder = self:getDicesOrder(dices)

    --On alimente la liste de dés à 
    for i,f in next,facesOrder do
        if(f.representedObject.backup == true) then
            table.insert(self.diceFacesBackupQueue, f)
        end
    end

    for i,d in next,dicesOrder do
        if(d:getCurrentFaceObject().backup == true) then
            table.insert(self.dicesBackupQueue, d)
        end
    end

    --trigger the first backup dice
    self:triggerNextBackupDice()

end

function Round:triggerNextBackupDice()
    if(table.getn(self.dicesBackupQueue)>=1)then --Si il reste au moins un dé non à backup
        if(self.diceFacesBackupQueue[1].representedObject.disabled == false) then
            self.diceFacesBackupQueue[1]:triggerBackup(self) --On trigger l'effer backup depuis l'objet UI

            
            --On ajoute à l'historique des backup
            table.insert(self.backupDiceHistory, self.dicesBackupQueue[1])
            table.insert(self.backupFaceHistory, self.diceFacesBackupQueue[1])

            --On retire de la file
            table.remove(self.diceFacesBackupQueue, 1)
            table.remove(self.dicesBackupQueue, 1)
        else
            --On retire de la file
            table.remove(self.diceFacesBackupQueue, 1)
            table.remove(self.dicesBackupQueue, 1)

            self:triggerNextBackupDice()
        end

    else
        --On termine la phase de trigger

        --Désactiver les dés ghosts qui ne sont pas utilisés dans la figure.
        --Liste des dés non utilisés
        local unusedDices = {}
        for i,d in next,self.diceObjects do
            if(self:containsDice(self.usedDices, d)) then

            else
                table.insert(unusedDices, d)
            end
        end

        --On désactive les dés ghosts qui ne sont pas utilisés
        for i,d in next,unusedDices do
            if(d:getCurrentFaceObject().ghost == true) then
                self.terrain.diceFaces[d]:disable(self.run)
            end
        end

        local j = 0
        for i,diceface in next,self.terrain.diceFaces do
            j = j+1
            if(j==5)then
                diceface.animator:add("y", diceface.y, diceface.y-20, 0.1)
                diceface.animator:add("y", diceface.y-20, 1000, 0.2)
                diceface.animator:addDelay(0.2, function()self:endTriggeringPhase()end) --On termine le round mais uniquement quand le dernier dé a terminé son animation
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
        if(self.bossType==Constants.BOSS_TYPES.CHEF_RD) then
            self.availableRerolls = 0
        else
            self.availableRerolls = Constants.BASE_REROLLS
        end
        self.roundScore = self.roundScore + self.handScore
        self.handScore = 0
    end

    if(self.roundScore >= self.targetScore or self.remainingHands <= 0) then
        self:endRound()
    else
        self.firstRoll = false
        self.terrain.timers.firstRerollTime = 0
    end
end

--==DICE FUNCTIONS==--

--TODO: à bouger dans roundscreen
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
    --Update the unselected dices position
    self.terrain:reorganiseDiceFaces(self:getUnSelectedDices())

    local us = self:getUnSelectedDices()

end

--==REROLL FUNCTIONS==--
function Round:rerollDices() --Triggers the makeRoll function after clicking the reroll button
    
    if(self.firstRoll == false) then
        self:makeRoll(self.diceObjects);
        self.firstRoll = true
        return
    end

    local dicesToReroll = {}
    --Add 1 to the total rerolls used this run
    self.run.usedRerolls = self.run.usedRerolls+1
    --On créée la liste des dés à reroll
    for k,d in next,self.diceObjects do
        if not self:containsDice(self.selectedDices, d) then
            table.insert(dicesToReroll, d)
        end
    end

    --On désactive les dés ghost qui sont reroll
    for k,d in next,dicesToReroll do
        if(d:getCurrentFaceObject().ghost == true) then
            self.terrain.diceFaces[d]:disable(self.run)
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
        self.terrain.diceFaces[dice]:setFaceObject(self.drawedFaceObjects[dice]) --update the ui
    end

    local rerolledDiceFaces = {}
    for k,d in next,dices do
        rerolledDiceFaces[d] = self.terrain.diceFaces[d]
    end

    for key,dice in next,dices do --Creates the roll animation for the rerolled dices

        self.terrain.diceFaces[dice].isRolling = true

        local randomXPos = math.random(80, self.terrain.dice_tray:getWidth()-80)
        local randomYPos = math.random(220, self.terrain.dice_tray:getHeight()-150)
        local randomR = ((math.random(0,1000)/1000)*5)-2.5 --(1001 angles possibles entre -2.5 et 5 radians)

        --Set initial position (random X axis, under the terrain)
        self.terrain.diceFaces[dice]:setX(self.terrain.dice_tray:getWidth()/2)
        --self.terrain.diceFaces[dice].targetX = 2000
        self.terrain.diceFaces[dice]:setY(self.terrain.dice_tray:getHeight()+100)
        --self.terrain.diceFaces[dice].targetY = 2000
        self.terrain.diceFaces[dice].rotation = 0

        --Add an animation to make them roll--

        --Add a small delay relative to the number of dices to rolls
        self.terrain.diceFaces[dice].animator:addDelay(((5-table.getn(dices))/5)*0.4)

        --Add a small random delay to add some relaness
        self.terrain.diceFaces[dice].animator:addDelay((math.random(0,100)/100)*0.2)
        local rollDuration = (math.random(50,100)/100)*0.6
        if(self.availableRerolls==1)then
            rollDuration = rollDuration+0.3
        end

        self.terrain.diceFaces[dice].animator:addGroup({
            {property = "x", from=self.terrain.canvas:getWidth()/2, targetValue = randomXPos, duration = rollDuration, onComplete=function()end, easing=AnimationUtils.Easing.outCubic},
            {property = "targetX", from=self.terrain.canvas:getWidth()/2, targetValue = randomXPos, duration = rollDuration, onComplete=function()end},
            {property = "y", from=self.terrain.canvas:getHeight()+100, targetValue = randomYPos, duration = rollDuration, onComplete=function()end, easing=AnimationUtils.Easing.outCubic},
            {property = "targetY", from=self.terrain.canvas:getHeight()+100, targetValue = randomYPos, duration = rollDuration, onComplete=function()end},
            {property = "rotation", from=-0, targetValue = randomR, duration = rollDuration, onComplete=function()end, easing=AnimationUtils.Easing.outCubic},
            {property = "baseRotation", from=-0, targetValue = randomR, duration = rollDuration, onComplete=function()end, easing=AnimationUtils.Easing.outCubic},
            {property = "displayedNumber", from=2, targetValue=6, duration = rollDuration*2, easing=AnimationUtils.makeRandomEasing(0.3, 0.00000005, function(t) return 1 - t end)}

        })
        self.terrain.diceFaces[dice].animator:addDelay(0.00, function()self.terrain.diceFaces[dice].displayedNumber = nil ;  self.terrain.diceFaces[dice]:updateSprite()end)
        self.terrain.diceFaces[dice].animator:addDelay(0.6, function()self.terrain:reorganiseDiceFaces(rerolledDiceFaces)end)
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
function Round:playFigure(points, usedDices, figure) --Function that triggers the hand
    --Commencer la phase de déclenchement

    --Si boss trésorier : on retire de l'argent selon le nombre de dés
    if(self.roundType==Constants.ROUND_TYPES.BOSS and self.bossType==Constants.BOSS_TYPES.TRESORIER)then
        self.terrain:setMoneyTo(self.run.money - table.getn(usedDices))
    end

    self:startTriggeringPhase(usedDices, figure)

    --Add one to the playcount
    self.run.figuresInfos[figure].playcount = self.run.figuresInfos[figure].playcount+1

    --Ajouter le score de base de la figure à la main
    self.handScore = self.handScore+points -- On ajoute les points au score
    self.terrain.handScoreDisplay = self.handScore
end

--==UTILS==--
function Round:getUnSelectedDices()
    local unSelectedDices = {}
    for i,dice in next,self.diceObjects do
        local selected = false
        for d,selectedDices in next,self.selectedDices do
            if(selectedDices==dice)then selected = true end
        end
        if(selected==false)then
            unSelectedDices[dice] = self.terrain.diceFaces[dice]
        end
    end 
    return unSelectedDices
end

function Round:addToScore(n)
    self.roundScore = self.roundScore + n
end

function Round:resetselectedDices()
    self.selectedDices = {} --remove the dices
    for key,uiFace in next,self.terrain.diceFaces do --unselect the UI Faces
        uiFace:setSelected(false)
        uiFace.anchorX = nil
        uiFace.anchorY = nil
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