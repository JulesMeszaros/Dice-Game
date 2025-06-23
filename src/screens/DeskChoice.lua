local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local Fonts = require("src.utils.Fonts")
local AnimationUtils = require("src.utils.scripts.Animations")

local Animator = require("src.utils.Animator")

local Sprites = require("src.utils.Sprites")
local Ciggie = require("src.classes.ui.Ciggie")
local FaceObject = require("src.classes.FaceObject")
local DiceObject = require("src.classes.DiceObject")

local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")

local Badge = require("src.classes.ui.Badge")
local Button = require("src.classes.ui.Button")
local DiceFace = require("src.classes.ui.DiceFace")

local DeskChoice = {}

DeskChoice.__index = DeskChoice

local choiceNumber = 4

--Images

function DeskChoice:new(floor, run)
    local self = setmetatable({}, DeskChoice)
  
    self.uiElements = {
        buttons = {},
        DeskChoiceButtons = {},
        faceRewards = {},
        ciggiesUI = {}
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
    self.descriptionCanvas = love.graphics.newCanvas(420, 240)
    self.figureButtonsCanvas = love.graphics.newCanvas(450,670)
    self.rerollsCanvas = love.graphics.newCanvas(220, 120)
    self.handsCanvas = love.graphics.newCanvas(220, 120)
    self.roundNumberCanvas = love.graphics.newCanvas(290, 80)
    self.moneyCanvas = love.graphics.newCanvas(290, 100)
    self.deckCanvas = love.graphics.newCanvas(140, 860)
    self.diceDetailsCanvas = love.graphics.newCanvas(420, 600)
    self.ciggiesTray = love.graphics.newCanvas(420, 140)

    --Positions
    self.gridTX, self.gridTY, self.gridX, self.gridY = 30, 30, 30, -650
    self.diceDetailsTX, self.diceDetailsTY, self.diceDetailsX, self.diceDetailsY = self.canvas:getWidth()-30, 30, self.canvas:getWidth()+600, 30
    self.descriptionTX, self.descriptionTY, self.descriptionX, self.descriptionY = self.canvas:getWidth()-30, 650, self.canvas:getWidth()+600, 650

    self.rerollsTX, self.rerollsTY, self.rerollsX, self.rerollsY = 260, 721, -500, 721
    self.turnsTX, self.turnsTY, self.turnsX, self.turnsY = 30, 721, -730, 721
    self.floorTX, self.floorTY, self.floorX, self.floorY = 190, 970, 190, self.canvas:getHeight()+400
    self.moneyTX, self.moneyTY, self.moneyX, self.moneyY = 190, 860, 190, self.canvas:getHeight()+300
    self.ciggiesTrayTX, self.ciggiesTrayTY, self.ciggiesTrayX, self.ciggiesTrayY = self.canvas:getWidth()-30, self.canvas:getHeight()-30, self.canvas:getWidth()+450, self.canvas:getHeight()-30

    --Btns positions
    self.planBtnTX, self.planBtnTY, self.planBtnX, self.planBtnY = 100, 910, -150, 910
    self.menuBtnTX, self.menuBtnTY, self.menuBtnX, self.menuBtnY = 100, 1010, -150, 1010

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

    --Créer le deck
    self.deckTX, self.deckTY , self.deckX, self.deckY = 1300, 110, 1300, self.canvas:getHeight()+20
    self:createDeck()

    --Entry animation
    local entryDuration = 0.2
    self.animator:addGroup({
        {property = "gridY", from = self.gridY, targetValue = self.gridTY, duration = entryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.diceDetailsTX, duration = entryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.descriptionTX, duration = entryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "deckY", from = self.deckY, targetValue = self.deckTY, duration = entryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "moneyY", from = self.moneyY, targetValue = self.moneyTY, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = self.turnsTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = self.rerollsTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.ciggiesTrayTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.floorTY, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},    
    })

    --Buttons animation
    self.uiElements.buttons["menuButton"].animator:add('x', self.menuBtnX, self.menuBtnTX, entryDuration*2, AnimationUtils.Easing.outCubic)
    self.uiElements.buttons["planButton"].animator:add('x', self.planBtnX, self.planBtnTX, entryDuration*2, AnimationUtils.Easing.outCubic)


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

    --hovered face
    self:getCurrentlyHoveredFace()

    for key,button in next,self.uiElements.buttons do
        button:update(dt)
        button:draw()
    end

    --UI
    self:drawDeck(dt)
    self:drawDescriptionCanvas()
    self:drawFigureGrid()
    self:drawRoundDetails()
    self:drawDiceDetails(dt)
    self:updateChoiceCanvas(dt)
    self:drawCiggiesTray()

     --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
        ciggie:draw()
    end

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
                70+((i-1)*180),
                120,
                true,
                true,
                function()return Inputs.getMouseInCanvas(1300, 110)end,
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
    love.graphics.draw(Sprites.DECK, 0, 0)

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
    love.graphics.draw(Sprites.GRID, 0, 0)

    --Write the calculatedPoints
    love.graphics.setColor(0, 0, 0, 1)

    --Write the remaining possible hands
    for i=1, 13 do
        local handsRemaining = love.graphics.newText(Fonts.nexaSmall, self.run.availableFigures[i])
        love.graphics.draw(handsRemaining, 368, 50*(i-1)+38, 0, 1, 1, handsRemaining:getWidth()/2, handsRemaining:getHeight()/2)
        --if no hands remaining, grey out the line
        if(self.run.availableFigures[i]<=0) then
            love.graphics.setColor(0.4, 0.4, 0.4, 0.4)
            love.graphics.rectangle("fill", 10, (i-1)*50+10, self.figureButtonsCanvas:getWidth()-20, 50)
            love.graphics.setColor(0, 0, 0, 1)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

    local mv = Inputs.getMouseInCanvas(30, 30) --get the mouse position
    local i = math.floor((mv.y-10)/50)+1

    --If we are hovering a line
    if(i>0 and i<=13)then
        if(mv.x>0 and mv.x<self.figureButtonsCanvas:getWidth())then
            --Draw a shadow on the line
            if(self.run.availableFigures[i]>=1)then
                love.graphics.setColor(1, 0, 0, 0.3)
                love.graphics.rectangle("fill", 10, (i-1)*50+10, self.figureButtonsCanvas:getWidth()-20, 50)
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
    local moneyText = love.graphics.newText(Fonts.nexaBig, tostring(self.run.money).."€")

    --ROUND
    love.graphics.setCanvas(self.roundNumberCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.FLOOR_INFOS, 0, 0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(currentRoundText, self.roundNumberCanvas:getWidth()/2, self.roundNumberCanvas:getHeight()/2, 0, 1, 1, currentRoundText:getWidth()/2, currentRoundText:getHeight()/2)
    love.graphics.setColor(1, 1, 1, 1)
    --HANDS
    love.graphics.setCanvas(self.handsCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.TURNS, 0, 0)
    love.graphics.setColor(245/255, 247/255, 228/255, 1)
    love.graphics.draw(currentHands, self.handsCanvas:getWidth()/2, self.handsCanvas:getHeight()/2+35, 0, 1, 1, currentHands:getWidth()/2, currentHands:getHeight()/2+3)
    love.graphics.setColor(1, 1, 1, 1)

    --REROLLS
    love.graphics.setCanvas(self.rerollsCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.REROLLS, 0, 0)
    love.graphics.setColor(245/255, 247/255, 228/255, 1)
    love.graphics.draw(rerollText, self.rerollsCanvas:getWidth()/2, self.rerollsCanvas:getHeight()/2+35, 0, 1, 1, rerollText:getWidth()/2, rerollText:getHeight()/2+3)
    love.graphics.setColor(1, 1, 1, 1)

    --MONEY
    love.graphics.setCanvas(self.moneyCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.MONEY,0,0)
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

function DeskChoice:drawCiggiesTray()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.ciggiesTray)

    love.graphics.draw(Sprites.CIGGIES_TRAY, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.ciggiesTray, self.ciggiesTrayX, self.ciggiesTrayY, 0, 1, 1, self.ciggiesTray:getWidth(), self.ciggiesTray:getHeight())
end


--Description
function DeskChoice:drawDescriptionCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.descriptionCanvas)
    love.graphics.clear()
    --Draw Sprite
    love.graphics.draw(Sprites.DESCRIPTION, 0, 0)


    if(self.currentlyHoveredFace) then

        --Face Name
        local faceName = self.currentlyHoveredFace.representedFace.name
        local nameText = love.graphics.newText(Fonts.nexa30, faceName)

        --Face tier
        local tierText = love.graphics.newText(
            Fonts.nexaSmall,
            self.currentlyHoveredFace.representedFace.tier
        )

        --Description
        local faceDescription = self.currentlyHoveredFace.representedFace.description
        local descWidth, descWrappedtext = Fonts.nexaSmall:getWrap( faceDescription, self.descriptionCanvas:getWidth()-20 )
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
--DiceNet

