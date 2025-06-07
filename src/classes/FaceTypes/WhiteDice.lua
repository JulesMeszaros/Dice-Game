--[[
    This class represents the basic white dice face.
    It is used as the default class for every dice faces, who inherits
    from this one.
]]
local WhiteDice = {}
WhiteDice.__index = WhiteDice

function WhiteDice:new(faceValue)
    local self = setmetatable({}, WhiteDice)

    --Metadatas about the WhiteDice
    self.name = "White Face"
    self.id = 1
    self.tier = "Common"
    self.description = "When triggered, adds its face value to the hand's score"

    --Metadatas about the graphics of the WhiteDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/BaseDiceTileset120.png")
    self.spriteSheet:setFilter("linear", "linear")

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
    self.faceValue = faceValue --The face the WhiteDice was drawed on

    return self
end

function WhiteDice:triggerEffect(round)
    round.roundScore = round.roundScore + self.faceValue
end

function WhiteDice:getSpriteSheet()
    return self.spriteSheet
end

function WhiteDice:getQuad(i)
    quad = love.graphics.newQuad(
            self.faceSpritesCoordinates[i][1], self.faceSpritesCoordinates[i][2],     -- x, y dans l'image source
            200, 200,     -- largeur, hauteur de la portion
            self.spriteSheet:getDimensions()  -- taille totale de l'image
        )
    return quad
end

function WhiteDice:getFaceDim()
    return self.faceDimmension
end

function WhiteDice:setDiceObject(diceObject)
    self.diceObject = diceObject
end

return WhiteDice