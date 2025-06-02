
local Dice = {}
Dice.__index = Dice

function Dice:new()
    local self = setmetatable({}, Dice)

    --Metadatas about the dice
    self.name = "White Dice"
    self.id = 1
    self.description = "Ajoute la valeur de la face obtenue au score"

    --Metadatas about the graphics of the dice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/BaseDiceTileset.png")
    self.spriteSheet:setFilter("nearest", "nearest")

    self.faceDimmension = 64 --sets the dimmensions for a face of the dice in px

    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {1, 1}, -- 1
        {65, 1}, -- 2
        {65, 65}, -- 3
        {65, 193}, -- 4
        {65, 129}, -- 5
        {129, 0} -- 6
    }
    self.nFaces = table.getn(self.faceSpritesCoordinates)

    --Round status
    self.currentFace = nil --The face the dice was drawed on

    return self
end

function Dice:update()
    
end

--==DICE TRIGGER==--

function Dice:trigger(round)
    print("Dice triggered!!!!!....."..tostring(self.currentFace))
    self:triggerEffect(round)
end

function Dice:triggerEffect(round)
    round:addToScore(self.currentFace)
end

--==GET/SET FUNCTIONS==--

function Dice:setCurrentFace(f)
    self.currentFace = f
end

function Dice:getNbFaces()
    return self.nFaces
end

function Dice:getFace(x)
    return self.diceFaces[x]
end

function Dice:getSpriteSheet()
    return self.spriteSheet
end

function Dice:getQuad(i)
    quad = love.graphics.newQuad(
            self.faceSpritesCoordinates[i][1], self.faceSpritesCoordinates[i][2],     -- x, y dans l'image source
            200, 200,     -- largeur, hauteur de la portion
            self.spriteSheet:getDimensions()  -- taille totale de l'image
        )
    return quad
end

function Dice:getFaceDim()
    return self.faceDimmension
end

return Dice