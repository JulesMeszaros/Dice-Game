--Utils
local Inputs = require("src.utils.scripts.Inputs")
local CalculatePoints = require("src.utils.scripts.CalculatePoints")
local Fonts = require("src.utils.Fonts")
local Constants = require("src.utils.Constants")
local FaceHoverInfos = require("src.classes.ui.FaceHoverInfo")
local AnimationUtils = require("src.utils.scripts.Animations")
--UI
local Sprites = require("src.utils.Sprites")
local DiceFace = require("src.classes.ui.DiceFace")
--Ciggies
local Ciggie = require("src.classes.ui.Ciggie")
--Dices
local Screen = require("src.classes.GameScreen")

local RoundScreen = setmetatable({}, { __index = Screen })
RoundScreen.__index = RoundScreen

local font = Fonts.soraSmall
local font30 = Fonts.soraMedium

function RoundScreen:new(round)
    local self = setmetatable(Screen:new(round.run.currentFloor, round.run, Constants.RUN_STATES.ROUND, round), RoundScreen)

    self.gameCanvas = round.gameCanvas
    self.round = round
    self.endRoundPopUp = nil

    --FIGURE BUTTONS
    self.clickedFigure = nil
    --Calculate points functions
    self.calcBasePoints = {
        function()return CalculatePoints.numberBasePoints(1, self.round.selectedDices)end,
        function()return CalculatePoints.numberBasePoints(2, self.round.selectedDices)end,
        function()return CalculatePoints.numberBasePoints(3, self.round.selectedDices)end,
        function()return CalculatePoints.numberBasePoints(4, self.round.selectedDices)end,
        function()return CalculatePoints.numberBasePoints(5, self.round.selectedDices)end,
        function()return CalculatePoints.numberBasePoints(6, self.round.selectedDices)end,
        function()return CalculatePoints.chanceBasePoints(self.round.selectedDices)end,
        function()return CalculatePoints.brelanBasePoints(self.round.selectedDices)end,
        function()return CalculatePoints.carreBasePoints(self.round.selectedDices)end,
        function()return CalculatePoints.fullBasePoints(self.round.selectedDices)end,
        function()return CalculatePoints.pttSuiteBasePoints(self.round.selectedDices)end,
        function()return CalculatePoints.gdSuiteBasePoints(self.round.selectedDices)end,
        function()return CalculatePoints.yatzeeBasePoints(self.round.selectedDices)end
    }

    self.calculatePointsFunctions = {
        function()self:playFigure(Constants.FIGURES.ONES, CalculatePoints.numberBasePoints(1, self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.TWOS, CalculatePoints.numberBasePoints(2, self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.THREES, CalculatePoints.numberBasePoints(3, self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.FOURS, CalculatePoints.numberBasePoints(4, self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.FIVES, CalculatePoints.numberBasePoints(5, self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.SIXS, CalculatePoints.numberBasePoints(6, self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.CHANCE, CalculatePoints.chanceBasePoints(self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.THREE_OAK, CalculatePoints.brelanBasePoints(self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.FOUR_OAK,CalculatePoints.carreBasePoints(self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.FULL_HOUSE,CalculatePoints.fullBasePoints(self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.SMALL_SUITE,CalculatePoints.pttSuiteBasePoints(self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.LARGE_SUITE,CalculatePoints.gdSuiteBasePoints(self.round.selectedDices))end,
        function()self:playFigure(Constants.FIGURES.DELUXE,CalculatePoints.yatzeeBasePoints(self.round.selectedDices))end,
    }
    
    self.dragAndDroppedCiggie = nil
    self.dragAndDroppedFace = nil

    --FACE DETAILS
    self.pointsDetailsCanvas = nil

    --DICE DETAILS
    self.diceDetailsTimer = 0
    self.diceDetailsTime = 0.5
    --Creating the different ui faces that will be shown
    self:createDiceNet()

    --Ciggies
    self.hoveredByCiggie = nil

    --Hand Score
    self.handScoreRX, self.handScoreRY = 1
    self.handScoreRot = 0

    --Start the round with the first roll
    self.animator:addDelay(0.5, function()self.round:makeRoll(self.round.diceObjects);self:generateCiggiesUI()end)

    self.diceFaces = {}
    --On créé des objets pour les nouveaux diceFaces
    for key,diceobject in next,self.round.diceObjects do

        local diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            diceobject, --Dice Object 
            diceobject:getFace(1), --La face représentée
            self.canvas:getWidth()/2, --X Position (centerd)
            self.canvas:getHeight()+70, --Yposition (centerd)
            120, --Width/Height
            true, --is Selectable
            true, --isHoverable,
            function()return Inputs.getMouseInCanvas(510 , 320)end,
            self.round
        )

        self.diceFaces[diceobject] = diceFaceUI
    end

    return self
end

function RoundScreen:update(dt)

    --Update dices UI
    for key,dice in next,self.diceFaces do
        dice:update(dt)
    end

    --Reset Bouton de figure et Dé survolé
    self.currentlyHoveredFigure = nil

    self.animator:update(dt)

    --Hover infos
    self:getCurrentlyHoveredDice() --Le dé survolé
    self:getCurrentlyHoveredCiggie() --Ciggie survolée

    --Utilities buttons
    for key,button in next,self.uiElements.buttons do
        self.uiElements.buttons["rerollButton"]:setActivated(self.round.availableRerolls>0 and table.getn(self.round.selectedDices)<table.getn(self.round.diceObjects))

        button:update(dt)
    end

    --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
    end

    self:updateCanvas(dt)

end

function RoundScreen:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    --set background
    if(self.round.roundType == Constants.ROUND_TYPES.BASE)then
        love.graphics.clear(40/255, 40/255, 43/255)
    else
        love.graphics.clear(55/255, 96/255, 85/255)
    end

    --Check if a ciggie is being dragged to the screen
    self:checkForDraggedCiggie()

    --PlayersInfos
    self:drawPlayersInfos()
    --Dice Tray
    self:drawDiceTray(self.diceMatx, self.diceMaty, self.diceFaces)

    --Figure Buttons

    self:drawFigureGrid(self.gridX, self.gridY)
    self:getCurrentlyHoveredLine() --La figure survolée

    --Bouttouns de round
    for k,b in next,self.uiElements.buttons do
        b:draw()
    end

    --Dice Details
    self:updateDiceNet(dt)
    for k,df in next,self.infoFaces do --éventuellement à bouger dans la fonction drawDescription
        df.targetedScale = self.diceDetailsTimer/self.diceDetailsTime
        df:updateCanvas(dt) 
        df:update(dt)
    end
    self:drawDiceDetails(self.diceDetailsX, self.diceDetailsY)
    
    --ROUND DETAILS
    self:drawRoundDetails()

    --Ciggie Popup

    if(self.previousCiggieDraggedState ~= self.draggedCiggie) then
        if(self.draggedCiggie)then
            self:startCiggiePopUp()
        else
            self:endCiggiePopup()
        end
    end

    if(self.showCiggiePopup) then
        self:drawCiggiePopup()
    end



    --Ciggies Tray
    self:drawCiggiesTray()

    --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:draw()
    end

    

    self:drawCiggiesTrayFront()

    --EndRoundScreen
    if(self.endRoundPopUp)then
        self.endRoundPopUp:update(dt)
        self.endRoundPopUp:updateCanvas(dt)
        self.endRoundPopUp:draw()
    end

    --Face Details
    self:drawDescription(self.descriptionX, self.descriptionY)

    --On dessine l'objet drag and drop au dessus de tout le reste
    if(self.dragAndDroppedCiggie)then
        self.dragAndDroppedCiggie:draw()
    end

    love.graphics.setCanvas(currentCanvas)
end

--==INPUT FUNCTIONS==--
function RoundScreen:mousemoved(x, y, dx, dy, isDragging)
    if(self.round.phase ~= Constants.ROUND_STATES.END_ROUND and self.run.runPaused == false) then
        --Drag and drop dice
        if(isDragging == true)then 
            for key,diceui in next, self.diceFaces do
                if(diceui.isDraggable and diceui.isBeingClicked) then
                    diceui.isBeingDragged = true
                    self.dragAndDroppedDice = diceui
                    diceui.dragXspeed = dx
                    if(diceui.targetX+dx<self.dice_tray:getWidth()-diceui.size/2 and diceui.targetX+dx>0+diceui.size/2) then --Vérification qu'on ne dépasse par les limites horizontales
                        diceui.targetX = (diceui.targetX + dx) 
                    end

                    if(diceui.targetY+dy<self.dice_tray:getHeight()-diceui.size/2-85 and diceui.targetY+dy>165+diceui.size/2) then --Vérification qu'on ne dépasse pas les limites verticales
                        diceui.targetY = (diceui.targetY + dy) 
                    end
                    break;
                end
            end
        end
        --Drag and drop Ciggies
        if(isDragging == true)then 
            for key,ciggie in next, self.uiElements.ciggiesUI do
                if(ciggie.isDraggable and ciggie.isBeingClicked) then
                    ciggie.isBeingDragged = true
                    self.dragAndDroppedCiggie = ciggie
                    ciggie.dragXspeed = dx
                    ciggie.targetX = x
                    ciggie.targetY = y
                    break;
                end
            end
        end
    elseif(self.endRoundPopUp)then
        self.endRoundPopUp:mousemoved(x, y, dx, dy, isDragging)
    end
end

function RoundScreen:mousepressed(x, y, button, istouch, presses)
    if(self.round.phase ~= Constants.ROUND_STATES.END_ROUND) then
        --DiceFaces
        for key,uiFace in next,self.diceFaces do
            uiFace:clickEvent()
        end

        --Ciggies
        for key,ciggie in next,self.uiElements.ciggiesUI do
            ciggie:clickEvent()
        end

        --Round Buttons
        for key,button in next,self.uiElements.buttons do
            button:clickEvent()
        end

        --Figure buttons
        self.clickedFigure = self:getCurrentlyHoveredLine()
    else
        if(self.endRoundPopUp) then
            self.endRoundPopUp:mousepressed(x, y, button, istouch, pressed)
        end
    end
end

function RoundScreen:mousereleased(x, y, button, istouch, presses)
    if(self.round.phase ~= Constants.ROUND_STATES.END_ROUND)then
        --release event for dice faces

        self.dragAndDroppedCiggie = nil
        self.dragAndDroppedFace = nil

        for key,diceface in next,self.diceFaces do
            local wasReleased = diceface:releaseEvent()
            if(wasReleased)then
                self.round:updateselectedDices(diceface)
            end
            diceface.isBeingDragged = false
        end

        --release event on UI elements (buttons)
        for key,button in next,self.uiElements.buttons do
            local wasReleased = button:releaseEvent()
            if(wasReleased) then --Si le click a été complété
                button:getCallback()()
            end
        end

        --Figure buttons
        if(self.clickedFigure)then
            if(self.clickedFigure == self:getCurrentlyHoveredLine())then
                self.calculatePointsFunctions[self.clickedFigure]()
            end
        end

        --Ciggies
        for key,ciggie in next,self.uiElements.ciggiesUI do
            ciggie:releaseEvent()
            self:ciggieReleaseAction(ciggie)
            ciggie.isBeingDragged = false
        end
    elseif(self.endRoundPopUp)then
        self.endRoundPopUp:mousereleased(x, y, button, istouch, presses)
    end
end

function RoundScreen:updateSelectedPosDices()
    local i = 1
    for k,d in next,self.round.selectedDices do
        self.diceFaces[d].targetY = 70
        self.diceFaces[d].targetX = 105 + (i-1)*(180)
        i=i+1
    end
end

--==DRAW FUNCTIONS==--

function RoundScreen:drawDiceTray(x, y, dices2)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.dice_tray)
    love.graphics.clear()
    
    love.graphics.draw(Sprites.DICE_MAT, 0, 0, 0, 1, 1)
    
    --On déssine les autres dés
    for key,uiFace in next,dices2 do
        uiFace:draw()
    end

    --dessiner le dé drag and drop au dessus des autres
    if(self.dragAndDroppedDice)then
        self.dragAndDroppedDice:draw()
    end

    --Score de la main en direct
    if(self.round.phase == Constants.ROUND_STATES.TRIGGERING)then
        self:drawHandScore()
    end


    --On retourne au canvas précédent
    love.graphics.setCanvas(targetCanvas)
    --On déssine le terrain à dés sur le canvas
    love.graphics.draw(self.dice_tray, x, y) --On fixe son offset sur son angle superieur droit

end

function RoundScreen:drawDiceDetails(x, y)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceDetailsCanvas)
    love.graphics.clear()

    --Draw sprite
    love.graphics.draw(Sprites.DICE_INFOS, 0, 0)
    
    --Draw the dice net
    if self.currentlyHoveredDice then
        for k,df in next,self.infoFaces do
            df:draw()
        end
    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.diceDetailsCanvas, x, y, 0, 1, 1, self.diceDetailsCanvas:getWidth(), 0)
end

function RoundScreen:drawPlayersInfos()
    local currentCanvas = love.graphics.getCanvas()
    --Player
    love.graphics.setCanvas(self.playerInfos)
    love.graphics.clear()
    love.graphics.draw(Sprites.PLAYER_INFOS, 0, 0)
    local scoreText = love.graphics.newText(font, 'Score : ' ..tostring(self.round.roundScore))
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(scoreText, self.playerInfos:getWidth()-20, 72, 0, 1, 1, scoreText:getWidth(), 0)
    love.graphics.setColor(1, 1, 1, 1)

    --Ennemy
    love.graphics.setCanvas(self.enemyInfos)
    love.graphics.clear()
    love.graphics.draw(Sprites.ENEMY_INFOS, 0, 0)
    local targetScoreText = love.graphics.newText(font, 'Target : '..tostring(self.round.targetScore))
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(targetScoreText, 20, 210)
    love.graphics.setColor(1, 1, 1, 1)

    --Lion
    self.round.enemyCharacter:update()
    self.round.enemyCharacter:draw(390+130, 125, 250, 250)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.playerInfos, self.playerX, self.playerY)
    love.graphics.draw(self.enemyInfos, self.enemyX, self.enemyY)
end

--==CREATE CANVAS FUNCTIONS==--

function RoundScreen:animateHandScore()
    local randomAngle = math.random(2, 5)/10
    local randomDir = math.random(0, 1) == 0 and -1 or 1
    self.animator:addGroup({
        {property="handScoreRX", from=1.4, targetValue=1, duration = 0.2}, --Makes it instantly bigger and animate it to its base size
        {property="handScoreRot", from=randomAngle*randomDir, targetValue=0, duration = 0.2}, --Makes it instantly bigger and animate it to its base size
    })
end

function RoundScreen:drawHandScore()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.handScoreCanvas)
    love.graphics.clear()

    local scoreText = love.graphics.newText(Fonts.soraBig, self.round.handScore)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(scoreText, self.handScoreCanvas:getWidth()/2, self.handScoreCanvas:getHeight()/2, self.handScoreRot, self.handScoreRX, self.handScoreRY, scoreText:getWidth()/2-10, scoreText:getHeight()/2-10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.handScoreCanvas, 0, 200)
end

function RoundScreen:outAnimation()
    local outDuration = 0.4
    self.animator:addGroup({
        {property = "gridY", from = self.gridY, targetValue = -820, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "diceMaty", from = self.diceMaty, targetValue = self.canvas:getHeight()+1000, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        
        {property = "moneyY", from = self.moneyY, targetValue = self.canvas:getHeight()+300, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = -730, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = -500, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.canvas:getHeight()+400, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
    })

    --Ciggarettes
    for i,c in next,self.uiElements.ciggiesUI do
        c.animator:addGroup({
            {property="scaleX", from=c.scaleX, targetValue=0, duration = outDuration/2},
            {property="scaleY", from=c.scaleY, targetValue=0, duration = outDuration/2},
            {property = "baseTargetedScale", from = c.baseTargetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = c.targetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
        })
    end
    
    self.animator:addDelay(0.2)
    self.animator:addGroup({
        {property = "playerX", from = self.playerX, targetValue = -800, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "enemyX", from = self.enemyX, targetValue = self.canvas:getWidth()+20, duration = outDuration, easing = AnimationUtils.Easing.inCubic, onComplete=function()self.round.run:goToNextRound()end},
    })

    --Buttons animation
    self.uiElements.buttons["rerollButton"].animator:add('y', self.rerollBtnY, 1500, outDuration)
    self.uiElements.buttons["menuButton"].animator:add('x', self.menuBtnX, -150, outDuration)
    self.uiElements.buttons["planButton"].animator:add('x', self.planBtnX, -150, outDuration)

end

--==UTILS FUNCTIONS==--
--HOVER FUNCTIONS
function RoundScreen:getCurrentlyHoveredLine()
    local mv = Inputs.getMouseInCanvas(30, 30) --get the mouse position
    local i = math.floor((mv.y-10)/50)+1
    if(i>0 and i<=13)then
        if(mv.x>0 and mv.x<self.figureButtonsCanvas:getWidth())then
            self:highlightDices(self.calcBasePoints[i]()[2])
            return i
        end
    else
        self:highlightDices({})
        return nil
    end 
end
--Gets the currenty hovered dice, both in the mat AND in the dice net
function RoundScreen:getCurrentlyHoveredDice()
    self.previouslyHoveredFace = self.currentlyHoveredFace
    self.currentlyHoveredFace = nil

    self.hoveredFaceCanvas = nil

    --Dés dans le terrain de jeu
    for key,diceface in next,self.diceFaces do
        if diceface:isHovered() then
            self.currentlyHoveredDice = diceface.diceObject
            self.currentlyHoveredFace = diceface
            self.hoveredFaceCanvas = 1
            break
        end
    end

    --Dés dans l'encart à droite
    for key,diceface in next,self.infoFaces do
        if diceface:isHovered() and self.currentlyHoveredDice then
                self.currentlyHoveredFace = diceface
                self.hoveredFaceCanvas = 2
            break
        end
    end

    if(self.previouslyHoveredFace ~= self.currentlyHoveredFace and self.currentlyHoveredFace~= nil)then
        if(self.hoveredFaceCanvas==1) then
            self.pointsDetailsCanvas = FaceHoverInfos:new(
                self.currentlyHoveredFace, 
                "points", 
                self.diceMatx, 
                self.diceMaty)
        elseif(self.hoveredFaceCanvas==2) then
            self.pointsDetailsCanvas = FaceHoverInfos:new(
                self.currentlyHoveredFace, 
                "points", 
                self.diceDetailsX - self.diceDetailsCanvas:getWidth(), 
                30)
        end
    end

end

function RoundScreen:getCurrentlyHoveredCiggie()
    self.currentlyHoveredCiggie = nil

    for i,ciggie in next,self.uiElements.ciggiesUI do
        if(ciggie:isHovered())then
            self.currentlyHoveredCiggie = ciggie
            break
        end
    end
end

--Gets the currently hovered object (dice, ciggie, etc...)
function RoundScreen:getCurrentlyHoveredObject()
    local object = nil

    if(self.currentlyHoveredCiggie and not self.endRoundPopUp)then object = self.currentlyHoveredCiggie.representedObject
    elseif(self.currentlyHoveredFace and not self.endRoundPopUp)then object = self.currentlyHoveredFace.representedObject
    elseif(self.endRoundPopUp and self.endRoundPopUp.currentlyHoveredFace) then object = self.endRoundPopUp.currentlyHoveredFace.representedObject
    else object = nil end

    return object
end

-- Updates the dice net
function RoundScreen:updateDiceNet(dt)
    if(self.currentlyHoveredDice) then
        for i = 1, 6 do
            self.infoFaces[i]:setRepresentedFace(self.currentlyHoveredDice:getFace(i))
            self.infoFaces[i]:updateSprite()
            self.infoFaces[i]:update(dt)
        end
        if(self.diceDetailsTimer+100*dt<self.diceDetailsTime)then
            self.diceDetailsTimer = self.diceDetailsTimer+100*dt
        else
            self.diceDetailsTimer = self.diceDetailsTime
        end
    else
        self.diceDetailsTimer = 0
    end
end

function RoundScreen:playFigure(figure, params)
    local points, usedDices = params[1], params[2]
    if(self.round.run.availableFigures[figure]>=1 and table.getn(self.round.selectedDices)>=1)then
        self.round:playFigure(points, usedDices, figure)
        self.round.run.availableFigures[figure] = self.round.run.availableFigures[figure]-1
    end
end
--Reorganises the UI faces by face order
function RoundScreen:reorganiseDiceFaces(dices)
    --Reorganise the dice by face (increasing)
    local reorganisedDices = {}
    local temp = {}
    --On créée une liste d'incides, qui sert de base pour trier la liste de dés ET de diceFaces

    for _, dice in next,dices do
        table.insert(temp, dice)
    end

    table.sort(temp, function(a, b)
        return a.representedObject.faceValue < b.representedObject.faceValue
    end)
    for _, dice in ipairs(temp) do
        table.insert(reorganisedDices, dice)
    end

    local i = 1
    for key,uiFace in next,reorganisedDices do
        uiFace.targetX = (i)*(((self.dice_tray:getWidth()-100)/(table.getn(reorganisedDices)+1)))+50
        uiFace.targetY = (self.dice_tray:getHeight()/2+140)
        uiFace.baseRotation = 0
        i = i+1
    end    
end
--Highlight the dices when hovering a figure
function RoundScreen:highlightDices(usedDices)
    for key,diceface in next,self.diceFaces do
        diceface:setHighlighted(false)
        for _, dice in next,usedDices do
            if self.diceFaces[dice] == diceface then
                    diceface:setHighlighted(true)
                    break
            end
        end
    end
end

return RoundScreen