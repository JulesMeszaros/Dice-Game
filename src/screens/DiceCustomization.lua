--==IMPORTS==--
local Sprites = require("src.utils.Sprites")
local DiceFace = require("src.classes.ui.DiceFace")
local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local Button = require("src.classes.ui.Button")
local AnimationUtils = require("src.utils.scripts.Animations")
local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")
local Screen = require("src.classes.GameScreen")
local Fonts = require("src.utils.Fonts")
local UI = require("src.utils.scripts.UI")
--===========--

local DiceCustomization = setmetatable({}, { __index = Screen })
DiceCustomization.__index = DiceCustomization

function DiceCustomization:new(previousRound, newFaceObjects)
    local self = setmetatable(Screen:new(previousRound.run.currentFloor, previousRound.run, Constants.RUN_STATES.DICE_CUSTOMIZATION, previousRound), DiceCustomization)
    self.run = previousRound.run
    --Table where we store the ui faces of the face objects earned
    self.newFaceObjects = newFaceObjects
    --Table where we store the ui dice faces, grouped by dice
    self.uiDices = {}
    self.newUIFaces = {}
    self.rewardsUIFaces = {}
    --On peuple notre table
    
    self.dragAndDroppedObject = nil

    for i,dice in next, self.diceObjects do
        table.insert(self.uiDices, self:createDiceUI(dice, i))
    end

    self.uiElements.buttons["nextRound"] = Button:new(
        function()self:switchFaces()end,
        "src/assets/sprites/ui/Next Round Big.png",
        self.nextRoundX,
        self.nextRoundY,
        910,
        150,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.buttons["nextRound"].animator:add('y', self.nextRoundY, self.nextRoundTY, AnimationUtils.EntryDuration, AnimationUtils.Easing.inOutCubic)

    self.addRewardText = UI.Text.TextWavy:new(
        "Add to",
        self.inventoryMDTX + self.inventoryCanvasMedium:getWidth()/2,
        self.inventoryMDTY + self.inventoryCanvasMedium:getHeight()/2-35,
        {
            font = Fonts.soraRewardTotal,
            centered = true,
            amplitude = 5,
            speed = 2
        }
    )

    self.addRewardText2 = UI.Text.TextWavy:new(
        "inventory?",
        self.inventoryMDTX + self.inventoryCanvasMedium:getWidth()/2,
        self.inventoryMDTY + self.inventoryCanvasMedium:getHeight()/2+35,
        {
            font = Fonts.soraRewardTotal,
            centered = true,
            amplitude = 5,
            speed = 2
        }
    )

    --Wavy Texts
    self.sellText = UI.Text.TextWavy:new(
        "Sell : 3$",
        250, 950,
        {
            font = Fonts.SoraBig,
            centered = true,
            amplitude = 5,
            speed = 2,
            colorStart = {255/255, 178/255, 89/255},
            colorEnd = {255/255, 178/255, 89/255}
        }
    )

    self:createInventoryUI()
    self:createRewardsUI()

    self.animator:addDelay(0.5, function()self:generateCiggiesUI()end)

    return self
end

function DiceCustomization:update(dt)
    --Get hovered objects
    self:getCurrentlyHoveredFace()
    self:getCurrentlyHoveredCiggie()
    
    --Update animations
    self.animator:update(dt)

    --update the canvas
    self:updateCanvas(dt)

    --Update the dice faces
    --Draw the uiFaces on the canvas
    for i,uiDice in next,self.uiDices do
        for j,uiFace in next,uiDice do
            uiFace:update(dt)
        end
    end

    --New faces
    for i,uiFace in next,self.newUIFaces do
        uiFace:update(dt)
    end

    --Rewards
    for i,uiFace in next,self.rewardsUIFaces do
        uiFace:update(dt)
    end

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end
    
end

function DiceCustomization:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    --Check if a ciggie is being dragged to the screen
    self:checkForDraggedCiggie()

    --UI

    --Run informations
    self:drawRoundDetails(dt)
    
    --New Faces Canvas
    --self:drawNewFacesCanvas()
    self:drawFigureGrid()
    self:drawRewardsMedium()
    self:drawInventoryBackGroundMedium()
    --Customization mat
    self:drawCustomizationMat()
    --Ciggies
    self:drawCiggiesTray()

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:draw()
    end

    --Popup d'ajout à l'inventaire
    if(self.dragAndDroppedReward)then
        love.graphics.draw(Sprites.ADD_TO_INVENTORY_L, self.inventoryMDTX, self.inventoryMDTY, 0, 1, 1)
        self.addRewardText:update(dt)
        self.addRewardText:draw()

        self.addRewardText2:update(dt)
        self.addRewardText2:draw()
    else
        self.addRewardText:reset()
        self.addRewardText2:reset()
    end

    --Popup de vente de face de dé
    if(self.dragAndDroppedReward or self.dragAndDroppedInventory)then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Sprites.SELL_CIGGIE, 30, self.canvas:getHeight()-30, 0, 1, 1, 0, Sprites.SELL_CIGGIE:getHeight())
        self.sellText:update(dt)
        self.sellText:draw()
    else
        self.sellText:reset()
    end

    --Draw the deck dices on the canvas
    for i,uiDice in next,self.uiDices do
        for j,uiFace in next,uiDice do
            uiFace:draw()
        end
    end

    self:drawNewFaces()
    self:drawRewards()

    --Ciggie Popup

    if(self.previousCiggieDraggedState ~= self.draggedCiggie) then
        if(self.draggedCiggie)then
            self:startCiggiePopUp()
        else
            self:endCiggiePopup()
        end
    end

    if(self.showCiggiePopup) then
        self:drawCiggiePopup(dt)
    end

    --Description
    --self:drawDescription()

    --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
        if(ciggie ~= self.dragAndDroppedObject)then
            ciggie:draw()
        end
    end

    

    --DnDropped object
    if(self.dragAndDroppedObject)then
        self.dragAndDroppedObject:draw()
    end 

    --self:drawCiggiesTrayFront()

    love.graphics.setCanvas(currentCanvas)
