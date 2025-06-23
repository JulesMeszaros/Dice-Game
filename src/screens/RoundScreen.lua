--Utils
local Inputs = require("src.utils.scripts.Inputs")
local CalculatePoints = require("src.utils.scripts.CalculatePoints")
local Fonts = require("src.utils.Fonts")
local Constants = require("src.utils.Constants")
local FaceHoverInfos = require("src.classes.ui.FaceHoverInfo")
local AnimationUtils = require("src.utils.scripts.Animations")
--UI
local Button = require("src.classes.ui.Button")
local Sprites = require("src.utils.Sprites")
--Ciggies
local Ciggie = require("src.classes.ui.Ciggie")
local CiggieObject = require("src.classes.CiggieObject")
--Dices
local DiceObject = require("src.classes.DiceObject")
local FaceObject = require("src.classes.FaceObject")
local DiceFace = require("src.classes.ui.DiceFace")

--Sprites
local descriptionSprite = love.graphics.newImage("src/assets/sprites/ui/Description.png")
local DiceInfosSprite = love.graphics.newImage("src/assets/sprites/ui/DiceComposition.png")
local EnemyInfosSprite= love.graphics.newImage("src/assets/sprites/ui/Enemy.png")
local FloorInfosSprite= love.graphics.newImage("src/assets/sprites/ui/Office.png")
local PlayerInfosSprite = love.graphics.newImage("src/assets/sprites/ui/Player.png")
local MoneySprite= love.graphics.newImage("src/assets/sprites/ui/Money.png")
local RerollsSprite= love.graphics.newImage("src/assets/sprites/ui/Rerolls.png")
local TableauFiguresSprite= love.graphics.newImage("src/assets/sprites/ui/Grid.png")
local DiceMatSprite = love.graphics.newImage("src/assets/sprites/ui/Dice Mat.png")
local TurnsSprite= love.graphics.newImage("src/assets/sprites/ui/Turns.png")

local Animator = require("src.utils.Animator")

local RoundScreen = {}

RoundScreen.__index = RoundScreen

local font = Fonts.nexaSmall
local font30 = Fonts.nexaMedium

