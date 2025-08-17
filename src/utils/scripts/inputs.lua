local Constants = require("src.utils.Constants")

local Inputs = {}

function Inputs.getVirtualMousePosition(layer)
    local mouseX, mouseY = love.mouse.getPosition()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = math.min(screenWidth /Constants.VIRTUAL_GAME_WIDTH, screenHeight / Constants.VIRTUAL_GAME_HEIGHT)
    local offsetX = (screenWidth - Constants.VIRTUAL_GAME_WIDTH * scale) / 2
    local offsetY = (screenHeight - Constants.VIRTUAL_GAME_HEIGHT * scale) / 2

    -- Ramène les coordonnées souris dans le repère virtuel
    local virtualX = (mouseX - offsetX) / scale
    local virtualY = (mouseY - offsetY) / scale

    -- Apply parallax offset if layer is specified
    if layer then
        local px, py = G.calculateParalaxeOffset(layer)
        virtualX = virtualX - px
        virtualY = virtualY - py
    end

    return virtualX, virtualY
end

function Inputs.getCanvasScale()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = math.min(screenWidth / Constants.VIRTUAL_GAME_WIDTH, screenHeight / Constants.VIRTUAL_GAME_HEIGHT)
    return scale
end

function Inputs.getMouseInCanvas(canvasX, canvasY, layer)
    local virtualX, virtualY = Inputs.getVirtualMousePosition(layer)
    return {x = virtualX - canvasX, y=virtualY - canvasY}
end

return Inputs