end

function DiceCustomization:draw()
    love.graphics.draw(self.canvas, 0, 0)
end

--==INPUTS FUNCTIONS==--
function DiceCustomization:keypressed(key)
    print("keypressed")
end

function DiceCustomization:mousepressed(x, y, button, istouch, presses)
   --Dice faces
    for key,face in next,self.newUIFaces do
        face:clickEvent()
    end

    --Rewards
    for key,face in next,self.rewardsUIFaces do
        face:clickEvent()
    end
   
    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:clickEvent()
    end

end

function DiceCustomization:mousereleased(x, y, button, istouch, presses)
    self.dragAndDroppedObject = nil
    self.dragAndDroppedReward = nil
    self.dragAndDroppedInventory = nil

    for i,face in next,self.newUIFaces do
        face:releaseEvent()
        
        local closestFace = self:detectClosestFace(face.x, face.y)

        if(closestFace) then
            face.anchorX = closestFace[1]
            face.anchorY = closestFace[2]
        elseif(face.x > 0 and face.x < 500) and (face.y>850 and face.y<self.canvas:getHeight()) then
            self:sellDiceFace(face.representedObject, face, i)

        else
            face.anchorX = self.xPositions[i] + self.inventoryMDTX + 60
            face.anchorY = self.yPositions[i] + self.inventoryMDTY + 60
        end

        if(face.anchorX)then
            face.targetX = face.anchorX
        end
        if(face.anchorY)then
            face.targetY = face.anchorY
        end

        face.isBeingDragged = false

    end

    for i,face in next,self.rewardsUIFaces do
        face:releaseEvent()
        
        local closestFace = self:detectClosestFace(face.x, face.y)

        if(closestFace) then
            face.anchorX = closestFace[1]
            face.anchorY = closestFace[2]
        elseif(
            (face.targetX > self.inventoryMDTX and face.targetX < self.inventoryMDTX + self.inventoryCanvasMedium:getWidth()) and
            (face.targetY > self.inventoryMDTY and face.targetY < self.inventoryMDTY + self.inventoryCanvasMedium:getHeight()) --[[ and
            (table.getn(self.run.facesInventory)< 8) ]]
        )then
            self:addRewardToInventory(face, i)
        elseif(face.x > 0 and face.x < 500) and (face.y>850 and face.y<self.canvas:getHeight())then
            self:sellReward(face.representedObject, face, i)
        else
            face.anchorX = self.xPositionsRewards[i] + self.rewardsMDTX + 60
            face.anchorY = self.yPositionsRewards[i] + self.rewardsMDTY + 60
        end

        if(face.anchorX)then
            face.targetX = face.anchorX
        end
        if(face.anchorY)then
            face.targetY = face.anchorY
        end
        
        face.isBeingDragged = false

    end

    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:releaseEvent()
        ciggie.isBeingDragged = false
        self:ciggieReleaseAction(ciggie)
    end