function RoundScreen:new(round)
    local self = setmetatable({}, RoundScreen)
    self.animator = Animator:new(self)
    self.gameCanvas = round.gameCanvas
    self.round = round

    self.uiElements = {
        roundButtons = {},
        ciggiesUI = {}
    }

    self.x, self.y = 0, 0

    --Create the terrain canvas
    self.canvas = love.graphics.newCanvas(round.gameCanvas:getWidth(),round.gameCanvas:getHeight() )

    --DICE TRAY
    self.dice_tray = love.graphics.newCanvas(930, 630)
    self.dice_tray:setFilter("linear", "linear")

    
    --Hovered infos
    self.currentlyHoveredFigure = nil 
    self.currentlyHoveredDice = nil
    self.currentlyHoveredFace = nil
    self.previouslyHoveredFace = nil

    --FIGURE BUTTONS
    self.figureButtonsCanvas = love.graphics.newCanvas(450,670)
    self.figureButtonsCanvas:setFilter("linear", "linear")
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
    
    --FACE DETAILS
    self.descriptionCanvas = love.graphics.newCanvas(420, 240)
    self.pointsDetailsCanvas = nil

    --DICE DETAILS
    self.diceDetailsCanvas = love.graphics.newCanvas(420, 600)
    self.diceDetailsTimer = 0
    self.diceDetailsTime = 0.5
    --Creating the different ui faces that will be shown
    self:createDiceNet()

    --ROUND DETAILS
    self:createRoundInfos()

    --Ciggies
    self.ciggiesTray = love.graphics.newCanvas(420, 140)
    self.hoveredByCiggie = nil
    
    --Hand Score
    self.handScoreCanvas = love.graphics.newCanvas(self.dice_tray:getWidth(), 170)
    self.handScoreRX, self.handScoreRY = 1
    self.handScoreRot = 0

    --Positions
    self.gridTX, self.gridTY, self.gridX, self.gridY = 30, 30, 30, -650
    self.diceMatTX, self.diceMatTY, self.diceMatx, self.diceMaty = 510 , 320, 510, self.canvas:getHeight()+1000
    self.diceDetailsTX, self.diceDetailsTY, self.diceDetailsX, self.diceDetailsY = self.canvas:getWidth()-30, 30, self.canvas:getWidth()+600, 30
    self.descriptionTX, self.descriptionTY, self.descriptionX, self.descriptionY = self.canvas:getWidth()-30, 650, self.canvas:getWidth()+600, 650
    self.enemyTX, self.enemyTY, self.enemyX, self.enemyY = 790, 30, self.canvas:getWidth()+20, 30
    self.playerTX, self.playerTY, self.playerX, self.playerY = 510, 30, -800, 30
    self.ciggiesTrayTX, self.ciggiesTrayTY, self.ciggiesTrayX, self.ciggiesTrayY = self.canvas:getWidth()-30, self.canvas:getHeight()-30, self.canvas:getWidth()+450, self.canvas:getHeight()-30

    self.rerollsTX, self.rerollsTY, self.rerollsX, self.rerollsY = 260, 721, -500, 721
    self.turnsTX, self.turnsTY, self.turnsX, self.turnsY = 30, 721, -730, 721
    self.floorTX, self.floorTY, self.floorX, self.floorY = 190, 970, 190, self.canvas:getHeight()+400
    self.moneyTX, self.moneyTY, self.moneyX, self.moneyY = 190, 860, 190, self.canvas:getHeight()+300

    --Btns positions
    self.rerollBtnTX, self.rerollBtnTY, self.rerollBtnX, self.rerollBtnY = 975, 1010, 975, 1500
    self.planBtnTX, self.planBtnTY, self.planBtnX, self.planBtnY = 100, 910, -150, 910
    self.menuBtnTX, self.menuBtnTY, self.menuBtnX, self.menuBtnY = 100, 1010, -150, 1010

    --LEFT PANNEL BUTTONS

    self.uiElements.roundButtons["rerollButton"] = Button:new(
        function()self.round:rerollDices()end, 
        "src/assets/sprites/ui/Reroll.png", 
        self.rerollBtnX,
        self.rerollBtnY,
        840, 
        80,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.roundButtons["menuButton"] = Button:new(
        function()print("menu")end,
        "src/assets/sprites/ui/Menu.png",
        self.menuBtnX,
        self.menuBtnY,
        140,
        80,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.roundButtons["planButton"] = Button:new(
        function()print("plan")end,
        "src/assets/sprites/ui/Plan.png",
        self.planBtnX,
        self.planBtnY,
        140,
        100,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    local entryDuration = 0.3

    --Animation
    self.animator:addGroup({
        {property = "gridY", from = self.gridY, targetValue = self.gridTY, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.diceDetailsTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.descriptionTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "diceMaty", from = self.diceMaty, targetValue = self.diceMatTY, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "moneyY", from = self.moneyY, targetValue = self.moneyTY, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = self.turnsTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = self.rerollsTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.floorTY, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.ciggiesTrayTX, duration = entryDuration, easing = AnimationUtils.Easing.inOutCubic},
    })
    self.animator:addDelay(0.2)
    self.animator:addGroup({
        {property = "playerX", from = self.playerX, targetValue = self.playerTX, duration = entryDuration, },
        {property = "enemyX", from = self.enemyX, targetValue = self.enemyTX, duration = entryDuration,},
    })
    --Buttons animation
    self.uiElements.roundButtons["rerollButton"].animator:add('y', self.rerollBtnY, self.rerollBtnTY, entryDuration, AnimationUtils.Easing.inOutCubic)
    self.uiElements.roundButtons["menuButton"].animator:add('x', self.menuBtnX, self.menuBtnTX, entryDuration, AnimationUtils.Easing.inOutCubic)
    self.uiElements.roundButtons["planButton"].animator:add('x', self.planBtnX, self.planBtnTX, entryDuration, AnimationUtils.Easing.inOutCubic)

    AnimationUtils.shake(self, 0, 10, 0.1)
    self.animator:addDelay(0.5, function()self.round:makeRoll(self.round.diceObjects)end)

    --PLAYERS INFOS
    self.playerInfos = love.graphics.newCanvas(650,260)
    self.enemyInfos = love.graphics.newCanvas(650,260)

    return self
end

function RoundScreen:update(dt)
    --Reset Bouton de figure et Dé survolé
    self.currentlyHoveredFigure = nil

    self.animator:update(dt)

    --Hover infos
    self:getCurrentlyHoveredDice() --Le dé survolé

    --Utilities buttons
    for key,button in next,self.uiElements.roundButtons do
        self.uiElements.roundButtons["rerollButton"]:setActivated(self.round.availableRerolls>0 and table.getn(self.round.selectedDices)<table.getn(self.round.diceObjects))

        button:update(dt)
    end

    --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
    end
    self:getCanvasHoveredByCiggie()

    self:updateCanvas(dt)

end

function RoundScreen:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    if(self.round.roundType == Constants.ROUND_TYPES.BASE)then
        love.graphics.clear(40/255, 40/255, 43/255)
    else
        love.graphics.clear(55/255, 96/255, 85/255)
    end

    --PlayersInfos
    self:drawPlayersInfos()
    --Dice Tray
    if(self.pointsDetailsCanvas) then
        self.pointsDetailsCanvas:update(dt)
    end
    self:drawDiceTray(self.diceMatx, self.diceMaty, self.round.diceFaces)

    --Figure Buttons

    self:drawFigureGrid(self.gridX, self.gridY)
    self:getCurrentlyHoveredLine() --La figure survolée


    --Bouttouns de round
    for k,b in next,self.uiElements.roundButtons do
        b:draw()
    end

    --Face Details
    self:drawFaceDetails(self.descriptionX, self.descriptionY)

    --Dice Details
    self:updateDiceNet(dt)
    for k,df in next,self.infoFaces do --éventuellement à bouger dans la fonction drawFaceDetails
        df.targetedScale = self.diceDetailsTimer/self.diceDetailsTime
        df:updateCanvas(dt) 
        df:update(dt)
    end
    self:drawDiceDetails(self.diceDetailsX, self.diceDetailsY)
    
    --ROUND DETAILS
    self:drawRoundDetails()

    --Ciggies Tray
    self:drawCiggiesTray()

    --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:draw()
    end

    love.graphics.setCanvas(currentCanvas)
end

function RoundScreen:updateSelectedPosDices()
    local i = 1
    for k,d in next,self.round.selectedDices do
        self.round.diceFaces[d].targetY = 70
        self.round.diceFaces[d].targetX = 105 + (i-1)*(180)
        i=i+1
    end
end

--==DRAW FUNCTIONS==--

function RoundScreen:drawDiceTray(x, y, dices2)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.dice_tray)
    love.graphics.clear()
    if(self.hoveredByCiggie == Constants.CANVAS.DICE_MAT) then
        love.graphics.setColor(0, 0.8, 0, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.draw(DiceMatSprite, 0, 0, 0, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)
    --On déssine les autres dés
    for key,uiFace in next,dices2 do
        uiFace:draw()
    end

    --On dessine la bulle des points
    if(self.currentlyHoveredFace)then
        self.pointsDetailsCanvas:draw()
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

function RoundScreen:drawFigureGrid(x, y)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.figureButtonsCanvas)
    love.graphics.clear()
    --Draw the table
    love.graphics.draw(TableauFiguresSprite, 0, 0)

    --Write the calculatedPoints
    love.graphics.setColor(0, 0, 0, 1)
    --Draw the scores
    for i=1, 13 do
        local calcScore = love.graphics.newText(Fonts.nexaSmall, self.calcBasePoints[i]()[1])
        love.graphics.draw(calcScore, 225, 50*(i-1)+38, 0, 1, 1, calcScore:getWidth()/2, calcScore:getHeight()/2)
    end

    --Write the remaining possible hands
    for i=1, 13 do
        local handsRemaining = love.graphics.newText(Fonts.nexaSmall, self.round.run.availableFigures[i])
        love.graphics.draw(handsRemaining, 368, 50*(i-1)+38, 0, 1, 1, handsRemaining:getWidth()/2, handsRemaining:getHeight()/2)
        --if no hands remaining, grey out the line
        if(self.round.run.availableFigures[i]<=0) then
            love.graphics.setColor(0.4, 0.4, 0.4, 0.4)
            love.graphics.rectangle("fill", 10, (i-1)*50+10, self.figureButtonsCanvas:getWidth()-20, 50)
            love.graphics.setColor(0, 0, 0, 1)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

    local mv = Inputs.getMouseInCanvas(30, 30) --get the mouse position
    local i = math.floor((mv.y-10)/50)+1

    self:highlightDices({})

    --If we are hovering a line
    if(i>0 and i<=13)then
        if(mv.x>0 and mv.x<self.figureButtonsCanvas:getWidth())then
            self:highlightDices(self.calcBasePoints[i]()[2])
            --Draw a shadow on the line
            if(self.round.run.availableFigures[i]>=1 and table.getn(self.round.selectedDices)>=1)then
                if(love.mouse.isDown(1)) then
                    love.graphics.setColor(0.7, 0, 0, 0.3)
                else
                    love.graphics.setColor(1, 0, 0, 0.3)
                end
                love.graphics.rectangle("fill", 10, (i-1)*50+10, self.figureButtonsCanvas:getWidth()-20, 50)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    love.graphics.setCanvas(targetCanvas)
    
    love.graphics.draw(self.figureButtonsCanvas, x, y)
    
end

function RoundScreen:drawFaceDetails(x, y)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.descriptionCanvas)
    love.graphics.clear()
    --Draw Sprite
    love.graphics.draw(descriptionSprite, 0, 0)

    if(self.currentlyHoveredDice) then
        --Face Name
        local faceName = self.currentlyHoveredDice:getCurrentFaceObject().name
        local nameText = love.graphics.newText(Fonts.nexa30, faceName)

        --Face tier
        local tierText = love.graphics.newText(
            Fonts.nexaSmall,
            self.currentlyHoveredDice:getCurrentFaceObject().tier
        )

        --Description
        local faceDescription = self.currentlyHoveredDice:getCurrentFaceObject().description
        local descWidth, descWrappedtext = Fonts.nexaDesc:getWrap( faceDescription, self.descriptionCanvas:getWidth()-18 )
        local descText = love.graphics.newText(Fonts.nexaDesc, table.concat(descWrappedtext, "\n"))

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.draw(nameText, self.descriptionCanvas:getWidth()/2, 65, 0, 1, 1, nameText:getWidth()/2, 0)
        love.graphics.draw(tierText, self.descriptionCanvas:getWidth()/2, 105, 0, 1, 1, tierText:getWidth()/2, 0)
        love.graphics.draw(descText, self.descriptionCanvas:getWidth()/2, 140, 0, 1, 1, descText:getWidth()/2, 0)
        love.graphics.setColor(1, 1, 1, 1)

    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.descriptionCanvas, x, y, 0, 1, 1, self.descriptionCanvas:getWidth(), 0)
