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
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/Dices/BasicDice80.png")
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
    self.faceValue = faceValue --The face the WhiteDice was drawed on

    return self
end

function WhiteDice:triggerEffect()
    print("Dice triggered "..tostring(self.faceValue))
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

return WhiteDice