local DiceFace = require("src.classes.ui.DiceFace")
local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")
local Button = require("src.classes.ui.Button")
local DeskChoice = require("src.screens.DeskChoice")

local Fonts = require("src.utils.fonts")

local Animator = require("src.utils.Animator")
local AnimationUtils = require("src.utils.scripts.animationUtils")

local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")

local DiceCustomization = {}
DiceCustomization.__index = DiceCustomization

--Sprites
local descriptionSprite = love.graphics.newImage("src/assets/sprites/ui/Description.png")
local DiceInfosSprite = love.graphics.newImage("src/assets/sprites/ui/DiceComposition.png")
local FloorInfosSprite= love.graphics.newImage("src/assets/sprites/ui/Office.png")
local MoneySprite= love.graphics.newImage("src/assets/sprites/ui/Money.png")
local RerollsSprite= love.graphics.newImage("src/assets/sprites/ui/Rerolls.png")
local TurnsSprite= love.graphics.newImage("src/assets/sprites/ui/Turns.png")
local newFacesImage = love.graphics.newImage("src/assets/sprites/ui/Rewards.png")
local CustomMatImage = love.graphics.newImage("src/assets/sprites/ui/Customization Mat.png")

function DiceCustomization:new(previousRound, newFaceObjects)
    local self = setmetatable({}, DiceCustomization)

    self.uiElements = {
        buttons = {}
    }

    self.animator = Animator:new(self)

    --Link with the game
    self.diceObjects = previousRound.diceObjects
    self.previousRound = previousRound

    --The selected face object to modify
    self.selectedDiceFace = nil
    self.selectedNewDiceFace = nil

    --Table where we store the ui faces of the face objects earned
    self.newFaceObjects = newFaceObjects
    --Table where we store the ui dice faces, grouped by dice
    self.uiDices = {}

    self.newUIFaces = {}
    --On peuple notre table
    
    for i,dice in next, self.diceObjects do
        table.insert(self.uiDices, self:createDiceUI(dice, i))
    end

    --Create the canvas
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    --The other canvas
    self.newFacesCanvas = love.graphics.newCanvas(950, 400)
    self.descriptionCanvas = love.graphics.newCanvas(420, 390)
    self.rerollsCanvas = love.graphics.newCanvas(220, 120)
    self.handsCanvas = love.graphics.newCanvas(220, 120)
    self.roundNumberCanvas = love.graphics.newCanvas(290, 80)
    self.moneyCanvas = love.graphics.newCanvas(290, 100)
    self.customizationMat = love.graphics.newCanvas(1860, 600)

     --Positions
    self.newFacesTX, self.newFacesTY, self.newFacesX, self.newFacesY = 500, 650, 500, self.canvas:getHeight()+450
    self.diceDetailsTX, self.diceDetailsTY, self.diceDetailsX, self.diceDetailsY = self.canvas:getWidth()-30, 30, self.canvas:getWidth()+600, 30
    self.descriptionTX, self.descriptionTY, self.descriptionX, self.descriptionY = self.canvas:getWidth()-30, 650, self.canvas:getWidth()+600, 650
    
    self.customizationMatTX, self.customizationMatTY, self.customizationMatX, self.customizationMatY = 30, 30, 30, -700

    self.rerollsTX, self.rerollsTY, self.rerollsX, self.rerollsY = 260, 721, -500, 721
    self.turnsTX, self.turnsTY, self.turnsX, self.turnsY = 30, 721, -730, 721
    self.floorTX, self.floorTY, self.floorX, self.floorY = 190, 970, 190, self.canvas:getHeight()+400
    self.moneyTX, self.moneyTY, self.moneyX, self.moneyY = 190, 860, 190, self.canvas:getHeight()+300

    --Btns positions
    self.planBtnTX, self.planBtnTY, self.planBtnX, self.planBtnY = 100, 910, -150, 910
    self.menuBtnTX, self.menuBtnTY, self.menuBtnX, self.menuBtnY = 100, 1010, -150, 1010
    self.nextRoundTX, self.nextRoundTY, self.nextRoundX, self.nextRoundY = 255, 680, -255, 680

    --Entry animation
    local entryDuration = 0.2
    self.animator:addGroup({
        {property = "newFacesY", from = self.newFacesY, targetValue = self.newFacesTY, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.descriptionTX, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
        {property = "moneyY", from = self.moneyY, targetValue = self.moneyTY, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = self.turnsTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = self.rerollsTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.floorTY, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "customizationMatY", from = self.customizationMatY, targetValue = self.customizationMatTY, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
    
    })

    self.uiElements.buttons["menuButton"] = Button:new(
        function()print("menu")end,
        "src/assets/sprites/ui/Menu.png",
        self.menuBtnX,
        self.menuBtnY,
        140,
        80,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.buttons["planButton"] = Button:new(
        function()print("plan")end,
        "src/assets/sprites/ui/Plan.png",
        self.planBtnX,
        self.planBtnY,
        140,
        100,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

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

    self.uiElements.buttons["menuButton"].animator:add('x', self.menuBtnX, self.menuBtnTX, entryDuration, AnimationUtils.Easing.inOutCubic)
    self.uiElements.buttons["planButton"].animator:add('x', self.planBtnX, self.planBtnTX, entryDuration, AnimationUtils.Easing.inOutCubic)
    self.uiElements.buttons["nextRound"].animator:add('x', self.nextRoundX, self.nextRoundTX, entryDuration, AnimationUtils.Easing.inOutCubic)

    self:createNewFacesUI()


    return self
end

function DiceCustomization:update(dt)
    --Get hovered face
    self:getCurrentlyHoveredFace()
    
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
    self:drawDescriptionCanvas()
    --New Faces Canvas
    self:drawNewFacesCanvas()
    --Customization mat
    self:drawCustomizationMat()

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
        print("ok")
        self.hoverInfosCanvas:update(dt)
        self.hoverInfosCanvas:draw()
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

end

function DiceCustomization:mousereleased(x, y, button, istouch, presses)

    for i,face in next,self.newUIFaces do
        face:releaseEvent()
        
        closestFace = self:detectClosestFace(face.x, face.y)

        print(closestFace)

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

    end

    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
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
    end
end

--==Draw UI==--
--Run Infos
function DiceCustomization:drawRoundDetails()
    local currentCanvas = love.graphics.getCanvas()
    --Create the texts
    local rerollText = love.graphics.newText(Fonts.nexaBig, tostring(self.previousRound.availableRerolls))
    local currentHands = love.graphics.newText(Fonts.nexaBig, tostring(self.previousRound.remainingHands))
    local currentRoundText = love.graphics.newText(Fonts.nexa30, 'Floor '..tostring(self.previousRound.floorNumber)..'\nDesk : '..tostring(self.previousRound.deskNumber))
    local moneyText = love.graphics.newText(Fonts.nexaBig, tostring(self.previousRound.run.money).."€")

    --ROUND
    love.graphics.setCanvas(self.roundNumberCanvas)
    love.graphics.clear()
    love.graphics.draw(FloorInfosSprite, 0, 0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(currentRoundText, self.roundNumberCanvas:getWidth()/2, self.roundNumberCanvas:getHeight()/2, 0, 1, 1, currentRoundText:getWidth()/2, currentRoundText:getHeight()/2)
    love.graphics.setColor(1, 1, 1, 1)
    --HANDS
    love.graphics.setCanvas(self.handsCanvas)
    love.graphics.clear()
    love.graphics.draw(TurnsSprite, 0, 0)
    love.graphics.setColor(245/255, 247/255, 228/255, 1)
    love.graphics.draw(currentHands, self.handsCanvas:getWidth()/2, self.handsCanvas:getHeight()/2+35, 0, 1, 1, currentHands:getWidth()/2, currentHands:getHeight()/2+3)
    love.graphics.setColor(1, 1, 1, 1)

    --REROLLS
    love.graphics.setCanvas(self.rerollsCanvas)
    love.graphics.clear()
    love.graphics.draw(RerollsSprite, 0, 0)
    love.graphics.setColor(245/255, 247/255, 228/255, 1)
    love.graphics.draw(rerollText, self.rerollsCanvas:getWidth()/2, self.rerollsCanvas:getHeight()/2+35, 0, 1, 1, rerollText:getWidth()/2, rerollText:getHeight()/2+3)
    love.graphics.setColor(1, 1, 1, 1)

    --MONEY
    love.graphics.setCanvas(self.moneyCanvas)
    love.graphics.clear()
    love.graphics.draw(MoneySprite,0,0)
    love.graphics.setColor(1, 195/256, 132/256, 1)
    love.graphics.draw(moneyText, self.moneyCanvas:getWidth()/2, self.moneyCanvas:getHeight()/2, 0, 1, 1, moneyText:getWidth()/2, moneyText:getHeight()/2-10)
    love.graphics.setColor(1, 1, 1, 1)


    --DRAW ALL THE CANVAS
    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.roundNumberCanvas, self.floorX, self.floorY)
    love.graphics.draw(self.handsCanvas, self.turnsX, self.turnsY)
    love.graphics.draw(self.rerollsCanvas, self.rerollsX, self.rerollsY)
    love.graphics.draw(self.moneyCanvas, self.moneyX, self.moneyY)
end

--Description
function DiceCustomization:drawDescriptionCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.descriptionCanvas)
    love.graphics.clear()
    --Draw Sprite
    love.graphics.draw(descriptionSprite, 0, 0)


    if(self.currentlyHoveredFace) then

        --Face Name
        local faceName = self.currentlyHoveredFace.representedFace.name
        local nameText = love.graphics.newText(Fonts.nexaMedium, faceName)

        --Face tier
        local tierText = love.graphics.newText(
            Fonts.nexaSmall,
            self.currentlyHoveredFace.representedFace.tier
        )

        --Description
        local faceDescription = self.currentlyHoveredFace.representedFace.description
        local descWidth, descWrappedtext = Fonts.nexaDesc:getWrap( faceDescription, self.descriptionCanvas:getWidth()-20 )
        local descText = love.graphics.newText(Fonts.nexaDesc, table.concat(descWrappedtext, "\n"))
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.draw(nameText, self.descriptionCanvas:getWidth()/2, 65, 0, 1, 1, nameText:getWidth()/2, 0)
        love.graphics.draw(tierText, self.descriptionCanvas:getWidth()/2, 105, 0, 1, 1, tierText:getWidth()/2, 0)
        love.graphics.draw(descText, self.descriptionCanvas:getWidth()/2, 140, 0, 1, 1, descText:getWidth()/2, 0)
        love.graphics.setColor(1, 1, 1, 1)

    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.descriptionCanvas, self.descriptionX, self.descriptionY, 0, 1, 1, self.descriptionCanvas:getWidth(), 0)
end

function DiceCustomization:drawNewFacesCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.newFacesCanvas)
    love.graphics.clear()

    love.graphics.draw(newFacesImage, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.newFacesCanvas, self.newFacesX, self.newFacesY, 0, 1, 1)
end

function DiceCustomization:drawCustomizationMat()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.customizationMat)
    love.graphics.clear()

    love.graphics.draw(CustomMatImage, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.customizationMat, self.customizationMatX, self.customizationMatY, 0, 1, 1)
