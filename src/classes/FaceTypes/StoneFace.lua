local WhiteFace = require("src.classes.FaceTypes.WhiteFace")

local StoneFace = setmetatable({}, { __index = WhiteFace })
StoneFace.__index = StoneFace

function StoneFace:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), StoneFace)

    --Metadatas about the WhiteFace
    self.name = "Stone Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "When triggered, adds 1€ to the balance"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/StoneDiceTileset120.png")
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

function StoneFace:triggerEffect(round)
    --Ajoute 1€ au solde banquaire
    round.run.money = round.run.money + 1
end

return StoneFace