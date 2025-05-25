local DiceFace = require("src.classes.ui.DiceFace")

local Dice = { }
Dice.__index = Dice

function Dice:new()
    local self = setmetatable({}, Dice)
    
    --Metadatas about the dice
    self.name = "White Dice"

    --Metadatas about the graphics of the dice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/basic_dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    
    self.faceDimmension = 200 --sets the dimmensions for a face of the dice in px
    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {0, 0}, -- 1
        {200, 0}, -- 2
        {200, 200}, -- 3
        {200, 600}, -- 4
        {200, 400}, -- 5
        {400, 0} -- 6
    }
    self.nFaces = table.getn(self.faceSpritesCoordinates)

    --Create the UI elements of the faces

    self.diceFaces = {}

    for i=1,self.nFaces,1 do
        
        local quad = love.graphics.newQuad(
            self.faceSpritesCoordinates[i][1], self.faceSpritesCoordinates[i][2],     -- x, y dans l'image source
            200, 200,     -- largeur, hauteur de la portion
            self.spriteSheet:getDimensions()  -- taille totale de l'image
        )

        local face = DiceFace:new(self, i, self.spriteSheet, quad, self.faceDimmension)

        table.insert(self.diceFaces, face)
    end

    return self
end

function Dice:update()
    
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
    local quad = love.graphics.newQuad(
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