local Button = require("src.classes.ui.Button")
local Inputs = require("src.utils.scripts.inputs")
local CalculatePoints = require("src.utils.scripts.calculatePoints")
local DiceHoverInfo = require("src.classes.ui.DiceHoverInfo")

local DiceObject = require("src.classes.DiceObject")
local FaceObject = require("src.classes.FaceTypes.WhiteDice")
local DiceFace = require("src.classes.ui.DiceFace")

local RoundScreen = {}

RoundScreen.__index = RoundScreen

local font = love.graphics.newFont("src/assets/fonts/joystix.otf", 20)
local matImage = love.graphics.newImage("src/assets/sprites/ui/terrain/dice_mat.png")

function RoundScreen:new(round)
    local self = setmetatable({}, RoundScreen)
    self.gameCanvas = round.gameCanvas

    self.uiElements = {
        roundButtons = {},
        figureButtons = {}
    }

    --Create the terrain canvas
    self.terrainCanvas = love.graphics.newCanvas(round.gameCanvas:getWidth(),round.gameCanvas:getHeight() )

    self.round = round

    --DICE TRAY
    self.diceTrayX = 0
    self.diceTrayY = 0

    self.currentlyHoveredFigure = nil
    
    self.currentlyHoveredDice = nil

    self.dice_tray = love.graphics.newCanvas(980, 700)
    self.dice_tray:setFilter("nearest", "nearest")

    --FIGURE BUTTONS
    self.figureButtonsCanvas = love.graphics.newCanvas(440,702)
    self.figureButtonsCanvas:setFilter("nearest", "nearest")
    
    --HoverInfos
    self.diceTrayHoverInfos = DiceHoverInfo:new("blablabla")

    --CREATION DES BOUTONS DE FIGURE
    --Importation des images
    local image_buttons = {
        "src/assets/sprites/ui/buttons/figure_1.png",
        "src/assets/sprites/ui/buttons/figure_2.png",
        "src/assets/sprites/ui/buttons/figure_3.png",
        "src/assets/sprites/ui/buttons/figure_4.png",
        "src/assets/sprites/ui/buttons/figure_5.png",
        "src/assets/sprites/ui/buttons/figure_6.png",
        "src/assets/sprites/ui/buttons/figure_chance.png",
        "src/assets/sprites/ui/buttons/figure_brelan.png",
        "src/assets/sprites/ui/buttons/figure_full.png",
        "src/assets/sprites/ui/buttons/figure_ptt_suite.png",
        "src/assets/sprites/ui/buttons/figure_gd_suite.png",
        "src/assets/sprites/ui/buttons/figure_carre.png",
        "src/assets/sprites/ui/buttons/figure_yatzee.png"
    }

    local calculatePointsFunctions = {
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

    self.figureButtons = {}

    local i = 0
    for key,image in next,image_buttons do
        local t = i
        local button = Button:new(
            calculatePointsFunctions[key],
            image, 
            self.figureButtonsCanvas:getWidth()/2, 
            (i*36*1.5)+18*1.5, 
            440, 
            36*1.5, 
            currentCanvas, 
            function()return Inputs.getMouseInCanvas(20, 20)end
        )
        table.insert(self.figureButtons, button)
        i=i+1
    end

    --FACE DETAILS
    self.faceDetailsCanvas = love.graphics.newCanvas(420, 300)

    --DICE DETAILS
    self.diceDetailsCanvas = love.graphics.newCanvas(420, 490)
    self:createDiceNet()

    --Creating the different ui faces that will be shown

    --BOUTONS

    self.uiElements.roundButtons["reorganiserButton"] = Button:new(
        function()self:reorganiseDiceFaces(self.round.diceFaces2)end, 
        "src/assets/sprites/ui/buttons/reorganiser.png", 
        self.terrainCanvas:getWidth()/2-100, 
        self.terrainCanvas:getHeight()-65, 
        90, 
        90,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.roundButtons["rerollButton"] = Button:new(
        function()self.round:rerollDices()end, 
        "src/assets/sprites/ui/buttons/reroll.png", 
        self.terrainCanvas:getWidth()/2+100, 
        self.terrainCanvas:getHeight()-65, 
        90, 
        90,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    return self
end

function RoundScreen:update(dt)
    --Reset Bouton de figure et Dé survolé
    self.currentlyHoveredFigure = nil

    -- Figure buttons
    for key,button in next, self.figureButtons do
        button:update(dt)

        if(button:isHovered())then self.currentlyHoveredFigure = key end

         --Deactivate buttons if no hand remaining (temporaire)
         if(self.round.remainingHands <= 0)then
            button.isActivated = false
         else
            button.isActivated = true
         end
    end

    --Hover infos
    self:getCurrentlyHoveredDice()


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
    --Dice Tray
    self:drawDiceTray(480+self.dice_tray:getWidth()/2, self.terrainCanvas:getHeight()/2+60, self.round.diceFaces2)

    --Figure Buttons
    self:drawFigureButtons(20, 20)

    --Bouttouns de round
    for k,b in next,self.uiElements.roundButtons do
        b:draw()
    end

    --Différents textes
    local rerollText = love.graphics.newText(font, "Rerolls : " ..tostring(self.round.availableRerolls))
    local scoreText = love.graphics.newText(font, 'Score : ' ..tostring(self.round.roundScore))
    local targetScoreText = love.graphics.newText(font, 'Target : '..tostring(self.round.targetScore))
    local currentHands = love.graphics.newText(font, 'Hands : '..tostring(self.round.remainingHands))
    local currentRoundText = love.graphics.newText(font, 'Round : '..tostring(self.round.nround).. " - Money : "..tostring(self.round.run.money).."€")

    love.graphics.draw(rerollText, 10, 750)
    love.graphics.draw(currentHands, 10, 773)
    love.graphics.draw(targetScoreText, 10, 793)
    love.graphics.draw(scoreText, 10, 813)

    love.graphics.draw(currentRoundText, 10, self.gameCanvas:getHeight()-10, 0, 1, 1, 0, currentRoundText:getHeight())


    --Highlighted figure
    if(self.currentlyHoveredFigure)then
        -- Creates a text with the name of the figure and the text
        local figureHoveredText = love.graphics.newText(font, self:getCurrentlyHoveredFigure()[1])
        love.graphics.draw(figureHoveredText, 20, self.terrainCanvas:getHeight()-100, 0, 1, 1, 0, figureHoveredText:getHeight()/2)

        --Highlight the used dices
        local usedDices = self:getCurrentlyHoveredFigure()[2]

        for key,diceface in next,self.round.diceFaces2 do
            diceface:setHighlighted(false)
            for _, dice in next,usedDices do
                if self.round.diceFaces2[dice] == diceface then
                     diceface:setHighlighted(true)
                     break
                end
            end
        end
    else
        for key,diceface in next,self.round.diceFaces2 do
            diceface:setHighlighted(false)
        end
    end

    --Hover Infos
    self.diceTrayHoverInfos:draw()

    --Face Details
    self:drawFaceDetails(self.terrainCanvas:getWidth()-20, self.terrainCanvas:getHeight()-20)

    --Dice Details
    self:updateDiceNet()
    self:drawDiceDetails(self.terrainCanvas:getWidth()-20, self.terrainCanvas:getHeight()-40-self.faceDetailsCanvas:getHeight())
    for k,df in next,self.infoFaces do
        df:updateCanvas(dt)
    end
    

    love.graphics.setCanvas(self.gameCanvas)
end

--==DRAW FUNCTIONS==--

function RoundScreen:drawDiceTray(x, y, dices2)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.dice_tray)
    love.graphics.clear(60/255, 99/255, 60/255)

    love.graphics.draw(matImage, 0, 0, 0, 1, 1)

    --On déssine les autres dés
    for key,uiFace in next,dices2 do
        uiFace:draw()
    end

    --On retourne au canvas précédent
    love.graphics.setCanvas(targetCanvas)
    --On déssine le terrain à dés sur le canvas
    love.graphics.draw(self.dice_tray, x, y, 0, 1, 1, self.dice_tray:getWidth()/2, self.dice_tray:getHeight()/2) --On fixe son offset sur son angle superieur droit

end

function RoundScreen:drawFigureButtons(x, y)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.figureButtonsCanvas)
    love.graphics.clear()

    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 0, 0, self.figureButtonsCanvas:getWidth(), self.figureButtonsCanvas:getHeight())

    for key,button in next,self.figureButtons do
        button:draw(self.figureButtonsCanvas)
    end

    love.graphics.setCanvas(targetCanvas)
    
    love.graphics.draw(self.figureButtonsCanvas, x, y)
