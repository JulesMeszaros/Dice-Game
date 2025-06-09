local WhiteFace = require("src.classes.FaceTypes.WhiteFace")

local StaticFace = setmetatable({}, { __index = WhiteFace })
StaticFace.__index = StaticFace

function StaticFace:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), StaticFace)

    --Metadatas about the WhiteFace
    self.name = "Lucky Face"
    self.tier = "Common"
    self.id = 5
    self.description = "When triggered, adds its total number of triggers to the score"

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

function StaticFace:triggerEffect(round)
    round.roundScore = round.roundScore + self.totalTriggered
end

return StaticFace