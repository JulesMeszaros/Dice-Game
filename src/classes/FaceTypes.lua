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
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Base Dice-demo.png")
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

function WhiteFace:trigger(round)
    round.handScore = round.handScore + self.pointsValue
    self.totalTriggered = self.totalTriggered + 1
    self:triggerEffect(round)    
end

function WhiteFace:triggerEffect(round)
    --Complementary effect triggered by the face
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
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Red Dice-demo.png")
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

FaceTypes.RedFace = RedFace

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
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Blue Dice-demo.png")
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
    --On rettriger le dé précédement trigger, s'il n'est pas un blue face
    if(table.getn(round.triggerDiceHistory) > 1 and round.triggerDiceHistory[table.getn(round.triggerDiceHistory)-1].currentFaceObject.name ~= "Blue Face") then
        --[[ print(round.triggerDiceHistory[table.getn(round.triggerDiceHistory)-1].currentFaceObject.name)
        print(table.getn(round.triggerDiceHistory)) ]]
        table.insert(round.dicesTriggerQueue, 1, round.triggerDiceHistory[table.getn(round.triggerDiceHistory)-1])
        table.insert(round.diceFacesTriggerQueue, 1, round.triggerFaceHistory[table.getn(round.triggerFaceHistory)-1])
    end
end

FaceTypes.BlueFace = BlueFace

--==STONE FACE==--

local StoneFace = setmetatable({}, { __index = FaceObject })
StoneFace.__index = StoneFace

function StoneFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), StoneFace)

    --Metadatas about the WhiteFace
    self.name = "Gold Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "When triggered, adds 1€ to the balance"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Gold Dice-demo.png")
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
    print("test stone")
end

FaceTypes.StoneFace = StoneFace

--==STATIC FACE==--

local StaticFace = setmetatable({}, { __index = WhiteFace })
StaticFace.__index = StaticFace

function StaticFace:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), StaticFace)

    --Metadatas about the WhiteFace
    self.name = "Deluxe Face"
    self.tier = "Common"
    self.id = 5
    self.description = "When triggered, adds its total number of triggers to the score"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Deluxe Dice-demo.png")
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

function StaticFace:triggerEffect(round)
    round.handScore = round.handScore + self.totalTriggered
end

FaceTypes.StaticFace = StaticFace

return FaceTypes