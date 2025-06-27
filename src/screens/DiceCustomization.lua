--==IMPORTS==--
local Sprites = require("src.utils.Sprites")
local DiceFace = require("src.classes.ui.DiceFace")
local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local Button = require("src.classes.ui.Button")
local AnimationUtils = require("src.utils.scripts.Animations")
local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")
local Screen = require("src.classes.GameScreen")
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
    --On peuple notre table
    
    for i,dice in next, self.diceObjects do
        table.insert(self.uiDices, self:createDiceUI(dice, i))
    end

    self.uiElements.buttons["nextRound"] = Button:new(
        function()self:switchFaces()end,
        "src/assets/sprites/ui/Next Round.png",
        self.nextRoundX,
        self.nextRoundY,
        450,
        60,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.buttons["nextRound"].animator:add('x', self.nextRoundX, self.nextRoundTX, AnimationUtils.EntryDuration, AnimationUtils.Easing.inOutCubic)

    self:createNewFacesUI()

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

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end
    
end

function DiceCustomization:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    --UI

    --Run informations
    self:drawRoundDetails()
    --Description
    self:drawDescription()
    --New Faces Canvas
    self:drawNewFacesCanvas()
    --Customization mat
    self:drawCustomizationMat()
    --Ciggies
    self:drawCiggiesTray()

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:draw()
    end

    --Draw the deck dices on the canvas
    for i,uiDice in next,self.uiDices do
        for j,uiFace in next,uiDice do
            uiFace:draw()
        end
    end

    self:drawNewFaces()

     --Update the hover info
    if(self.currentlyHoveredFace)then
        self.hoverInfosCanvas:update(dt)
        self.hoverInfosCanvas:draw()
    end

    --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
        ciggie:draw()
    end

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

    for i,face in next,self.newUIFaces do
        face:releaseEvent()
        
        local closestFace = self:detectClosestFace(face.x, face.y)

        if(closestFace) then
            face.anchorX = closestFace[1]
            face.anchorY = closestFace[2]
        else
            face.anchorX = self.xPositions[i]
            face.anchorY = 880
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
    end

end

function DiceCustomization:mousemoved(x, y, dx, dy, isDragging)
    if(isDragging == true)then 
        for key,diceui in next, self.newUIFaces do
            if(diceui.isDraggable and diceui.isBeingClicked) then
                diceui.isBeingDragged = true
                diceui.dragXspeed = dx
                diceui.targetX = (diceui.targetX + dx) 
                diceui.targetY = (diceui.targetY + dy)
                
            end
        end

        for key,ciggie in next, self.uiElements.ciggiesUI do
            if(ciggie.isDraggable and ciggie.isBeingClicked) then
                ciggie.isBeingDragged = true
                ciggie.dragXspeed = dx
                if(ciggie.targetX+dx<self.canvas:getWidth()-ciggie.width/2 and ciggie.targetX+dx>0+ciggie.width/2) then --Vérification qu'on ne dépasse par les limites horizontales
                    ciggie.targetX = (ciggie.targetX + dx) 
                end

                if(ciggie.targetY+dy<self.canvas:getHeight()-ciggie.height/2 and ciggie.targetY+dy>0+ciggie.height/2) then --Vérification qu'on ne dépasse pas les limites verticales
                    ciggie.targetY = (ciggie.targetY + dy) 
                end
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
        face:draw()
    end
end

--==UTILS=--

function DiceCustomization:outAnimation()
    local outDuration = 0.4
    self.animator:addGroup({
        {property = "customizationMatY", from = self.customizationMatY, targetValue = -700, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.canvas:getWidth()+600, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "newFacesY", from = self.newFacesY, targetValue = self.canvas:getHeight()+500, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.canvas:getWidth()+450, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        
        {property = "moneyY", from = self.moneyY, targetValue = self.canvas:getHeight()+300, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = -730, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = -500, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.canvas:getHeight()+400, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
    })

    --Buttons animation
    self.uiElements.buttons["nextRound"].animator:add('x', self.nextRoundX, -500, outDuration)
    self.uiElements.buttons["menuButton"].animator:add('x', self.menuBtnX, -150, outDuration)
    self.uiElements.buttons["planButton"].animator:add('x', self.planBtnX, -150, outDuration)

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

    --Reward Faces exit
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
    self:outAnimation()
end

function DiceCustomization:detectClosestFace(x, y)
    local relativeXPositions = { -- this table represents the position of the dice after applying the offset
        180, 60, 180, 300, 180, 180
    }

    local relativeYPositions = {
        60, 180, 180, 180, 300, 420
    }

    local basisY = 180

    for i=1,5 do --loop over dices
        local basisX = 120+360*(i-1)        
        for j=1,6 do --loop over faces 
            if(math.abs((x+60)-(relativeXPositions[j]+basisX))<40 and math.abs((y+60)-(relativeYPositions[j]+basisY))<40) then
                return({relativeXPositions[j]+basisX-60, relativeYPositions[j]+basisY-60, i, j})
            end
        end
    end
    return nil
end

function DiceCustomization:createNewFacesUI()
    self.xPositions = self:getCenteredPositions(table.getn(self.newFaceObjects), 120, 20, self.canvas:getWidth()/2+60)

    local startY = self.canvas:getHeight()/2
    local startX = -120

    for i,face in next,self.newFaceObjects do
        local diceFace = DiceFace:new(nil,
                                    face,
                                    startX,
                                    startY,
                                    120,
                                    true,
                                    true,
                                    function()return Inputs.getMouseInCanvas(0, 0)end,
                                    nil)
        diceFace.animator:addDelay(0.3)
        local duration = math.random(2, 8)/10
        
        local randomAngle = math.random(-500, 500)/100

        diceFace.animator:addGroup({
                {property = "x", from = startX, targetValue = self.xPositions[i], duration = duration,easing = AnimationUtils.Easing.outQuad},
                {property = "targetX", from = startX, targetValue = self.xPositions[i], duration = duration, easing = AnimationUtils.Easing.outQuad},
                {property = "y", from = startY, targetValue = 880, duration = duration, easing = AnimationUtils.Easing.outQuad},
                {property = "targetY", from = startY, targetValue = 880, duration = duration, easing = AnimationUtils.Easing.outQuad},
                {property = "rotation", from = randomAngle, targetValue = 0, duration = duration, easing = AnimationUtils.Easing.inCubic},
                {property = "baseRotation", from = randomAngle, targetValue = 0, duration = duration, easing = AnimationUtils.Easing.inCubic},
            })

        table.insert(self.newUIFaces, diceFace)
                                    
    end
end

function DiceCustomization:createDiceUI(diceObject, i)
    --This function creates every faces of a ui Dice and stores them in a table located in self.uiDices
    local diceUI = {}
    local xOffset = 120+360*(i-1) - 60 -- the base position of the dice
    local yOffset = 180 - 60
    
    local relativeXPositions = { -- this table represents the position of the dice after applying the offset
        180, 60, 180, 300, 180, 180
    }

    local relativeYPosition = {
        60, 180, 180, 180, 300, 420
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

    --Si un dé est survolé et qu'il est différent du dé précédent alors on créé un nouveau canvas d'infos
    if(self.currentlyHoveredFace ~= self.previouslyHoveredFace) then
        if (self.currentlyHoveredFace) then
            self.hoverInfosCanvas = FaceHoverInfo:new(self.currentlyHoveredFace, "points", 0, 0)
        end
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

return DiceCustomization