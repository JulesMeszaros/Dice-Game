local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")
local Fonts = require("src.utils.fonts")
local AnimationUtils = require("src.utils.scripts.AnimationUtils")

local Animator = require("src.utils.Animator")

local FaceObject = require("src.classes.FaceTypes.FaceObject")
local DiceObject = require("src.classes.DiceObject")

local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")

local Badge = require("src.classes.ui.Badge")
local Button = require("src.classes.ui.Button")
local DiceFace = require("src.classes.ui.DiceFace")

local DeskChoice = {}

DeskChoice.__index = DeskChoice

local choiceNumber = 4

--Images
local descriptionSprite = love.graphics.newImage("src/assets/sprites/ui/terrain/Description-proto.png")
local DiceInfosSprite = love.graphics.newImage("src/assets/sprites/ui/terrain/Dice Info-proto.png")
local FloorInfosSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Floor-proto.png")
local MoneySprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Money-proto.png")
local RerollsSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Rerolls-proto.png")
local TableauFiguresSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Tableau-proto.png")
local TurnsSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Turns-proto.png")
local deckBackGroundImage = love.graphics.newImage("src/assets/sprites/ui/terrain/deck_deskchoice_proto.png")

function DeskChoice:new(floor, run)
    local self = setmetatable({}, DeskChoice)
  
    self.uiElements = {
        buttons = {},
        DeskChoiceButtons = {},
        faceRewards = {}
    }


    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    self.floor = floor
    self.run = run

    --animator
    self.animator = Animator:new(self)
    self.animator:addDelay(0.1)
    --Run dices
    self.diceObjects = run.diceObjects
   
    --UI
    self.descriptionCanvas = love.graphics.newCanvas(420, 390)
    self.figureButtonsCanvas = love.graphics.newCanvas(495,630)
    self.rerollsCanvas = love.graphics.newCanvas(240, 150)
    self.handsCanvas = love.graphics.newCanvas(240, 150)
    self.roundNumberCanvas = love.graphics.newCanvas(240, 90)
    self.moneyCanvas = love.graphics.newCanvas(240, 90)
    self.deckCanvas = love.graphics.newCanvas(195, 1020)
    self.diceDetailsCanvas = love.graphics.newCanvas(420, 600)

    --Positions
    self.gridTX, self.gridTY, self.gridX, self.gridY = 30, 30, 30, -650
    self.diceDetailsTX, self.diceDetailsTY, self.diceDetailsX, self.diceDetailsY = self.canvas:getWidth()-30, 30, self.canvas:getWidth()+600, 30
    self.descriptionTX, self.descriptionTY, self.descriptionX, self.descriptionY = self.canvas:getWidth()-30, self.canvas:getHeight()-30, self.canvas:getWidth()+600, self.canvas:getHeight()-30



    --Créer le deck
    self.deckTX, self.deckTY , self.deckX, self.deckY = 1260, 30, 1260, self.canvas:getHeight()+20
    self:createDeck()

    --Entry animation
    local entryDuration = 0.2
    self.animator:addGroup({
        {property = "gridY", from = self.gridY, targetValue = self.gridTY, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.diceDetailsTX, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.descriptionTX, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
        {property = "deckY", from = self.deckY, targetValue = self.deckTY, duration = entryDuration, eading = AnimationUtils.Easing.outCubic},
    })

    --Créer le dice net
    self:createDiceNet()

    self.currentlyHoveredFace = nil
    self.previouslyHoveredFace = nil
    self.currentlySelectedDice = nil


    if(self.run.floorDeskNumber < 4) then
        self.possibleRounds = self.floor.desks[self.run.floorDeskNumber]
    else
        self.possibleRounds = {self.floor.boss}
    end

    --Création des différents canvas de choix de round
    self:generateChoiceCanvas()

    return self
end

function DeskChoice:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    self.animator:update(dt)

    --UI
    self:drawDeck(dt)
    self:drawDescriptionCanvas()
    self:drawFigureGrid()
    self:drawRoundDetails()
    self:drawDiceDetails(dt)
    self:updateChoiceCanvas(dt)

    --hovered face
    self:getCurrentlyHoveredFace()

    love.graphics.setCanvas(currentCanvas)
end

function DeskChoice:draw()
    love.graphics.draw(self.canvas, 0, 0)
end

--==UI==--

--Deck
function DeskChoice:createDeck()
    local deckFaces = {}
    for i,dice in next,self.diceObjects do
        --Create the UIFaces
        local faceUI = DiceFace:new(
                dice,
                dice:getFace(1),
                self.deckCanvas:getWidth()/2+1,
                160+((i-1)*192)-1,
                120,
                true,
                true,
                function()return Inputs.getMouseInCanvas(1260, 30)end,
                nil
            )
        deckFaces[dice] = faceUI
    end
    self.deckFaces = deckFaces
end 

function DeskChoice:drawDeck(dt)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.deckCanvas)
    love.graphics.clear()
    
    --Draw the background
    love.graphics.draw(deckBackGroundImage, 0, 0)

    --draw the deck faces
    for dice,face in next,self.deckFaces do
        if(face:getIsSelected())then
            face.selectionScale = 0.1
        else
            face.selectionScale = 0
        end
        face:update(dt)
        face:draw()
    end

    love.graphics.setCanvas(targetCanvas)
    love.graphics.draw(self.deckCanvas, self.deckX, self.deckY)
