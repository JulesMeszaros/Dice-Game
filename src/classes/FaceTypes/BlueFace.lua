local WhiteFace = require("src.classes.FaceTypes.WhiteFace")

local BlueFace = setmetatable({}, { __index = WhiteFace })
BlueFace.__index = BlueFace

function BlueFace:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), BlueFace)

    --Metadatas about the WhiteFace
    self.name = "Red Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "When triggered, adds the triple of its points value to the hand's score"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/BlueDiceTileset120.png")
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

function BlueFace:triggerEffect(round)
    round.roundScore = round.roundScore + 3*self.pointsValue
end

return BlueFace