end

function DiceCustomization:drawNewFaces()
    for i,face in next,self.newUIFaces do
        face:draw()
    end
end



function DiceCustomization:flipFaces()
    print("flip faces")
    --First, get the dice concerned by the change
    local dice = self.selectedDiceFace.diceObject
    local oldFace = self.selectedDiceFace
    local newFace = self.selectedNewDiceFace

    --Then, find the index of the face in the dice
    local oldfaceindex = nil
    for i,f in next,dice:getAllFaces() do
        if(f == self.selectedDiceFace) then
            oldfaceindex = i
        end
    end

    --Find the index of the new face selected
    local newfaceindex = nil
    for i,f in next,self.newFaceObjects do
        print(tostring(f).." "..tostring(self.selectedNewDiceFace))
        if(f == self.selectedNewDiceFace) then
            newfaceindex = i
        end
    end

    --Also, get the index of the dice that will get the change
    local diceindex = nil
    for i,f in next,self.diceObjects do
        if(f==dice)then
            diceindex = i
        end
    end

    --Set the new face on the dice
    dice:setFace(newFace, oldfaceindex) --We set the new face
    oldFace:setDiceObject(nil) --We reset the dice attached to the old dice face object

    --Then, Change the new face as the previous face on the dice
    self.newFaceObjects[newfaceindex] = oldFace 

    --Flip the UI on the dice
    self.uiDices[diceindex][oldfaceindex]:flipChange(newFace)

    --Flip the UI on the top
    self.newUIFaces[newfaceindex]:flipChange(oldFace)

    --Reset the selection
    self:resetSelectedDices()
    self:resetSelectedNewFace()
    self.selectedDiceFace, self.selectedNewDiceFace = nil, nil