end

function RoundScreen:drawDiceDetails(x, y)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceDetailsCanvas)
    love.graphics.clear()

    --Draw sprite
    love.graphics.draw(DiceInfosSprite, 0, 0)
    
    --Draw the dice net
    if self.currentlyHoveredDice then
        for k,df in next,self.infoFaces do
            if(df.representedFace == self.currentlyHoveredDice:getCurrentFaceObject())then
                love.graphics.setColor(1, 0, 0, 1)
                --love.graphics.rectangle("fill", df.x-5-df.size/2, df.y-5-df.size/2, 125, 125)
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
    local currentRoundText = love.graphics.newText(font, 'Floor '..tostring(self.round.floorNumber)..'\nDesk : '..tostring(self.round.deskNumber))
    local moneyText = love.graphics.newText(Fonts.nexaBig, tostring(self.round.run.money).."€")

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

function RoundScreen:drawCiggiesTray()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.ciggiesTray)

    love.graphics.draw(Sprites.CIGGIES_TRAY, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.ciggiesTray, self.ciggiesTrayX, self.ciggiesTrayY, 0, 1, 1, self.ciggiesTray:getWidth(), self.ciggiesTray:getHeight())
end

function RoundScreen:drawPlayersInfos()
    local currentCanvas = love.graphics.getCanvas()
    --Player
    love.graphics.setCanvas(self.playerInfos)
    love.graphics.clear()
    love.graphics.draw(PlayerInfosSprite, 0, 0)
    local scoreText = love.graphics.newText(font, 'Score : ' ..tostring(self.round.roundScore))
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(scoreText, self.playerInfos:getWidth()-20, 72, 0, 1, 1, scoreText:getWidth(), 0)
    love.graphics.setColor(1, 1, 1, 1)

    --Ennemy
    love.graphics.setCanvas(self.enemyInfos)
    love.graphics.clear()
    love.graphics.draw(EnemyInfosSprite, 0, 0)
    local targetScoreText = love.graphics.newText(font, 'Target : '..tostring(self.round.targetScore))
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(targetScoreText, 20, 210)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.playerInfos, self.playerX, self.playerY)
    love.graphics.draw(self.enemyInfos, self.enemyX, self.enemyY)
