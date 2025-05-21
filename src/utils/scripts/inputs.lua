local Inputs = {}

function Inputs.getVirtualMousePosition(virtualWidth, virtualHeight)
    local mouseX, mouseY = love.mouse.getPosition()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = math.min(screenWidth /virtualWidth, screenHeight / virtualHeight)
    local offsetX = (screenWidth - virtualWidth * scale) / 2
    local offsetY = (screenHeight - virtualHeight * scale) / 2

    -- Ramène les coordonnées souris dans le repère virtuel
    local virtualX = (mouseX - offsetX) / scale
    local virtualY = (mouseY - offsetY) / scale

    return virtualX, virtualY
end

function Inputs.getCanvasScale(virtualWidth, virtualHeight)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = math.min(screenWidth / virtualWidth, screenHeight / virtualHeight)
    return scale
end

return Inputs