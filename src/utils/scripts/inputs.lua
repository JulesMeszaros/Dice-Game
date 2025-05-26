local Constants = require("src.utils.constants")

local Inputs = {}

function Inputs.getVirtualMousePosition()
    local mouseX, mouseY = love.mouse.getPosition()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = math.min(screenWidth /Constants.VIRTUAL_GAME_WIDTH, screenHeight / Constants.VIRTUAL_GAME_HEIGHT)
    local offsetX = (screenWidth - Constants.VIRTUAL_GAME_WIDTH * scale) / 2
    local offsetY = (screenHeight - Constants.VIRTUAL_GAME_HEIGHT * scale) / 2

    -- Ramène les coordonnées souris dans le repère virtuel
    local virtualX = (mouseX - offsetX) / scale
    local virtualY = (mouseY - offsetY) / scale

    return virtualX, virtualY
end

function Inputs.getCanvasScale()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = math.min(screenWidth / Constants.VIRTUAL_GAME_WIDTH, screenHeight / Constants.VIRTUAL_GAME_HEIGHT)
    return scale
end

function Inputs.getMouseInCanvas(canvasX, canvasY)
    local virtualX, virtualY = Inputs.getVirtualMousePosition(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    return {x = virtualX - canvasX, y=virtualY - canvasY}
end

return Inputs