end

function RoundScreen:drawFaceDetails(x, y)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.faceDetailsCanvas)
    love.graphics.clear(60/255, 99/255, 60/255)

    love.graphics.rectangle("line", 0, 0, self.faceDetailsCanvas:getWidth(), self.faceDetailsCanvas:getHeight())

    if(self.currentlyHoveredDice) then
        --Face Name
        local faceName = self.currentlyHoveredDice:getCurrentFaceObject().name
        local nameText = love.graphics.newText(font, faceName)

        --Description
        local faceDescription = self.currentlyHoveredDice:getCurrentFaceObject().description
        local descWidth, descWrappedtext = font:getWrap( faceDescription, self.faceDetailsCanvas:getWidth()-10 )
        local descText = love.graphics.newText(font, table.concat(descWrappedtext, "\n"))

        love.graphics.draw(nameText, self.faceDetailsCanvas:getWidth()/2, 5, 0, 1, 1, nameText:getWidth()/2, 0)
        love.graphics.draw(descText, self.faceDetailsCanvas:getWidth()/2, 40, 0, 1, 1, descText:getWidth()/2, 0)
    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.faceDetailsCanvas, x, y, 0, 1, 1, self.faceDetailsCanvas:getWidth(), self.faceDetailsCanvas:getHeight())