end

function DiceCustomization:mousemoved(x, y, dx, dy, isDragging)
    if(isDragging == true)then 
        for key,diceui in next, self.newUIFaces do
            if(diceui.isDraggable and diceui.isBeingClicked) then
                diceui.isBeingDragged = true
                self.dragAndDroppedObject = diceui
                self.dragAndDroppedInventory = diceui
                diceui.dragXspeed = dx
                diceui.targetX = (diceui.targetX + dx) 
                diceui.targetY = (diceui.targetY + dy)
                break;
            end
        end

        for key,diceui in next, self.rewardsUIFaces do
            if(diceui.isDraggable and diceui.isBeingClicked) then
                diceui.isBeingDragged = true
                self.dragAndDroppedObject = diceui
                self.dragAndDroppedReward = diceui
                diceui.dragXspeed = dx
                diceui.targetX = (diceui.targetX + dx) 
                diceui.targetY = (diceui.targetY + dy)
                break;
            end
        end

        for key,ciggie in next, self.uiElements.ciggiesUI do
            if(ciggie.isDraggable and ciggie.isBeingClicked) then
                ciggie.isBeingDragged = true
                self.dragAndDroppedObject = ciggie
                ciggie.dragXspeed = dx
                ciggie.targetX = x
                ciggie.targetY = y
                break;
            end
        end
    end
end

--==Draw UI==--

function DiceCustomization:drawNewFacesCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.newFacesCanvas)
    love.graphics.clear()

    love.graphics.draw(Sprites.REWARDS, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.newFacesCanvas, self.newFacesX, self.newFacesY, 0, 1, 1)
end

function DiceCustomization:drawCustomizationMat()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.customizationMat)
    love.graphics.clear()

    love.graphics.draw(Sprites.CUSTOMIZATION_MAT, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.customizationMat, self.customizationMatX, self.customizationMatY, 0, 1, 1)
end

function DiceCustomization:drawNewFaces()
    for i,face in next,self.newUIFaces do
        if(face ~= self.dragAndDroppedObject)then
            face:draw()
        end
    end
end

function DiceCustomization:drawRewards()
    for i,face in next,self.rewardsUIFaces do
        if(face ~= self.dragAndDroppedObject)then
            face:draw()
        end
    end
end



--==UTILS=--

