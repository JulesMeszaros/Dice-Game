--[[
    This class represents the basic white dice face.
    It is used as the default class for every dice faces, who inherits
    from this one.
]]

local FaceObject = {}
FaceObject.__index = FaceObject

function FaceObject:new()
    local self = setmetatable({}, FaceObject)

    --Metadatas about the FaceObject
    self.name = "FACE OBJECT"
    self.id = 0
    self.tier = "??"
    self.description = "???"

    --Metadatas about the graphics of the FaceObject
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Base Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the FaceObject in px (in the png)
    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    --Numbered status
    self.faceValue = 1 --This is the face represented by the face (the number shown)
    self.pointsValue = 0 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

--==Trigger functions==--

function FaceObject:update(dt, run)
    --print(self.name)

end

function FaceObject:trigger(round)
    self.totalTriggered = self.totalTriggered + 1
    self:triggerEffect(round)
end

function FaceObject:triggerEffect(round)
    --Complementary effect triggered by the face
    return
end

function FaceObject:getSpriteSheet()
    return self.spriteSheet
end

function FaceObject:getQuad(i)
    quad = love.graphics.newQuad(
            self.faceSpritesCoordinates[i][1], self.faceSpritesCoordinates[i][2],     -- x, y dans l'image source
            200, 200,     -- largeur, hauteur de la portion
            self.spriteSheet:getDimensions()  -- taille totale de l'image
        )
    return quad
end

function FaceObject:getFaceDim()
    return self.faceDimmension
end

function FaceObject:setDiceObject(diceObject)
    self.diceObject = diceObject
end

function FaceObject:setFacePoints(n)
    self.pointsValue = n
end

return FaceObject