end

--Grid
function DeskChoice:drawFigureGrid()
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.figureButtonsCanvas)
    love.graphics.clear()
    --Draw the table
    love.graphics.draw(TableauFiguresSprite, 0, 0)

    --Write the calculatedPoints
    love.graphics.setColor(0, 0, 0, 1)

    --Write the remaining possible hands
    for i=1, 13 do
        local handsRemaining = love.graphics.newText(Fonts.nexaSmall, self.run.availableFigures[i])
        love.graphics.draw(handsRemaining, 320+85, 45*i+25, 0, 1, 1, handsRemaining:getWidth()/2, handsRemaining:getHeight()/2)
        --if no hands remaining, grey out the line
        if(self.run.availableFigures[i]<=0) then
            love.graphics.setColor(0.4, 0.4, 0.4, 0.4)
            love.graphics.rectangle("fill", 0, i*45, self.figureButtonsCanvas:getWidth(), 45)
            love.graphics.setColor(0, 0, 0, 1)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

    local mv = Inputs.getMouseInCanvas(30, 30) --get the mouse position
    local i = math.floor(mv.y/45)

    --If we are hovering a line
    if(i>0 and i<=13)then
        if(mv.x>0 and mv.x<self.figureButtonsCanvas:getWidth())then
            --Draw a shadow on the line
            if(self.run.availableFigures[i]>=1)then
                love.graphics.setColor(1, 0, 0, 0.3)
                love.graphics.rectangle("fill", 0, i*45, self.figureButtonsCanvas:getWidth(), 45)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    love.graphics.setCanvas(targetCanvas)
    
    love.graphics.draw(self.figureButtonsCanvas, self.gridX, self.gridY)
    
end

--Bottom buttons
function DeskChoice:drawRoundDetails()
    local currentCanvas = love.graphics.getCanvas()
    --Create the texts
    local rerollText = love.graphics.newText(Fonts.nexaBig, tostring("-"))
    local currentHands = love.graphics.newText(Fonts.nexaBig, tostring("-"))
    local currentRoundText = love.graphics.newText(Fonts.nexaSmall, 'Floor '..tostring(self.run.floorNumber)..'\nDesk : '..tostring(0))
    local moneyText = love.graphics.newText(Fonts.nexaSmall, tostring(self.run.money).."€")

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
function DeskChoice:drawDescriptionCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.descriptionCanvas)
    love.graphics.clear(60/255, 99/255, 60/255)
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
        local descWidth, descWrappedtext = Fonts.nexaSmall:getWrap( faceDescription, self.descriptionCanvas:getWidth()-20 )
        local descText = love.graphics.newText(Fonts.nexaSmall, table.concat(descWrappedtext, "\n"))
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.draw(nameText, self.descriptionCanvas:getWidth()/2, 65, 0, 1, 1, nameText:getWidth()/2, 0)
        love.graphics.draw(tierText, self.descriptionCanvas:getWidth()/2, 105, 0, 1, 1, tierText:getWidth()/2, 0)
        love.graphics.draw(descText, self.descriptionCanvas:getWidth()/2, 140, 0, 1, 1, descText:getWidth()/2, 0)
        love.graphics.setColor(1, 1, 1, 1)

    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.descriptionCanvas, self.descriptionX, self.descriptionY, 0, 1, 1, self.descriptionCanvas:getWidth(), self.descriptionCanvas:getHeight())
end
--DiceNet

function DeskChoice:createDiceNet()
    --Create a temp dice with a temp face repeated 6 times
    local tempFace = FaceObject:new(6)
    self.tempDice = DiceObject:new({tempFace, tempFace, tempFace, tempFace, tempFace, tempFace})

    --Create the coordinates of each dice face
    local diceFacesCoords = {
        {self.diceDetailsCanvas:getWidth()/2-120, self.diceDetailsCanvas:getHeight()/2-10}, --1
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2-120-10}, --2
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2-10}, --3
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2+240-10}, --4
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2+120-10}, --5
        {self.diceDetailsCanvas:getWidth()/2+120, self.diceDetailsCanvas:getHeight()/2-10}, --6
    }
    
    -- Create the uiFaces objects
    local infoFaces = {}

    for k,d in next,self.tempDice:getAllFaces() do
        local diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            self.tempDice, --Dice Object 
            d, --La face représentée
            diceFacesCoords[k][1], --X Position (centerd)
            diceFacesCoords[k][2], --Yposition (centerd)
            120, --Width/Height
            false, --is Selectable
            true, --isHoverable,
            function()return Inputs.getMouseInCanvas(self.canvas:getWidth()-30-self.diceDetailsCanvas:getWidth(),30)end,
            self.round
        )

        table.insert(infoFaces, diceFaceUI)
    end

    self.infoFaces = infoFaces
