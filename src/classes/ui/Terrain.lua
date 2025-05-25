local Button = require("src.classes.ui.Button")
local Inputs = require("src.utils.scripts.inputs")
local CalculatePoints = require("src.utils.scripts.calculatePoints")

local Terrain = {}
Terrain.__index = Terrain

local font = love.graphics.newFont("src/assets/fonts/joystix.otf", 20)

function Terrain:new(round)
    local self = setmetatable({}, Terrain)
    currentCanvas = love.graphics.getCanvas()

    self.round = round

    --Dice Tray
    self.diceTrayX = 0
    self.diceTrayY = 0

    self.currentlyHoveredFigure = nil
    self.currentlyHoveredDice = nil

    self.dice_tray = love.graphics.newCanvas(900, 550)
    self.dice_tray:setFilter("linear", "linear")

    --Figure buttons
    self.figureButtonsCanvas = love.graphics.newCanvas(330,468)
    self.figureButtonsCanvas:setFilter("linear", "linear")

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
        function()self:playFigure(CalculatePoints.numberBasePoints(1, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(2, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(3, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(4, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(5, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.numberBasePoints(6, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.chanceBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.brelanBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.fullBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.pttSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.gdSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.carreBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
        function()self:playFigure(CalculatePoints.yatzeeBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices))end,
    }

    self.figureButtons = {}

    local i = 0
    for key,image in next,image_buttons do
        local t = i
        print(i)
        button = Button:new(
            calculatePointsFunctions[key], 
            image, 
            self.figureButtonsCanvas:getWidth()/2, 
            (i*36)+18, 
            330, 
            36, 
            currentCanvas, 
            function()return Inputs.getMouseInCanvas(20, 102)end
        )
        table.insert(self.figureButtons, button)
        i=i+1
    end

    return self
end

function Terrain:update(dt)
    --Reset Bouton de figure et Dé survolé
    self.currentlyHoveredFigure = nil
    self.currentlyHoveredDice = nil

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

    for key,diceface in next,self.round.diceFaces do --On récupère le dé survolé par la souris
        if(diceface:isHovered())then
            self.currentlyHoveredDice = diceface.dice.name
        end
    end
end

--==DRAW FUNCTIONS==--

function Terrain:playFigure(points)
    self.round:playFigure(points)
end

function Terrain:drawDiceTray(x, y, dices)
    targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.dice_tray)
    love.graphics.clear()

    matImage = love.graphics.newImage("src/assets/sprites/ui/terrain/dice_mat.png")
    love.graphics.draw(matImage, 0, 0)

    --On déssiné les dés
    for key,uiFace in next,dices do
        uiFace:draw()
    end

    --On déssine le nom du dé survolé (si il existe)
    diceName = love.graphics.newText(font, tostring(self.currentlyHoveredDice))
    if(self.currentlyHoveredDice)then
        love.graphics.draw(diceName, self.dice_tray:getWidth()/2, 20, 0, 1, 1, diceName:getWidth()/2, diceName:getHeight()/2)
    end

    --On retourne au canvas précédent
    love.graphics.setCanvas(targetCanvas)
    --On déssine le terrain à dés sur le canvas
    love.graphics.draw(self.dice_tray, x, y, 0, 1, 1, self.dice_tray:getWidth(), 0) --On fixe son offset sur son angle superieur droit

end

function Terrain:drawFigureButtons(x, y)
    targetCanvas = love.graphics.getCanvas()
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

--==UTILS FUNCTIONS==--

function Terrain:reorganiseDiceFaces(dices)
    i = 1
    for key,uiFace in next,dices do
        uiFace.targetX = ((i*80) - 30)
        uiFace.targetY = (self.dice_tray:getHeight()-60)
        uiFace.baseRotation = 0
        i = i+1
    end
end

function Terrain:getCurrentlyHoveredFigure()
    figureNames = {
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

    calcPoints = {
        function()return CalculatePoints.numberBasePoints(1, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.numberBasePoints(2, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.numberBasePoints(3, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.numberBasePoints(4, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.numberBasePoints(5, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.numberBasePoints(6, self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.chanceBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.brelanBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.fullBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.pttSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.gdSuiteBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.carreBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end,
        function()return CalculatePoints.yatzeeBasePoints(self.round.selectedFaces, self.round.selectedDices, self.round.drawedDices)end
    }

    if(self.currentlyHoveredFigure)then
        return(figureNames[self.currentlyHoveredFigure] .. " : ".. calcPoints[self.currentlyHoveredFigure]()..' pts')
    else
        return nil
    end
end

return Terrain

