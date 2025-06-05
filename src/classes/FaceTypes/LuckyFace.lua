local WhiteDice = require("src.classes.FaceTypes.WhiteDice")

local LuckyFace = setmetatable({}, { __index = WhiteDice })
LuckyFace.__index = LuckyFace

function LuckyFace:new(faceValue)
    local self = setmetatable(WhiteDice:new(), LuckyFace)

    --Metadatas about the WhiteDice
    self.name = "Lucky Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "When triggered, adds the double of its face value to the hand's score"

    --Metadatas about the graphics of the WhiteDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/Dices/LuckyDiceTileset.png")
    self.spriteSheet:setFilter("nearest", "nearest")

    self.faceDimmension = 64 --sets the dimmensions for a face of the WhiteDice in px (in the png)

    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {1, 1}, -- 1
        {65, 1}, -- 2
        {65, 65}, -- 3
        {65, 193}, -- 4
        {65, 129}, -- 5
        {129, 0} -- 6
    }
    
    --Round status
    self.faceValue = faceValue --Le numéro de face que le dé représente

    return self
end


function LuckyFace:triggerEffect()
    print("PharmaDice triggered")
end

return LuckyFace