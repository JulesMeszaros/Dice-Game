--Utils
local Inputs = require("src.utils.scripts.inputs")
local CalculatePoints = require("src.utils.scripts.calculatePoints")
local Fonts = require("src.utils.fonts")
--UI
local Button = require("src.classes.ui.Button")
--Dices
local DiceObject = require("src.classes.DiceObject")
local FaceObject = require("src.classes.FaceTypes.WhiteDice")
local DiceFace = require("src.classes.ui.DiceFace")
--Sprites
local descriptionSprite = love.graphics.newImage("src/assets/sprites/ui/terrain/Description-proto.png")
local DiceInfosSprite = love.graphics.newImage("src/assets/sprites/ui/terrain/Dice Info-proto.png")
local EnemyInfosSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Enemy-proto.png")
local FloorInfosSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Floor-proto.png")
local PlayerInfosSprite = love.graphics.newImage("src/assets/sprites/ui/terrain/Joueur infos-proto.png")
local MoneySprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Money-proto.png")
local RerollsSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Rerolls-proto.png")
local TableauFiguresSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Tableau-proto.png")
local DiceMatSprite = love.graphics.newImage("src/assets/sprites/ui/terrain/Tapis-png.png")
local TurnsSprite= love.graphics.newImage("src/assets/sprites/ui/terrain/Turns-proto.png")

local RoundScreen = {}

RoundScreen.__index = RoundScreen

local font = Fonts.nexaSmall
local font30 = Fonts.nexaMedium