end

function RoundScreen:drawDiceDetails(x, y)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceDetailsCanvas)
    love.graphics.clear(60/255, 99/255, 60/255)

    love.graphics.rectangle("line", 0, 0, self.diceDetailsCanvas:getWidth(), self.diceDetailsCanvas:getHeight())

    --Draw the dice net
    if self.currentlyHoveredDice then
        for k,df in next,self.infoFaces do
            df:draw()
        end
    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.diceDetailsCanvas, x, y, 0, 1, 1, self.diceDetailsCanvas:getWidth(), self.diceDetailsCanvas:getHeight())
end

--==UTILS FUNCTIONS==--
function RoundScreen:updateDiceNet()
    if(self.currentlyHoveredDice) then
        for i = 1, 6 do
            self.infoFaces[i]:setRepresentedFace(self.currentlyHoveredDice:getFace(i))
            self.infoFaces[i]:updateSprite()
        end
    end

    
end

function RoundScreen:createDiceNet()
    --Create a temp dice with a temp face repeated 6 times
    local tempFace = FaceObject:new(6)
    self.tempDice = DiceObject:new({tempFace, tempFace, tempFace, tempFace, tempFace, tempFace})

    --Create the coordinates of each dice face
    local diceFacesCoords = {
        {self.diceDetailsCanvas:getWidth()/2-80, self.diceDetailsCanvas:getHeight()/2}, --1
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2-80}, --2
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2}, --3
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2+160}, --4
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2+80}, --5
        {self.diceDetailsCanvas:getWidth()/2+80, self.diceDetailsCanvas:getHeight()/2}, --6
    }
    
    -- Create the uiFaces objects
    local infoFaces = {}

    for k,d in next,self.tempDice:getAllFaces() do
        local diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            self.tempDice, --Dice Object 
            d, --La face représentée
            diceFacesCoords[k][1], --X Position (centerd)
            diceFacesCoords[k][2], --Yposition (centerd)
            80, --Width/Height
            false, --is Selectable
            false, --isHoverable,
            function()return Inputs.getMouseInCanvas(0,0)end,
            self.round
        )

        table.insert(infoFaces, diceFaceUI)
    end

    self.infoFaces = infoFaces
end

function RoundScreen:getCurrentlyHoveredDice()
    self.currentlyHoveredDice = nil

    for key,diceface in next,self.round.diceFaces2 do
        if diceface:isHovered() then
            self.currentlyHoveredDice = diceface.diceObject
            break
        end
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
        uiFace.targetX = (i)*(((self.dice_tray:getWidth()-200)/(table.getn(reorganisedDices)+1)))+100
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

return RoundScreen

