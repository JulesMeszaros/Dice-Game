local WhiteDice = require("src.classes.FaceTypes.WhiteDice")

local StoneFace = setmetatable({}, { __index = WhiteDice })
StoneFace.__index = StoneFace

function StoneFace:new(faceValue)
    local self = setmetatable(WhiteDice:new(), StoneFace)

    --Metadatas about the WhiteDice
    self.name = "Stone Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "When triggered, doubles the hand's points"

    --Metadatas about the graphics of the WhiteDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/StoneDiceTileset120.png")
    self.spriteSheet:setFilter("nearest", "nearest")

    self.faceDimmension = 120 --sets the dimmensions for a face of the WhiteDice in px (in the png)

    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    --Round status
    self.faceValue = faceValue --Le numéro de face que le dé représente

    return self
end


function StoneFace:triggerEffect()
    print("PharmaDice triggered")
end

return StoneFace