end

--==UTILS=--
function DiceCustomization:switchFaces()
    for i,face in next,self.newUIFaces do
        closestFace = self:detectClosestFace(face.x, face.y)
        if(closestFace) then
            local diceObject = self.uiDices[closestFace[3]][closestFace[4]].diceObject
            diceObject:setFace(face.representedFace, closestFace[4])
            --print(self.uiDices[closestFace[3]][closestFace[4]].representedFace.name, self.uiDices[closestFace[3]][closestFace[4]].representedFace.faceValue, self.uiDices[closestFace[3]][closestFace[4]].diceObject)
        end
    end
    self:goToRoundSelection()
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

function DiceCustomization:resetSelectedDices()
    --Dice faces
    for key,dice in next,self.uiDices do
        for j, uiFace in next,dice do
            uiFace:setSelected(false)
        end
    end 
end

function DiceCustomization:resetSelectedNewFace()
    --Dice faces
    for key,face in next,self.newUIFaces do
        face:setSelected(false)
    end 
end

function DiceCustomization:createNewFacesUI()
    self.xPositions = self:getCenteredPositions(table.getn(self.newFaceObjects), 120, 20, self.canvas:getWidth()/2+60)

    for i,face in next,self.newFaceObjects do
        local diceFace = DiceFace:new(nil,
                                    face,
                                    self.xPositions[i],
                                    880,
                                    120,
                                    true,
                                    true,
                                    function()return Inputs.getMouseInCanvas(0, 0)end,
                                    nil)

        diceFace.anchorX = self.xPositions[i]
        diceFace.anchorY = 880

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
        
        --Create a dice face ui with the dice
        local diceFace = DiceFace:new(diceObject,
                                    faceObject,
                                    xOffset + relativeXPositions[k],
                                    yOffset + relativeYPosition[k],
                                    120,
                                    true,
                                    true,
                                    function()return Inputs.getMouseInCanvas(0, 0)end,
                                    nil)
        table.insert(diceUI, diceFace)
    end

    return diceUI
end

function DiceCustomization:goToRoundSelection()
    self.previousRound.run.deskChoice = DeskChoice:new(self.previousRound.run.currentFloor, self.previousRound.run)
    self.previousRound.run.currentState = Constants.RUN_STATES.ROUND_CHOICE --Change d'état de Run
end

function DiceCustomization:getCenteredPositions(count, objectWidth, spacing, centerX)
    local totalWidth = count * objectWidth + (count - 1) * spacing
    local startX = centerX - totalWidth / 2

    local positions = {}
    for i = 0, count - 1 do
        local x = startX + i * (objectWidth + spacing)
        table.insert(positions, x)
    end

    return positions
end

function DiceCustomization:createFaceInfosCanvas(face)
    return FaceHoverInfo:new(face, "points")
end

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
            self.hoverInfosCanvas = self:createFaceInfosCanvas(self.currentlyHoveredFace)
        end
    end

end

return DiceCustomization