--[[
    This class represents the basic white dice face.
    It is used as the default class for every dice faces, who inherits
    from this one.
]]
local WhiteFace = {}
WhiteFace.__index = WhiteFace

function WhiteFace:new(faceValue, pointsValue)
    local self = setmetatable({}, WhiteFace)

    --Metadatas about the WhiteFace
    self.name = "White Face"
    self.id = 1
    self.tier = "Common"
    self.description = "When triggered, adds its face value to the hand's score"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/BaseDiceTileset120.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the WhiteFace in px (in the png)
    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = pointsValue --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function WhiteFace:triggerEffect(round)
    round.roundScore = round.roundScore + self.pointsValue
    self.totalTriggered = self.totalTriggered + 1
    print(self.totalTriggered)
end

function WhiteFace:getSpriteSheet()
    return self.spriteSheet
end

function WhiteFace:getQuad(i)
    quad = love.graphics.newQuad(
            self.faceSpritesCoordinates[i][1], self.faceSpritesCoordinates[i][2],     -- x, y dans l'image source
            200, 200,     -- largeur, hauteur de la portion
            self.spriteSheet:getDimensions()  -- taille totale de l'image
        )
    return quad
end

function WhiteFace:getFaceDim()
    return self.faceDimmension
end

function WhiteFace:setDiceObject(diceObject)
    self.diceObject = diceObject
end

return WhiteFace