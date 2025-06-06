local WhiteDice = require("src.classes.FaceTypes.WhiteDice")

local ReverseFace = setmetatable({}, { __index = WhiteDice })
ReverseFace.__index = ReverseFace

function ReverseFace:new(faceValue)
    local self = setmetatable(WhiteDice:new(), ReverseFace)

    --Metadatas about the WhiteDice
    self.name = "Reverse Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "When triggered, adds its face value to the hand's score. Triggers twice"

    --Metadatas about the graphics of the WhiteDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/ReverseDice80.png")
    self.spriteSheet:setFilter("nearest", "nearest")

    self.faceDimmension = 80 --sets the dimmensions for a face of the WhiteDice in px (in the png)

    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {80, 80}, -- 1
        {0, 80}, -- 2
        {80, 0}, -- 3
        {80, 160}, -- 4
        {160, 80}, -- 5
        {80, 240} -- 6
    }
    
    --Round status
    self.faceValue = faceValue --Le numéro de face que le dé représente

    return self
end


function ReverseFace:triggerEffect()
    print("PharmaDice triggered")
end

return ReverseFace