function DiceCustomization:outAnimation()
    local outDuration = 0.4
    self.animator:addGroup({
        {property = "gridX", from = self.gridX, targetValue = 0-self.figureButtonsCanvas:getWidth(), duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.canvas:getWidth()+650, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
   
        {property = "customizationMatY", from = self.customizationMatY, targetValue = 0-self.customizationMat:getHeight()-50, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "newFacesY", from = self.newFacesY, targetValue = self.canvas:getHeight()+500, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
                
        {property = "inventoryMDY", from = self.inventoryMDY, targetValue = -50+self.rewardsMediumCanvas:getHeight()-self.customizationMat:getHeight(), duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rewardsMDY", from = self.rewardsMDY, targetValue = -50-self.customizationMat:getHeight(), duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
    
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.canvas:getWidth()+200, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "deckX", from = self.deckX, targetValue = self.canvas:getWidth()+50, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "moneyX", from = self.moneyX, targetValue = self.canvas:getWidth()+400, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = self.canvas:getWidth()+400, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = self.canvas:getWidth()+400, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorX", from = self.floorX, targetValue = self.canvas:getWidth()+400, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
    
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

    --Buttons animation
    self.uiElements.buttons["nextRound"].animator:add('y', self.nextRoundY, self.canvas:getHeight()+150, outDuration,AnimationUtils.Easing.inOutCubic)
    self.uiElements.buttons["menuButton"].animator:add('x', self.uiElements.buttons["menuButton"].x, self.canvas:getWidth()+200, outDuration, AnimationUtils.Easing.inOutCubic)
    self.uiElements.buttons["planButton"].animator:add('x', self.uiElements.buttons["menuButton"].x, self.canvas:getWidth()+200, outDuration, AnimationUtils.Easing.inOutCubic)

    --Dices exit
    for i,dice in next,self.uiDices do
        for j,face in next,dice do
            --Add a random animation for every faces
            local randomSide = math.random(0,1)
            local exitX = -200
            if(randomSide == 0)then
                exitX = -200
            else
                exitX = self.canvas:getWidth()+200
            end
            local exitY = self.canvas:getHeight()/2
            local duration = math.random(3, 5)/10
            local delayStart = math.random(1, 3)/100
            local randomAngle = math.random(-500, 500)/100
            face.animator:addDelay(delayStart)
            face.animator:addGroup({
                {property = "x", from = face.x, targetValue = exitX, duration = duration,easing = AnimationUtils.Easing.inCubic},
                {property = "targetX", from = face.targetX, targetValue = exitX, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "y", from = face.y, targetValue = exitY, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "targetY", from = face.targetY, targetValue = exitY, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "rotation", from = face.rotation, targetValue = randomAngle, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "baseRotation", from = face.baseRotation, targetValue = randomAngle, duration = duration, easing = AnimationUtils.Easing.inCubic},
            })

        end
    end

    --inventory Faces exit
    for i,face in next,self.newUIFaces do
        local randomSide = math.random(0,1)
        local exitX = -200
        if(randomSide == 0)then
            exitX = -200
        else
            exitX = self.canvas:getWidth()+200
        end
        local exitY = self.canvas:getHeight()/2
        local duration = math.random(3, 5)/10

        local randomAngle = math.random(-500, 500)/100


        face.animator:addGroup({
                {property = "x", from = face.x, targetValue = exitX, duration = duration,easing = AnimationUtils.Easing.inCubic},
                {property = "targetX", from = face.targetX, targetValue = exitX, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "y", from = face.y, targetValue = exitY, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "rotation", from = face.rotation, targetValue = randomAngle, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "baseRotation", from = face.baseRotation, targetValue = randomAngle, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "targetY", from = face.targetY, targetValue = exitY, duration = duration, easing = AnimationUtils.Easing.inCubic},
            })
    end

    --Rewards
    for i,face in next,self.rewardsUIFaces do
        local randomSide = math.random(0,1)
        local exitX = -200
        if(randomSide == 0)then
            exitX = -200
        else
            exitX = self.canvas:getWidth()+200
        end
        local exitY = self.canvas:getHeight()/2
        local duration = math.random(3, 5)/10

        local randomAngle = math.random(-500, 500)/100


        face.animator:addGroup({
                {property = "x", from = face.x, targetValue = exitX, duration = duration,easing = AnimationUtils.Easing.inCubic},
                {property = "targetX", from = face.targetX, targetValue = exitX, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "y", from = face.y, targetValue = exitY, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "rotation", from = face.rotation, targetValue = randomAngle, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "baseRotation", from = face.baseRotation, targetValue = randomAngle, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "targetY", from = face.targetY, targetValue = exitY, duration = duration, easing = AnimationUtils.Easing.inCubic},
            })
    end

    self.animator:addDelay(0.5, function()self.round.run:goToRoundSelection() end)


end

function DiceCustomization:switchFaces()
    for i,face in next,self.newUIFaces do
        local closestFace = self:detectClosestFace(face.x, face.y)
        if(closestFace) then
            local diceObject = self.uiDices[closestFace[3]][closestFace[4]].diceObject
            diceObject:setFace(face.representedObject, closestFace[4])
            --Removing the face from the inventory
            for k,d in next,self.run.facesInventory do
                if(d==face.representedObject) then table.remove(self.run.facesInventory, k) ; break end
            end
        end
    end

    for i,face in next,self.rewardsUIFaces do
        local closestFace = self:detectClosestFace(face.x, face.y)
        if(closestFace) then
            local diceObject = self.uiDices[closestFace[3]][closestFace[4]].diceObject
            diceObject:setFace(face.representedObject, closestFace[4])
        end
    end
    self:outAnimation()
end

function DiceCustomization:detectClosestFace(x, y)
    local relativeXPositions = { -- this table represents the position of the dice after applying the offset
        0, 0, 0, 0, 0, 0
    }

    local relativeYPositions = {
        60, 180, 300, 420, 540, 660
    }

    local basisY = 80 + 30 + 60

    for i=1,5 do --loop over dices
        local basisX = 160*(i-1) + self.customizationMatX +90+60
        for j=1,6 do --loop over faces 
            if(math.abs((x+60)-(relativeXPositions[j]+basisX))<60 and math.abs((y+60)-(relativeYPositions[j]+basisY))<60) then
                return({relativeXPositions[j]+basisX-60, relativeYPositions[j]+basisY-60, i, j})
            end
        end
    end
    return nil
end

function DiceCustomization:createInventoryUI()
    self.xPositions = {20, 150, 20, 150, 20, 150, 20, 150}
    self.yPositions = {70, 70, 200, 200, 330, 330, 460, 460}


    local startY = self.canvas:getHeight()/2
    local startX = -120

    for i,face in next,self.newFaceObjects do
        local diceFace = DiceFace:new(nil,
                                    face,
                                    startX,
                                    startY,
                                    120,
                                    false,
                                    true,
                                    function()return Inputs.getMouseInCanvas(0, 0)end,
                                    nil)
        diceFace.animator:addDelay(0.3)
        local duration = math.random(2, 8)/10
        
        local randomAngle = math.random(-500, 500)/100

        diceFace.animator:addGroup({
                {property = "x", from = startX, targetValue = self.xPositions[i] + self.inventoryMDTX + 60, duration = duration,easing = AnimationUtils.Easing.outQuad},
                {property = "targetX", from = startX, targetValue = self.xPositions[i] + self.inventoryMDTX + 60, duration = duration, easing = AnimationUtils.Easing.outQuad},
                {property = "y", from = startY, targetValue = self.yPositions[i] + self.inventoryMDTY + 60, duration = duration, easing = AnimationUtils.Easing.outQuad},
                {property = "targetY", from = startY, targetValue = self.yPositions[i] + self.inventoryMDTY + 60, duration = duration, easing = AnimationUtils.Easing.outQuad},
                {property = "rotation", from = randomAngle, targetValue = 0, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "baseRotation", from = randomAngle, targetValue = 0, duration = duration, easing = AnimationUtils.Easing.inCubic},
            })

        table.insert(self.newUIFaces, diceFace)
                                    
    end
end

function DiceCustomization:createRewardsUI()
    self.xPositionsRewards = {20, 150}
    self.yPositionsRewards = {70, 70}


    local startY = self.canvas:getHeight()/2
    local startX = -120

    for i,face in next,self.run.facesRewardsInventory do
        local diceFace = DiceFace:new(nil,
                                    face,
                                    startX,
                                    startY,
                                    120,
                                    false,
                                    true,
                                    function()return Inputs.getMouseInCanvas(0, 0)end,
                                    nil)

        diceFace.animator:addDelay(0.3)
        local duration = math.random(2, 8)/10
        
        local randomAngle = math.random(-500, 500)/100

        diceFace.animator:addGroup({
                {property = "x", from = startX, targetValue = self.xPositionsRewards[i] + self.rewardsMDTX + 60, duration = duration,easing = AnimationUtils.Easing.outQuad},
                {property = "targetX", from = startX, targetValue = self.xPositionsRewards[i] + self.rewardsMDTX + 60, duration = duration, easing = AnimationUtils.Easing.outQuad},
                {property = "y", from = startY, targetValue = self.yPositionsRewards[i] + self.rewardsMDTY + 60, duration = duration, easing = AnimationUtils.Easing.outQuad},
                {property = "targetY", from = startY, targetValue = self.yPositionsRewards[i] + self.rewardsMDTY + 60, duration = duration, easing = AnimationUtils.Easing.outQuad},
                {property = "rotation", from = randomAngle, targetValue = 0, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "baseRotation", from = randomAngle, targetValue = 0, duration = duration, easing = AnimationUtils.Easing.inCubic},
            })

        table.insert(self.rewardsUIFaces, diceFace)
                                    
    end
end

function DiceCustomization:createDiceUI(diceObject, i)
    --This function creates every faces of a ui Dice and stores them in a table located in self.uiDices
    local diceUI = {}
    local xOffset = 160*(i-1) + self.customizationMatX +90 -- the base position of the dice
    local yOffset = 80 + 30
    
    local relativeXPositions = { -- this table represents the position of the dice after applying the offset
        0, 0, 0, 0, 0, 0
    }

    local relativeYPosition = {
        60, 180, 300, 420, 540, 660
    }

    for k,faceObject in next,diceObject:getAllFaces() do
        
        local possibleXs = {-200, self.canvas:getWidth()+200}

        local startX = possibleXs[math.random(1, #possibleXs)]
        local startY = self.canvas:getHeight()/2

        --Create a dice face ui with the dice
        local diceFace = DiceFace:new(diceObject,
                                    faceObject,
                                    startX,
                                    startY,
                                    120,
                                    true,
                                    true,
                                    function()return Inputs.getMouseInCanvas(0, 0)end,
                                    nil)

        local duration = math.random(3, 5)/10 -- the duration of the animation
        local delayStart = math.random(1, 3)/10 --a little delay before it starts to desynchronize the dices
        diceFace.animator:addDelay(delayStart) --applying the delay

        local randomAngle = math.random(-500, 500)/100

        diceFace.animator:addDelay(0.3)
        diceFace.animator:addGroup({
            {property = "x", from = startX, targetValue = xOffset + relativeXPositions[k], duration = duration, easing = AnimationUtils.Easing.outCubic},
            {property = "y", from = startY, targetValue = yOffset + relativeYPosition[k], duration = duration, easing = AnimationUtils.Easing.outCubic},
            {property = "targetX", from = startX, targetValue = xOffset + relativeXPositions[k], duration = duration, easing = AnimationUtils.Easing.outCubic},
            {property = "targetY", from = startY, targetValue = yOffset + relativeYPosition[k], duration = duration, easing = AnimationUtils.Easing.outCubic},
            {property = "rotation", from = randomAngle, targetValue = 0, duration = duration, easing = AnimationUtils.Easing.outCubic},
            {property = "baseRotation", from = randomAngle, targetValue = 0, duration = duration, easing = AnimationUtils.Easing.outCubic}

        })
        
        table.insert(diceUI, diceFace)
    end

    return diceUI
end

--==Hovered objects==--

function DiceCustomization:getCurrentlyHoveredFace()
    self.previouslyHoveredFace = self.currentlyHoveredFace --We save the state of the frame before
    self.currentlyHoveredFace = nil

    for i,dice in next,self.uiDices do
        for j,face in next,dice do
            if face:isHovered() then self.currentlyHoveredFace = face ; break end
        end
    end

    for i,face in next,self.newUIFaces do
        if face:isHovered() then self.currentlyHoveredFace = face ; break end
    end

    for i,face in next,self.rewardsUIFaces do
        if face:isHovered() then self.currentlyHoveredFace = face ; break end
    end

end

function DiceCustomization:getCurrentlyHoveredCiggie()
    self.currentlyHoveredCiggie = nil

    for i,ciggie in next,self.uiElements.ciggiesUI do
        if(ciggie:isHovered())then
            self.currentlyHoveredCiggie = ciggie
            break
        end
    end
end

--Gets the currently hovered object (dice, ciggie, etc...)
function DiceCustomization:getCurrentlyHoveredObject()
    local object = nil

    if(self.currentlyHoveredCiggie)then object = self.currentlyHoveredCiggie.representedObject
    elseif(self.currentlyHoveredFace)then object = self.currentlyHoveredFace.representedObject
    else object = nil end
    
    return object
end

function DiceCustomization:addRewardToInventory(face, key)

    --Supprimer la face de la liste des rewards
    table.remove(self.run.facesRewardsInventory, key)
    --Ajouter la face à l'inventaire de jeu
    table.insert(self.run.facesInventory, face.representedObject)
    --Supprimer la face UI des rewards
    table.remove(self.rewardsUIFaces, key)
    --Ajouter la face UI à l'inventaire
    table.insert(self.newUIFaces, face)

    --Réorganiser l'inventaire
    self:updateInventoryPositions()
end

function DiceCustomization:sellReward(face, faceUI, key)
    --Add money to bank account
    self.run.money = self.run.money + 3

    --Remove dice face object from inventory

    table.remove(self.run.facesRewardsInventory, key)
    local apparitionDuration = 0.3

    --Remove dice face from ui with animation
    faceUI.animator:addGroup({
            --Rotation
            {property = "rotation", from = 0, targetValue = -2, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 0, targetValue = -2, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            --Scale
            {property = "baseTargetedScale", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack, onComplete = function()table.remove(self.rewardsUIFaces, key)end},
            
        })
    
end

function DiceCustomization:sellDiceFace(face, faceUI, key)
    --Add money to bank account
    self.run.money = self.run.money + 3

    --Remove dice face object from inventory

    table.remove(self.run.facesInventory, key)
    local apparitionDuration = 0.3

    --Remove dice face from ui with animation
    faceUI.animator:addGroup({
            --Rotation
            {property = "rotation", from = 0, targetValue = -2, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 0, targetValue = -2, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            --Scale
            {property = "baseTargetedScale", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack, onComplete = function()table.remove(self.newUIFaces, key);self:updateInventoryPositions()end},
            
        })
    
end

function DiceCustomization:updateInventoryPositions()
    for i,uiFace in next,self.newUIFaces do
        uiFace.anchorX = self.xPositions[i] + 60+ self.inventoryMDTX
        uiFace.anchorY = self.yPositions[i] + self.inventoryMDTY + 60
        uiFace.targetX = self.xPositions[i] + 60+ self.inventoryMDTX
        uiFace.targetY = self.yPositions[i] + self.inventoryMDTY + 60
    end
end

return DiceCustomization