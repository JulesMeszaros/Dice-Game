local WhiteFace = require("src.classes.FaceTypes.WhiteFace")

local LuckyFace = setmetatable({}, { __index = WhiteFace })
LuckyFace.__index = LuckyFace

function LuckyFace:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), LuckyFace)

    --Metadatas about the WhiteFace
    self.name = "Lucky Face"
    self.tier = "Common"
    self.id = 5
    self.description = "When triggered, ZBZBZHKLRHJKLRJRKLJDKLD"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/StaticDiceTileset120.png")
    self.spriteSheet:setFilter("nearest", "nearest")

    self.faceDimmension = 120 --sets the dimmensions for a face of the WhiteFace in px (in the png)

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
    self.pointsValue = pointsValue --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

return LuckyFace