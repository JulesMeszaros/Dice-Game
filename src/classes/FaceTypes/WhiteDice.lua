local DiceFace = require("src.classes.ui.DiceFace")

local WhiteDice = {}
WhiteDice.__index = WhiteDice

function WhiteDice:new(faceNumber)
    local self = setmetatable({}, WhiteDice)

    --Metadatas about the WhiteDice
    self.name = "White Dice"
    self.id = 1
    self.description = "Ajoute la valeur de la face obtenue au score"

    --Metadatas about the graphics of the WhiteDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/Dices/BaseDiceTileset.png")
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
    self.faceNumber = faceNumber --The face the WhiteDice was drawed on

    return self
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