function DeskChoice:createDiceNet()
    --Create a temp dice with a temp face repeated 6 times
    local tempFace = FaceObject:new(6)
    self.tempDice = DiceObject:new({tempFace, tempFace, tempFace, tempFace, tempFace, tempFace})

    --Create the coordinates of each dice face
    local diceFacesCoords = {
        {self.diceDetailsCanvas:getWidth()/2-120, self.diceDetailsCanvas:getHeight()/2-30}, --1
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2-120-30}, --2
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2-30}, --3
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2+240-30}, --4
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2+120-30}, --5
        {self.diceDetailsCanvas:getWidth()/2+120, self.diceDetailsCanvas:getHeight()/2-30}, --6
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
    love.graphics.draw(Sprites.DICE_INFOS, 0, 0)
    
    --Draw the dice net
    if(self.currentlySelectedDice)then
        self:updateDiceNet(dt)
    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.diceDetailsCanvas, self.diceDetailsX, self.diceDetailsY, 0, 1, 1, self.diceDetailsCanvas:getWidth(), 0)
end

function DeskChoice:generateCiggiesUI()
    for i,ciggie in next,self.run.ciggiesObjects do
        self.uiElements.ciggiesUI[ciggie] = Ciggie:new(ciggie, 1680, 949+((i-1)*60), true, true, function()return Inputs.getMouseInCanvas(0, 0)end, self.round)
    end
