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
local descriptionSprite = love.graphics.newImage("src/assets/sprites/ui/terrain/Description-proto.png")
local FloorInfosSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Floor-proto.png")
local MoneySprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Money-proto.png")
local RerollsSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Rerolls-proto.png")
local TurnsSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Turns-proto.png")
local deckBackGroundImage = love.graphics.newImage("src/assets/sprites/ui/terrain/deck_deskchoice_proto.png")
local newFacesImage = love.graphics.newImage("src/assets/sprites/ui/terrain/newfaces-proto.png")
local dicesImage = love.graphics.newImage("src/assets/sprites/ui/terrain/customization-mat-proto")

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
    --[[ for i,dice in next, self.diceObjects do
        table.insert(self.uiDices, self:createDiceUI(dice, i))
    end ]]

    --Create the canvas
    self.screenCanvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    --The other canvas
    self.newFacesCanvas = love.graphics.newCanvas(620*1.5, 260*1.5)
    self.descriptionCanvas = love.graphics.newCanvas(420, 390)
    self.handsCanvas = love.graphics.newCanvas(240, 150)
    self.rerollsCanvas = love.graphics.newCanvas(240, 150)
    self.moneyCanvas = love.graphics.newCanvas(240, 90)
    self.roundNumberCanvas = love.graphics.newCanvas(240, 90)

    --Positions
    self.gridTX, self.gridTY, self.gridX, self.gridY = 30, 30, 30, -650
    self.newFacesTX, self.newFacesTY, self.newFacesX, self.newFacesY = self.screenCanvas:getWidth()/2, self.screenCanvas:getHeight()-30, self.screenCanvas:getWidth()/2, self.screenCanvas:getHeight()+600
    self.descriptionTX, self.descriptionTY, self.descriptionX, self.descriptionY = self.screenCanvas:getWidth()-30, self.screenCanvas:getHeight()-30, self.screenCanvas:getWidth()+600, self.screenCanvas:getHeight()-30
    self.descriptionTX, self.descriptionTY, self.descriptionX, self.descriptionY = self.screenCanvas:getWidth()-30, self.screenCanvas:getHeight()-30, self.screenCanvas:getWidth()+600, self.screenCanvas:getHeight()-30

    --Entry animation
    local entryDuration = 0.2
    self.animator:addGroup({
        --{property = "gridY", from = self.gridY, targetValue = self.gridTY, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
        {property = "newFacesY", from = self.newFacesY, targetValue = self.newFacesTY, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.descriptionTX, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
        --{property = "deckY", from = self.deckY, targetValue = self.deckTY, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
    })

    --Create the switch button
    --[[ self.uiElements.buttons.switchButton = Button:new(
        function()self:flipFaces()end, 
        "src/assets/sprites/ui/terrain/Reroll-proto.png", 
        self.screenCanvas:getWidth()/2, 
        self.screenCanvas:getHeight()-75, 
        420, 
        60,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.buttons.nextRoundButton = Button:new(
        function()self:goToRoundSelection()end, 
        "src/assets/sprites/ui/buttons/next_round.png", 
        self.screenCanvas:getWidth()/2, 
        self.screenCanvas:getHeight()-150, 
        420, 
        60,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    ) ]]

    --self:createNewFacesUI()


    return self
end

function DiceCustomization:update(dt)
    --Get hovered face
    --self:getCurrentlyHoveredFace()
    
    --Update animations
    self.animator:update(dt)

    --update the canvas
    self:updateCanvas(dt)

    --Update the dice faces
    --Draw the uiFaces on the canvas
    --[[ for i,uiDice in next,self.uiDices do
        for j,uiFace in next,uiDice do
            uiFace:update(dt)
            if(uiFace:getIsSelected())then
                uiFace.selectionScale = -0.2
            else
                uiFace.selectionScale = 0
            end
        end
    end ]]

    --New faces
    --[[ for i,uiFace in next,self.newUIFaces do
        uiFace:update(dt)
        if(uiFace:getIsSelected())then
            uiFace.selectionScale = -0.2
        else
            uiFace.selectionScale = 0
        end
    end ]]

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end
    --Disable switch button
    --self.uiElements.buttons.switchButton:setActivated(self.selectedDiceFace ~= nil and self.selectedNewDiceFace ~= nil)
    
end

function DiceCustomization:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.screenCanvas)
    love.graphics.clear(89/255, 153/255, 255/255)

    --UI

    --Run informations
    self:drawRoundDetails()
    --Description
    self:drawDescriptionCanvas()
    --New Faces
    self:drawNewFacesCanvas()

    --[[ --Draw the uiFaces on the canvas
    for i,uiDice in next,self.uiDices do
        for j,uiFace in next,uiDice do
            uiFace:draw()
        end
    end

    --New faces
    for i,uiFace in next,self.newUIFaces do
        uiFace:draw()
    end

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:draw()
    end ]]

    --[[  --Update the hover info
    if(self.currentlyHoveredFace)then
        self.hoverInfosCanvas:update(dt)
        self.hoverInfosCanvas:draw()
    end]]

    love.graphics.setCanvas(currentCanvas)
end

function DiceCustomization:draw()
    love.graphics.draw(self.screenCanvas, 0, 0)
end

--==INPUTS FUNCTIONS==--
function DiceCustomization:keypressed(key)
    print("keypressed")
end

function DiceCustomization:mousepressed(x, y, button, istouch, presses)
   --[[ --Buttons
    for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end

    --Dice faces
    for key,dice in next,self.uiDices do
        for j, uiFace in next,dice do
            uiFace:clickEvent()
        end
    end

    --New Dice Faces
    for i,uiFace in next,self.newUIFaces do
        uiFace:clickEvent()
    end ]]

end

function DiceCustomization:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    --[[ for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    for i,dice in next,self.diceObjects do
        for key,face in next,self.uiDices[i] do
            local wasReleased = face:releaseEvent()
            if(wasReleased)then --On sélectionne la face a switcher
                self:resetSelectedDices()
                face:setSelected(true)
                self.selectedDiceFace = face.representedFace
            end
        end
    end

    for i,face in next,self.newUIFaces do
        local wasReleased = face:releaseEvent()
        if(wasReleased)then --On sélectionne la face a switcher
            self:resetSelectedNewFace()
            face:setSelected(true)
            self.selectedNewDiceFace = face.representedFace
        end
    end ]]
end

function DiceCustomization:mousemoved(x, y, dx, dy, isDragging)
    
end

--==Draw UI==--
--Run Infos
function DiceCustomization:drawRoundDetails()
    local currentCanvas = love.graphics.getCanvas()
    --Create the texts
    local rerollText = love.graphics.newText(Fonts.nexaBig, tostring("-"))
    local currentHands = love.graphics.newText(Fonts.nexaBig, tostring("-"))
    local currentRoundText = love.graphics.newText(Fonts.nexaSmall, 'Floor '..tostring(self.previousRound.floorNumber)..'\nDesk : '..tostring(0))
    local moneyText = love.graphics.newText(Fonts.nexaSmall, tostring(self.previousRound.run.money).."€")

    --ROUND
    love.graphics.setCanvas(self.roundNumberCanvas)
    love.graphics.clear(0, 0, 1)
    love.graphics.draw(FloorInfosSprite, 0, 0)
    love.graphics.draw(currentRoundText, self.roundNumberCanvas:getWidth()/2, self.roundNumberCanvas:getHeight()/2, 0, 1, 1, currentRoundText:getWidth()/2, currentRoundText:getHeight()/2)

    --HANDS
    love.graphics.setCanvas(self.handsCanvas)
    love.graphics.clear()
    love.graphics.draw(TurnsSprite, 0, 0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(currentHands, self.handsCanvas:getWidth()/2, self.handsCanvas:getHeight()/2+35, 0, 1, 1, currentHands:getWidth()/2, currentHands:getHeight()/2)
    love.graphics.setColor(1, 1, 1, 1)

    --REROLLS
    love.graphics.setCanvas(self.rerollsCanvas)
    love.graphics.clear()
    love.graphics.draw(RerollsSprite, 0, 0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(rerollText, self.rerollsCanvas:getWidth()/2, self.rerollsCanvas:getHeight()/2+35, 0, 1, 1, rerollText:getWidth()/2, rerollText:getHeight()/2)
    love.graphics.setColor(1, 1, 1, 1)

    --MONEY
    love.graphics.setCanvas(self.moneyCanvas)
    love.graphics.clear(1, 1, 0)
    love.graphics.draw(MoneySprite,0,0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(moneyText, self.moneyCanvas:getWidth()/2, self.moneyCanvas:getHeight()/2, 0, 1, 1, moneyText:getWidth()/2, moneyText:getHeight()/2)
    love.graphics.setColor(1, 1, 1, 1)


    --DRAW ALL THE CANVAS
    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.roundNumberCanvas, 30, 690)
    love.graphics.draw(self.handsCanvas, 30, 795)
    love.graphics.draw(self.rerollsCanvas, 295, 795)
    love.graphics.draw(self.moneyCanvas, 295, 690)
end

--Description
function DiceCustomization:drawDescriptionCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.descriptionCanvas)
    love.graphics.clear()
    --Draw Sprite
    love.graphics.draw(descriptionSprite, 0, 0)


    --[[ if(self.currentlyHoveredFace) then

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
        local descWidth, descWrappedtext = Fonts.nexaSmall:getWrap( faceDescription, self.descriptionCanvas:getWidth()-20 )
        local descText = love.graphics.newText(Fonts.nexaSmall, table.concat(descWrappedtext, "\n"))
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.draw(nameText, self.descriptionCanvas:getWidth()/2, 65, 0, 1, 1, nameText:getWidth()/2, 0)
        love.graphics.draw(tierText, self.descriptionCanvas:getWidth()/2, 105, 0, 1, 1, tierText:getWidth()/2, 0)
        love.graphics.draw(descText, self.descriptionCanvas:getWidth()/2, 140, 0, 1, 1, descText:getWidth()/2, 0)
        love.graphics.setColor(1, 1, 1, 1)

    end ]]

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.descriptionCanvas, self.descriptionX, self.descriptionY, 0, 1, 1, self.descriptionCanvas:getWidth(), self.descriptionCanvas:getHeight())
end

function DiceCustomization:drawNewFacesCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.newFacesCanvas)
    love.graphics.clear()

    love.graphics.draw(newFacesImage, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.newFacesCanvas, self.newFacesX, self.newFacesY, 0, 1, 1, self.newFacesCanvas:getWidth()/2, self.newFacesCanvas:getHeight())
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
    local xPositions = self:getCenteredPositions(table.getn(self.newFaceObjects), 120, 20, self.screenCanvas:getWidth()/2+60)

    for i,face in next,self.newFaceObjects do
        local diceFace = DiceFace:new(nil,
                                    face,
                                    xPositions[i],
                                    120,
                                    120,
                                    true,
                                    true,
                                    function()return Inputs.getMouseInCanvas(0, 0)end,
                                    nil)

        table.insert(self.newUIFaces, diceFace)
                                    
    end
end

function DiceCustomization:createDiceUI(diceObject, i)
    --This function creates every faces of a ui Dice and stores them in a table located in self.uiDices
    local diceUI = {}
    local xOffset = (20)+(i-1)*380 -- the base position of the dice
    local yOffset = 400
    
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
    return FaceHoverInfo:new(face, "both")
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