function RoundScreen:new(round)
    local self = setmetatable({}, RoundScreen)
    self.gameCanvas = round.gameCanvas
    self.round = round

    self.uiElements = {
        roundButtons = {},
    }

    --Create the terrain canvas
    self.terrainCanvas = love.graphics.newCanvas(round.gameCanvas:getWidth(),round.gameCanvas:getHeight() )

    --DICE TRAY
    self.dice_tray = love.graphics.newCanvas(885, 750)
    self.dice_tray:setFilter("linear", "linear")

    --Hovered infos
    self.currentlyHoveredFigure = nil 
    self.currentlyHoveredDice = nil

    --FIGURE BUTTONS
    self.figureButtonsCanvas = love.graphics.newCanvas(495,630)
    self.figureButtonsCanvas:setFilter("linear", "linear")
    self.clickedFigure = nil
    --Calculate points functions
    self.calcBasePoints = {
        function()return CalculatePoints.numberBasePoints(1, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(2, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(3, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(4, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(5, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(6, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.chanceBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.brelanBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.fullBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.pttSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.gdSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.carreBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.yatzeeBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end
    }

    self.calculatePointsFunctions = {
        function()self:playFigure(CalculatePoints.numberBasePoints(1, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(2, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(3, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(4, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(5, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(6, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.chanceBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.brelanBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.fullBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.pttSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.gdSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.carreBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
        function()self:playFigure(CalculatePoints.yatzeeBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects))end,
    }
    
    --FACE DETAILS
    self.faceDetailsCanvas = love.graphics.newCanvas(420, 390)

    --DICE DETAILS
    self.diceDetailsCanvas = love.graphics.newCanvas(420, 600)
    self.diceDetailsTimer = 0
    self.diceDetailsTime = 0.5
    --Creating the different ui faces that will be shown
    self:createDiceNet()

    --ROUND DETAILS
    self:createRoundInfos()

    --LEFT PANNEL BUTTONS
    self.uiElements.roundButtons["reorganiserButton"] = Button:new(
        function()self:reorganiseDiceFaces(self.round.diceFaces2)end, 
        "src/assets/sprites/ui/terrain/Order_btn-proto.png", 
        self.terrainCanvas:getWidth()-self.faceDetailsCanvas:getWidth()-60-self.dice_tray:getWidth()/2-215, 
        self.terrainCanvas:getHeight()-75, 
        420, 
        60,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.roundButtons["rerollButton"] = Button:new(
        function()self.round:rerollDices()end, 
        "src/assets/sprites/ui/terrain/Reroll-proto.png", 
        self.terrainCanvas:getWidth()-self.faceDetailsCanvas:getWidth()-60-self.dice_tray:getWidth()/2+215, 
        self.terrainCanvas:getHeight()-75, 
        420, 
        60,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.roundButtons["menuButton"] = Button:new(
        function()print("menu")end,
        "src/assets/sprites/ui/terrain/Menu_btn-proto.png",
        150,
        1005,
        240,
        90,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.roundButtons["planButton"] = Button:new(
        function()print("plan")end,
        "src/assets/sprites/ui/terrain/Plan_btn-proto.png",
        415,
        1005,
        240,
        90,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    --PLAYERS INFOS
    self.playerInfos = love.graphics.newCanvas(612,255)
    self.enemyInfos = love.graphics.newCanvas(612,255)

    return self
end

function RoundScreen:update(dt)
    --Reset Bouton de figure et Dé survolé
    self.currentlyHoveredFigure = nil

    --Hover infos
    self:getCurrentlyHoveredDice() --Le dé survolé

    --Utilities buttons
    for key,button in next,self.uiElements.roundButtons do
        self.uiElements.roundButtons["rerollButton"]:setActivated(self.round.availableRerolls>0 and table.getn(self.round.selectedDices)>0)

        button:update(dt)
    end

    self:updateCanvas(dt)

end

function RoundScreen:updateCanvas(dt)
    love.graphics.setCanvas(self.terrainCanvas)
    love.graphics.clear()

    --PlayersInfos
    self:drawPlayersInfos()

    --Dice Tray
    self:drawDiceTray(self.terrainCanvas:getWidth()-60-self.faceDetailsCanvas:getWidth(), self.terrainCanvas:getHeight()-30, self.round.diceFaces2)

    --Figure Buttons

    self:drawFigureButtons(30, 30)
    self:getCurrentlyHoveredLine() --La figure survolée


    --Bouttouns de round
    for k,b in next,self.uiElements.roundButtons do
        b:draw()
    end

    --Face Details
    self:drawFaceDetails(self.terrainCanvas:getWidth()-30, self.terrainCanvas:getHeight()-30)

    --Dice Details
    self:updateDiceNet(dt)
    for k,df in next,self.infoFaces do --éventuellement à bouger dans la fonction drawFaceDetails
        df.targetedScale = self.diceDetailsTimer/self.diceDetailsTime
        df:updateCanvas(dt) 
        df:update(dt)
    end
    self:drawDiceDetails(self.terrainCanvas:getWidth()-30, 30)
    
    --ROUND DETAILS
    self:drawRoundDetails()

    love.graphics.setCanvas(self.gameCanvas)
end

--==DRAW FUNCTIONS==--

function RoundScreen:drawDiceTray(x, y, dices2)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.dice_tray)
    love.graphics.clear(60/255, 99/255, 60/255)

    love.graphics.draw(DiceMatSprite, 0, 0, 0, 1, 1)

    --On déssine les autres dés
    for key,uiFace in next,dices2 do
        uiFace:draw()
    end

    --On retourne au canvas précédent
    love.graphics.setCanvas(targetCanvas)
    --On déssine le terrain à dés sur le canvas
    love.graphics.draw(self.dice_tray, x, y, 0, 1, 1, self.dice_tray:getWidth(), self.dice_tray:getHeight()) --On fixe son offset sur son angle superieur droit

end

function RoundScreen:drawFigureButtons(x, y)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.figureButtonsCanvas)
    love.graphics.clear()
    --Draw the table
    love.graphics.draw(TableauFiguresSprite, 0, 0)

    --Write the calculatedPoints
    love.graphics.setColor(0, 0, 0, 1)
    for i=1, 13 do
        local calcScore = love.graphics.newText(Fonts.nexaSmall, self.calcBasePoints[i]()[1])
        love.graphics.draw(calcScore, 150+85, 45*i+25, 0, 1, 1, calcScore:getWidth()/2, calcScore:getHeight()/2)
    end
    love.graphics.setColor(1, 1, 1, 1)

    local mv = Inputs.getMouseInCanvas(30, 30) --get the mouse position
    local i = math.floor(mv.y/45)
    if(i>0 and i<=13)then
        if(mv.x>0 and mv.x<self.figureButtonsCanvas:getWidth())then
            self:highlightDices(self.calcBasePoints[i]()[2])
            --Draw a shadow on the line
            if(love.mouse.isDown(1)) then
                love.graphics.setColor(0.7, 0, 0, 0.3)
            else
                love.graphics.setColor(1, 0, 0, 0.3)
            end
            love.graphics.rectangle("fill", 0, i*45, self.figureButtonsCanvas:getWidth(), 45)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    love.graphics.setCanvas(targetCanvas)
    
    love.graphics.draw(self.figureButtonsCanvas, x, y)
    
end

function RoundScreen:drawFaceDetails(x, y)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.faceDetailsCanvas)
    love.graphics.clear(60/255, 99/255, 60/255)
    --Draw Sprite
    love.graphics.draw(descriptionSprite, 0, 0)

    if(self.currentlyHoveredDice) then
        --Face Name
        local faceName = self.currentlyHoveredDice:getCurrentFaceObject().name
        local nameText = love.graphics.newText(font30, faceName)

        --Face tier
        local tierText = love.graphics.newText(
            font,
            self.currentlyHoveredDice:getCurrentFaceObject().tier
        )

        --Description
        local faceDescription = self.currentlyHoveredDice:getCurrentFaceObject().description
        local descWidth, descWrappedtext = font:getWrap( faceDescription, self.faceDetailsCanvas:getWidth()-20 )
        local descText = love.graphics.newText(font, table.concat(descWrappedtext, "\n"))
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.draw(nameText, self.faceDetailsCanvas:getWidth()/2, 65, 0, 1, 1, nameText:getWidth()/2, 0)
        love.graphics.draw(tierText, self.faceDetailsCanvas:getWidth()/2, 105, 0, 1, 1, tierText:getWidth()/2, 0)
        love.graphics.draw(descText, self.faceDetailsCanvas:getWidth()/2, 140, 0, 1, 1, descText:getWidth()/2, 0)
        love.graphics.setColor(1, 1, 1, 1)

    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.faceDetailsCanvas, x, y, 0, 1, 1, self.faceDetailsCanvas:getWidth(), self.faceDetailsCanvas:getHeight())
end

function RoundScreen:drawDiceDetails(x, y)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceDetailsCanvas)
    love.graphics.clear(60/255, 99/255, 60/255)

    --Draw sprite
    love.graphics.draw(DiceInfosSprite, 0, 0)
    
    --Draw the dice net
    if self.currentlyHoveredDice then
        for k,df in next,self.infoFaces do
            if(df.representedFace == self.currentlyHoveredDice:getCurrentFaceObject())then
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.rectangle("fill", df.x-5-df.size/2, df.y-5-df.size/2, 125, 125)
                love.graphics.setColor(1, 1, 1, 1)
            end
            df:draw()
        end
    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.diceDetailsCanvas, x, y, 0, 1, 1, self.diceDetailsCanvas:getWidth(), 0)
end

function RoundScreen:drawRoundDetails()
    local currentCanvas = love.graphics.getCanvas()
    --Create the texts
    local rerollText = love.graphics.newText(Fonts.nexaBig, tostring(self.round.availableRerolls))
    local currentHands = love.graphics.newText(Fonts.nexaBig, tostring(self.round.remainingHands))
    local currentRoundText = love.graphics.newText(font, 'Round : '..tostring(self.round.nround))
    local moneyText = love.graphics.newText(font, tostring(self.round.run.money).."€")

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

function RoundScreen:drawPlayersInfos()
    local currentCanvas = love.graphics.getCanvas()
    --Player
    love.graphics.setCanvas(self.playerInfos)
    love.graphics.clear()
    love.graphics.draw(PlayerInfosSprite, 0, 0)
    local scoreText = love.graphics.newText(font, 'Score : ' ..tostring(self.round.roundScore))
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(scoreText, self.playerInfos:getWidth()-10, 72, 0, 1, 1, scoreText:getWidth(), 0)
    love.graphics.setColor(1, 1, 1, 1)

    --Ennemy
    love.graphics.setCanvas(self.enemyInfos)
    love.graphics.clear()
    love.graphics.draw(EnemyInfosSprite, 0, 0)
    local targetScoreText = love.graphics.newText(font, 'Target : '..tostring(self.round.targetScore))
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(targetScoreText, 10, 207)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.playerInfos, 552, 12)
    love.graphics.draw(self.enemyInfos, 828, 30)
end

--==CREATE CANVAS FUNCTIONS==--
function RoundScreen:createDiceNet()
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
            false, --isHoverable,
            function()return Inputs.getMouseInCanvas(0,0)end,
            self.round
        )

        table.insert(infoFaces, diceFaceUI)
    end

    self.infoFaces = infoFaces
end

function RoundScreen:createRoundInfos()
    --Create the canvas
    self.rerollsCanvas = love.graphics.newCanvas(240, 150)
    self.handsCanvas = love.graphics.newCanvas(240, 150)
    self.roundNumberCanvas = love.graphics.newCanvas(240, 90)
    self.moneyCanvas = love.graphics.newCanvas(240, 90)
end

--[[ function RoundScreen:createPlayersInfos()
    local currentCanvas = love.graphics.getCanvas()
    --Player
    love.graphics.setCanvas(self.playerInfo)

    --Ennemy
    love.graphics.setCanvas(self.enemyInfos)

    
end ]]

--==FIGURES TABLE==--
function RoundScreen:getCurrentlyHoveredLine()
    local mv = Inputs.getMouseInCanvas(30, 30) --get the mouse position
    local i = math.floor(mv.y/45)
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



--==UTILS FUNCTIONS==--
function RoundScreen:getCurrentlyHoveredDice()
    self.currentlyHoveredDice = nil

    for key,diceface in next,self.round.diceFaces2 do
        if diceface:isHovered() then
            self.currentlyHoveredDice = diceface.diceObject
            break
        end
    end
end

function RoundScreen:updateDiceNet(dt)
    if(self.currentlyHoveredDice) then
        for i = 1, 6 do
            self.infoFaces[i]:setRepresentedFace(self.currentlyHoveredDice:getFace(i))
            self.infoFaces[i]:updateSprite()
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

function RoundScreen:playFigure(params)
    local points, usedDices = params[1], params[2]
    
    self.round:playFigure(points, usedDices)
end

function RoundScreen:reorganiseDiceFaces(dices)
    --Reorganise the dice by face (increasing)
    local reorganisedDices = {}
    local temp = {}
    --On créée une liste d'incides, qui sert de base pour trier la liste de dés ET de diceFaces

    for _, dice in next,dices do
        table.insert(temp, dice)
    end

    table.sort(temp, function(a, b)
        return a.representedFace.faceValue < b.representedFace.faceValue
    end)
    for _, dice in ipairs(temp) do
        table.insert(reorganisedDices, dice)
    end

    local i = 1
    for key,uiFace in next,reorganisedDices do
        uiFace.targetX = (i)*(((self.dice_tray:getWidth()-100)/(table.getn(reorganisedDices)+1)))+50
        uiFace.targetY = (self.dice_tray:getHeight()/2)
        uiFace.baseRotation = 0
        i = i+1
    end
end

function RoundScreen:getCurrentlyHoveredFigure()
    local figureNames = {
        "Uns",
        "Deux",
        "Trois",
        "Quatres",
        "Cinqs",
        "Six",
        "Chance",
        "Brelan",
        "Full",
        "Petite Suite",
        "Grande Suite",
        "Carré",
        "Yhatze!",
    }

    local calcPoints = {
        function()return CalculatePoints.numberBasePoints(1, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(2, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(3, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(4, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(5, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.numberBasePoints(6, self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.chanceBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.brelanBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.fullBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.pttSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.gdSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.carreBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end,
        function()return CalculatePoints.yatzeeBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedFaceObjects)end
    }

    if(self.currentlyHoveredFigure) then
        local calculatedPoints = calcPoints[self.currentlyHoveredFigure]()[1]
        local usedDices = calcPoints[self.currentlyHoveredFigure]()[2]
        local textToShow = figureNames[self.currentlyHoveredFigure] .. " : "..calculatedPoints ..' pts'
        return({textToShow, usedDices})
    else
        return nil
    end
end

function RoundScreen:highlightDices(usedDices)
    for key,diceface in next,self.round.diceFaces2 do
        diceface:setHighlighted(false)
        for _, dice in next,usedDices do
            if self.round.diceFaces2[dice] == diceface then
                    diceface:setHighlighted(true)
                    break
            end
        end
    end
end

return RoundScreen