end

--==CREATE CANVAS FUNCTIONS==--
function RoundScreen:createDiceNet()
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
    self.rerollsCanvas = love.graphics.newCanvas(220, 120)
    self.handsCanvas = love.graphics.newCanvas(220, 120)
    self.roundNumberCanvas = love.graphics.newCanvas(290, 80)
    self.moneyCanvas = love.graphics.newCanvas(290, 100)
end

--==FIGURES TABLE==--
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


--==Animations==--
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

    local scoreText = love.graphics.newText(Fonts.nexaBig, self.round.handScore)
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
    self.animator:addDelay(0.2)
    self.animator:addGroup({
        {property = "playerX", from = self.playerX, targetValue = -800, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "enemyX", from = self.enemyX, targetValue = self.canvas:getWidth()+20, duration = outDuration, easing = AnimationUtils.Easing.inCubic, onComplete=function()self.round.run:endRound()end},
    })

    --Buttons animation
    self.uiElements.roundButtons["rerollButton"].animator:add('y', self.rerollBtnY, 1500, outDuration)
    self.uiElements.roundButtons["menuButton"].animator:add('x', self.menuBtnX, -150, outDuration)
    self.uiElements.roundButtons["planButton"].animator:add('x', self.planBtnX, -150, outDuration)

end

