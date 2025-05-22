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
    love.graphics.setCanvas(self.dice_tray)

    love.graphics.setCanvas(currentCanvas)
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

return Terrain