end

function DeskChoice:updateDiceNet(dt)
   local i = 1
    for k,df in next,self.infoFaces do
        df:setRepresentedFace(self.currentlySelectedDice.diceObject:getFace(i))
        df:updateSprite()
        df:update(dt)
        df:draw()
        i =i+1
    end
end

function DeskChoice:drawDiceDetails(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceDetailsCanvas)
    love.graphics.clear(60/255, 99/255, 60/255)

    --Draw sprite
    love.graphics.draw(DiceInfosSprite, 0, 0)
    
    --Draw the dice net
    if(self.currentlySelectedDice)then
        self:updateDiceNet(dt)
    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.diceDetailsCanvas, self.diceDetailsX, self.diceDetailsY, 0, 1, 1, self.diceDetailsCanvas:getWidth(), 0)
end

--==CHOICES==--
function DeskChoice:generateChoiceCanvas()
    self.badges = {}
    self.choiceCanvas = {}

    local coords = {
        {550, 30},
        {908, 30},
        {550, 555},
        {908, 555},
    }

    local originalY = {
        -1000, -1000, 3000, 3000
    }

    for i=1, choiceNumber do
        local c = love.graphics.newCanvas(220*1.5, 330*1.5)
        local b = Badge:new(self.possibleRounds[i], coords[i][1], coords[i][2], originalY[i], 220*1.5, 330*1.5, function()return Inputs.getMouseInCanvas(0, 0)end)
        table.insert(self.choiceCanvas, c)
        table.insert(self.badges, b)
    end

end

function DeskChoice:updateChoiceCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()

    local coords = {
        {550, 30},
        {908, 30},
        {550, 555},
        {908, 555},
    }

    for i,badge in next,self.badges do
        badge:update(dt)
        badge:draw()
    end
    
end

--==INPUT FUNCTIONS==--

function DeskChoice:keypressed(key)
    print("keypressed")
end

function DeskChoice:mousepressed(x, y, button, istouch, presses)
   --Buttons
   for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end

    --Badges
   for key,badge in next,self.badges do
        badge:clickEvent()
    end

    --Deck faces
    for key,uiFace in next,self.deckFaces do
        uiFace:clickEvent()
    end
end

function DeskChoice:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,badge in next,self.badges do
        local wasReleased = badge:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            self.run:startNewRound(badge.round, badge.round.roundtype)
        end
    end

    for key,face in next,self.deckFaces do
        local wasReleased = face:releaseEvent()
        if(wasReleased)then --On sélectionne la face a switcher
            self:resetSelectedDices()
            face:setSelected(true)
            self.currentlySelectedDice = face
        end
    end
end

function DeskChoice:mousemoved(x, y, dx, dy, isDragging)

end

--==Utils==--

function DeskChoice:resetSelectedDices()
    --Dice faces
    for key,face in next,self.deckFaces do
        face:setSelected(false)
    end
end

function DeskChoice:createFaceInfosCanvas(face)
    return FaceHoverInfo:new(face, "both")
end

function DeskChoice:getCurrentlyHoveredFace()
    self.previouslyHoveredFace = self.currentlyHoveredFace --We save the state of the frame before
    self.currentlyHoveredFace = nil

    for i,face in next,self.infoFaces do
        if face:isHovered() then self.currentlyHoveredFace = face ; break end
        --TODO: add the reward faces
    end

    --Si un dé est survolé et qu'il est différent du dé précédent alors on créé un nouveau canvas d'infos
    --[[ if(self.currentlyHoveredFace ~= self.previouslyHoveredFace) then
        if (self.currentlyHoveredFace) then
            self.hoverInfosCanvas = self:createFaceInfosCanvas(self.currentlyHoveredFace)
        end
    end ]]

end

function DeskChoice:getCenteredPositions(count, objectWidth, spacing, centerX)
    local totalWidth = count * objectWidth + (count - 1) * spacing
    local startX = centerX - totalWidth / 2

    local positions = {}
    for i = 0, count - 1 do
        local x = startX + i * (objectWidth + spacing)
        table.insert(positions, x)
    end

    return positions
end

return DeskChoice