local Button = require("src.classes.ui.Button")
local Inputs = require("src.utils.scripts.inputs")
local CalculatePoints = require("src.utils.scripts.calculatePoints")

local Terrain = {}
Terrain.__index = Terrain

function Terrain:new()
    local self = setmetatable({}, Terrain)
    currentCanvas = love.graphics.getCanvas()
    --Dice Tray
    self.diceTrayX = 0
    self.diceTrayY = 0

    self.currentlyHoveredFigure = nil

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
        "src/assets/sprites/ui/buttons/figure_ptt_suite.png",
        "src/assets/sprites/ui/buttons/figure_gd_suite.png",
        "src/assets/sprites/ui/buttons/figure_carre.png",
        "src/assets/sprites/ui/buttons/figure_full.png",
        "src/assets/sprites/ui/buttons/figure_yatzee.png"
    }

    local calculatePointsFunctions = {
        function()print(CalculatePoints.numberBasePoints(1))end,
        function()print(CalculatePoints.numberBasePoints(2))end,
        function()print(CalculatePoints.numberBasePoints(3))end,
        function()print(CalculatePoints.numberBasePoints(4))end,
        function()print(CalculatePoints.numberBasePoints(5))end,
        function()print(CalculatePoints.numberBasePoints(6))end,
        function()print(CalculatePoints.brelanBasePoints())end,
        function()print(CalculatePoints.fullBasePoints())end,
        function()print(CalculatePoints.carreBasePoints())end,
        function()print(CalculatePoints.pttSuiteBasePoints())end,
        function()print(CalculatePoints.gdSuiteBasePoints())end,
        function()print(CalculatePoints.chanceBasePoints())end,
        function()print(CalculatePoints.yatzeeBasePoints())end,
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
    --Reset Bouton de figure survolé
    self.currentlyHoveredFigure = nil
    for key,button in next, self.figureButtons do
        button:update(dt)

        if(button:isHovered())then self.currentlyHoveredFigure = key end
    end
end

--==DRAW FUNCTIONS==--

function Terrain:drawDiceTray(x, y, dices)
    targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.dice_tray)
    love.graphics.clear()

    matImage = love.graphics.newImage("src/assets/sprites/ui/terrain/dice_mat.png")
    love.graphics.draw(matImage, 0, 0)

    for key,uiFace in next,dices do
        uiFace:draw()
    end

    love.graphics.setCanvas(targetCanvas)
    
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
        "Carré",
        "Full",
        "Petite Suite",
        "Grande Suite",
        "Yhatze!",
    }

    if(self.currentlyHoveredFigure)then
        return(figureNames[self.currentlyHoveredFigure])
    else
        return nil
    end
end

return Terrain