--==UTILS FUNCTIONS==--
function RoundScreen:getCurrentlyHoveredDice()
    self.previouslyHoveredFace = self.currentlyHoveredFace
    self.currentlyHoveredFace = nil
    self.currentlyHoveredDice = nil

    for key,diceface in next,self.round.diceFaces do
        if diceface:isHovered() then
            self.currentlyHoveredDice = diceface.diceObject
            self.currentlyHoveredFace = diceface
            break
        end
    end

    if(self.previouslyHoveredFace ~= self.currentlyHoveredFace and self.currentlyHoveredFace~= nil)then
        self.pointsDetailsCanvas = FaceHoverInfos:new(self.currentlyHoveredFace, "points")
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

function RoundScreen:playFigure(figure, params)
    local points, usedDices = params[1], params[2]
    if(self.round.run.availableFigures[figure]>=1 and table.getn(self.round.selectedDices)>=1)then
        self.round:playFigure(points, usedDices)
        self.round.run.availableFigures[figure] = self.round.run.availableFigures[figure]-1
    end
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
        uiFace.targetY = (self.dice_tray:getHeight()/2+140)
        uiFace.baseRotation = 0
        i = i+1
    end    
end

function RoundScreen:highlightDices(usedDices)
    for key,diceface in next,self.round.diceFaces do
        diceface:setHighlighted(false)
        for _, dice in next,usedDices do
            if self.round.diceFaces[dice] == diceface then
                    diceface:setHighlighted(true)
                    break
            end
        end
    end
end

function RoundScreen:generateCiggiesUI()
    for i,ciggie in next,self.round.run.ciggiesObjects do
        self.uiElements.ciggiesUI[ciggie] = Ciggie:new(ciggie, 1680, 949+((i-1)*60), true, true, function()return Inputs.getMouseInCanvas(0, 0)end, self.round)
    end
end

function RoundScreen:getCanvasHoveredByCiggie()
    self.hoveredByCiggie = nil
    for i, ciggie in next,self.uiElements.ciggiesUI do --get the current canvas hovered by a ciggie (if one is hovered)
        local canvas = ciggie:detectBelowCanvas(self.round)
        if(canvas)then
            self.hoveredByCiggie = canvas
            break
        end
    end
end

return RoundScreen