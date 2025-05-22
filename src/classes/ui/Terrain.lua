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

    return self
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

    --Importation des images
    local image_buttons = {
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_1.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_2.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_3.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_4.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_5.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_6.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_chance.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_brelan.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_ptt_suite.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_gd_suite.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_carre.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_full.png"),
        love.graphics.newImage("src/assets/sprites/ui/buttons/figure_yatzee.png")
    }

    i = 0
    for key,image in next,image_buttons do
        love.graphics.draw(image,0,i*36)
        i=i+1
    end

    love.graphics.setCanvas(targetCanvas)

    love.graphics.draw(self.figureButtonsCanvas, x, y)
end



return Terrain