end

--==CHOICES==--
function DeskChoice:generateChoiceCanvas()
    self.badges = {}
    self.choiceCanvas = {}

    local coords = {
        {510, 30},
        {905, 30},
        {510, 550},
        {905, 550},
    }

    local originalY = {
        -1000, -1000, 3000, 3000
    }

    for i=1, table.getn(self.possibleRounds) do
        local c = love.graphics.newCanvas(220*1.5, 330*1.5)
        local b = Badge:new(self.possibleRounds[i], coords[i][1], coords[i][2], originalY[i], 370, 500, function()return Inputs.getMouseInCanvas(0, 0)end)
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

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:clickEvent()
    end

end

function DeskChoice:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,badge in next,self.badges do
        local wasReleased = badge:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            self:outAnimation(badge)
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

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:releaseEvent()
        ciggie:detectBelowCanvas(self)
        ciggie.isBeingDragged = false
    end
end

function DeskChoice:mousemoved(x, y, dx, dy, isDragging)
    --Drag and drop Ciggies
    if(isDragging == true)then 
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

--==Utils==--

function DeskChoice:outAnimation(badge)
    local outDuration = 0.2
    local newBadgeY = {
        -1000, -1000, 3000, 3000
    }

    self.animator:addGroup({
        {property = "gridY", from = self.gridY, targetValue = -820, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "deckY", from = self.deckY, targetValue = self.canvas:getHeight()+20, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.canvas:getWidth()+450, duration = outDuration, easing = AnimationUtils.Easing.inCubic},

        {property = "moneyY", from = self.moneyY, targetValue = self.canvas:getHeight()+300, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = -730, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = -500, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.canvas:getHeight()+400, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
    })


    for i=1, table.getn(self.badges) do
        self.badges[i].animator:add("y", self.badges[i].y, newBadgeY[i], 0.4, AnimationUtils.Easing.inCubic)
    end

    --Buttons animation
    self.uiElements.buttons["menuButton"].animator:add('x', self.menuBtnX, -150, outDuration)
    self.uiElements.buttons["planButton"].animator:add('x', self.planBtnX, -150, outDuration)

    
    self.animator:addDelay(0.5, function()self.run:startNewRound(badge.round, badge.round.roundtype)end)
end

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
    end

    for i,badge in next,self.badges do
        if(badge.currentlyHoveredFace) then self.currentlyHoveredFace = badge.currentlyHoveredFace ; break end
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