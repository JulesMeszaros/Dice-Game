local FaceObject = require("src.classes.FaceObject")
local FaceTypes = {}

--==WHITE FACE==--

local WhiteFace = setmetatable({}, { __index = FaceObject })
WhiteFace.__index = FaceObject

function WhiteFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), WhiteFace)

    --Metadatas about the WhiteFace
    self.name = "White Face"
    self.id = 1
    self.tier = "Common"
    self.description = "When triggered, adds its points value to the hand's score"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Base Dice.png")
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

FaceTypes.WhiteFace = WhiteFace

function WhiteFace:triggerEffect(round)
    --Complementary effect triggered by the face
    round.handScore = round.handScore + self.pointsValue
    return
end

--==RED FACE==--

local RedFace = setmetatable({}, { __index = FaceObject })
RedFace.__index = RedFace

function RedFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), RedFace)

    --Metadatas about the WhiteFace
    self.name = "Red Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "When triggered, adds the double of its points value to the hand's score"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Red Dice.png")
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

function RedFace:triggerEffect(round)
    round.handScore = round.handScore + 2*self.pointsValue
end

--FaceTypes.RedFace = RedFace

--==BLUE FACE==--

local BlueFace = setmetatable({}, { __index = FaceObject })
BlueFace.__index = BlueFace

function BlueFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), BlueFace)

    --Metadatas about the WhiteFace
    self.name = "Blue Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "Triggers the previously triggered dice again (doesn't work with other Blue Faces)"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Blue Dice.png")
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
    self.pointsValue = 1 --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function BlueFace:update(dt, run)
    self.pointsValue = run.usedRerolls
end

function BlueFace:triggerEffect(round)
    --On rettriger le dé précédement trigger, s'il n'est pas un blue face
    self.pointsValue = round.run.usedRerolls
    round.handScore = round.handScore + self.pointsValue
end

FaceTypes.BlueFace = BlueFace

--==STONE FACE==--

local GoldFace = setmetatable({}, { __index = FaceObject })
GoldFace.__index = GoldFace

function GoldFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), GoldFace)

    --Metadatas about the WhiteFace
    self.name = "Gold Face"
    self.tier = "Common"
    self.id = 2
    self.description = "When triggered, adds 2€ to the balance"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Gold Dice.png")
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

function GoldFace:triggerEffect(round)
    --Ajoute 1€ au solde banquaire
    round.run.money = round.run.money + 2
end

FaceTypes.GoldFace = GoldFace

--==STATIC FACE==--

local DeluxeFace = setmetatable({}, { __index = FaceObject })
DeluxeFace.__index = DeluxeFace

function DeluxeFace:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), DeluxeFace)

    --Metadatas about the WhiteFace
    self.name = "Deluxe Face"
    self.tier = "Common"
    self.id = 5
    self.description = "When triggered, adds its total number of triggers to the score"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Deluxe Dice.png")
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

function DeluxeFace:triggerEffect(round)
    round.handScore = round.handScore + self.totalTriggered
end

FaceTypes.DeluxeFace = DeluxeFace

return FaceTypes