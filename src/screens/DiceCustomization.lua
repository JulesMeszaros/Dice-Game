local DiceFace = require("src.classes.ui.DiceFace")
local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")
local Button = require("src.classes.ui.Button")
local DeskChoice = require("src.screens.DeskChoice")

local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")

local DiceCustomization = {}
DiceCustomization.__index = DiceCustomization

function DiceCustomization:new(previousRound, newFaceObjects)
    local self = setmetatable({}, DiceCustomization)

    self.uiElements = {
        buttons = {}
    }

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
    self.screenCanvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)

    --Create the switch button
    self.uiElements.buttons.switchButton = Button:new(
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
    )

    self:createNewFacesUI()


    return self
end

function DiceCustomization:update(dt)
    --Get hovered face
    self:getCurrentlyHoveredFace()
   
    --update the canvas
    self:updateCanvas(dt)

    --Update the dice faces
    --Draw the uiFaces on the canvas
    for i,uiDice in next,self.uiDices do
        for j,uiFace in next,uiDice do
            uiFace:update(dt)
            if(uiFace:getIsSelected())then
                uiFace.selectionScale = -0.2
            else
                uiFace.selectionScale = 0
            end
        end
    end

    --New faces
    for i,uiFace in next,self.newUIFaces do
        uiFace:update(dt)
        if(uiFace:getIsSelected())then
            uiFace.selectionScale = -0.2
        else
            uiFace.selectionScale = 0
        end
    end

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end
    --Disable switch button
    self.uiElements.buttons.switchButton:setActivated(self.selectedDiceFace ~= nil and self.selectedNewDiceFace ~= nil)
    
end

function DiceCustomization:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.screenCanvas)
    love.graphics.clear(89/255, 153/255, 255/255)

    --Draw the uiFaces on the canvas
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
    end

     --Update the hover info
    if(self.currentlyHoveredFace)then
        self.hoverInfosCanvas:update(dt)
        self.hoverInfosCanvas:draw()
    end

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
   --Buttons
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
    end

end

function DiceCustomization:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
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
    end
end

function DiceCustomization:mousemoved(x, y, dx, dy, isDragging)
    
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
    return FaceHoverInfo:new(face)
end

function DiceCustomization:getCurrentlyHoveredFace()
    self.previouslyHoveredFace = self.currentlyHoveredFace --We save the state of the frame before
    self.currentlyHoveredFace = nil

    for i,dice in next,self.uiDices do
        for j,face in next,dice do
            if face:isHovered() then self.currentlyHoveredFace = face ; break end
        end
    end

    --Si un dé est survolé et qu'il est différent du dé précédent alors on créé un nouveau canvas d'infos
    if(self.currentlyHoveredFace ~= self.previouslyHoveredFace) then
        if (self.currentlyHoveredFace) then
            self.hoverInfosCanvas = self:createFaceInfosCanvas(self.currentlyHoveredFace)
        end
    end

end

return DiceCustomization