local Button = require("src.classes.ui.Button")
local Inputs = require("src.utils.scripts.inputs")
local Terrain = {}
Terrain.__index = Terrain

function Terrain:new()
    local self = setmetatable({}, Terrain)
    currentCanvas = love.graphics.getCanvas()
    --Dice Tray
    self.diceTrayX = 0
    self.diceTrayY = 0

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

    self.figureButtons = {}

    i = 0
    for key,image in next,image_buttons do
        button = Button:new(
            function()print(i)end, 
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
    for key,button in next, self.figureButtons do
        button:update(dt)
    end
end

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



return Terrain

