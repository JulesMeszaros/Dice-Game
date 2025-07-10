local FaceObject = require("src.classes.FaceObject")
local Constants = require("src.utils.Constants")
local CiggieTypes = require("src.classes.CiggieTypes")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")

local FaceTypes = {}

--==COMMON==--

--==WHITE FACE==--
local WhiteFace = setmetatable({}, { __index = FaceObject })
WhiteFace.__index = WhiteFace

function WhiteFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), WhiteFace)

    --Metadatas about the WhiteFace
    self.name = "White Face"
    self.id = 1
    self.tier = "Common"
    self.description = "Scoring : +10pts"

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

function WhiteFace:triggerEffect(round)
    --Complementary effect triggered by the face
    print("test")
    round.handScore = round.handScore + self.pointsValue
end

FaceTypes.WhiteFace = WhiteFace



--==CHUNKY DICE==--
local ChunkyFace = setmetatable({}, { __index = FaceObject })
ChunkyFace.__index = ChunkyFace

function ChunkyFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), ChunkyFace)

    --Metadatas about the ChunkyFace
    self.name = "Chunky Dice"
    self.id = 2
    self.tier = "Common"
    self.description = "Scoring : +20pts"

    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Chunky Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 
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
    self.pointsValue = 20 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end


function ChunkyFace:triggerEffect(round)
    --Complementary effect triggered by the face
    round.handScore = round.handScore + self.pointsValue
end

FaceTypes.ChunkyFace = ChunkyFace


--==MASSIVE DICE==--
local MassiveFace = setmetatable({}, { __index = FaceObject })
MassiveFace.__index = MassiveFace

function MassiveFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), MassiveFace)

    --Metadatas about the ChunkyFace
    self.name = "Massive Dice"
    self.id = 3
    self.tier = "Common"
    self.description = "Scoring : +50pts"

    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Massive Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 
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
    self.pointsValue = 50 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end


function MassiveFace:triggerEffect(round)
    --Complementary effect triggered by the face
    round.handScore = round.handScore + self.pointsValue
    
end

FaceTypes.MassiveFace = MassiveFace


--==BLUE FACE==--

local BlueFace = setmetatable({}, { __index = FaceObject })
BlueFace.__index = BlueFace

function BlueFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), BlueFace)

    --Metadatas about the WhiteFace
    self.name = "Blue Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "Scoring : Adds its points value. \n Passive : Adds 1 point per used rerolls this building to its points value (currently : 0)"

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
    self.pointsValue = 1+run.usedRerolls
    self.description = "Scoring : Adds its points value. \n Passive : Adds 1 point per used rerolls this building to its points value (currently : "..tostring(run.usedRerolls)..')'

end

function BlueFace:triggerEffect(round)
    round.handScore = round.handScore + self.pointsValue
end

FaceTypes.BlueFace = BlueFace

--==GOLD FACE==--

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

--==DELUXE FACE==--

local DeluxeFace = setmetatable({}, { __index = FaceObject })
DeluxeFace.__index = DeluxeFace

function DeluxeFace:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), DeluxeFace)

    --Metadatas about the WhiteFace
    self.name = "Deluxe Face"
    self.tier = "Common"
    self.id = 5
    self.description = "Scoring: This Face adds the Point Value of every other scoring Face to the Total Score."

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
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function DeluxeFace:triggerEffect(round)
    print("------")
    
    if(round.playedFigure == Constants.FIGURES.DELUXE)then
        local sumScore = 0
        for i,k in next,round.usedDices do
            sumScore = sumScore+k:getCurrentFaceObject().pointsValue
        end

        round.handScore = round.handScore + sumScore
    end

    round.handScore = round.handScore + self.pointsValue

end

FaceTypes.DeluxeFace = DeluxeFace

--==STRIKE OF LUCK==--
local StrikeOfLuck = setmetatable({}, { __index = FaceObject })
StrikeOfLuck.__index = StrikeOfLuck

function StrikeOfLuck:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), StrikeOfLuck)

    --Metadatas about the WhiteFace
    self.name = "Strike Of Luck"
    self.tier = "Common"
    self.id = 5
    self.description = "Scoring: Adds a random ciggie to the inventory. \n +10pts"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Strike of Luck.png")
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
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function StrikeOfLuck:triggerEffect(round)
    
    if(table.getn(round.run.ciggiesObjects)<Constants.BASE_MAX_CIGGIES)then
        local c = GenerateRandom.CiggieObject()
        table.insert(round.run.ciggiesObjects, c)
        round.terrain:generateCiggiesUI()
    end

    round.handScore = round.handScore + self.pointsValue

end

FaceTypes.StrikeOfLuck = StrikeOfLuck

--==Copyprinter==--
local Copyprinter = setmetatable({}, { __index = FaceObject })
Copyprinter.__index = Copyprinter

function Copyprinter:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), Copyprinter)

    --Metadatas about the WhiteFace
    self.name = "Copyprinter"
    self.tier = "Uncommon"
    self.id = 5
    self.description = "Scoring: Triggers the scoring dice to its left again."

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Copyprinter.png")
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
    self.pointsValue = 0 --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function Copyprinter:triggerEffect(round)
    
    local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)

    --Add to the
    local leftDice = nil

    --On parcoure un a un les dés, et on remplace au fur et a mesure leftDice, sauf si on atteint le dé concerné. 
    for i,dice in next,dicesOrder do
        --On vérifie si le dé actuel de la boucle n'est pas ce dé
        print(dice:getCurrentFaceObject().name)
        if(dice:getCurrentFaceObject() == self) then
            --Si oui on arrete
            break;
        end
        --On ajoute le dé à leftDice
        leftDice = dice
    end

    --S'il y a un dé à gauche, on l'ajoute au tout début de la queue de triggers
    if(leftDice)then
        table.insert(round.dicesTriggerQueue, 1, leftDice)
        table.insert(round.diceFacesTriggerQueue, 1, round.terrain.diceFaces[leftDice])
    end

    --print(round.selectedDices[1]:getCurrentFaceObject().name, round.selectedDices[1]:getCurrentFaceObject().faceValue)

end

FaceTypes.Copyprinter = Copyprinter

--==BasketOfEggs==--
local BasketOfEggs = setmetatable({}, { __index = FaceObject })
BasketOfEggs.__index = BasketOfEggs

function BasketOfEggs:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), BasketOfEggs)

    --Metadatas about the WhiteFace
    self.name = "Basket Of Eggs"
    self.tier = "Uncommon"
    self.id = 5
    self.description = "Full Hand: Multiplies the total score by 1,5."

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Milk Dice.png")
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
    
    self.fullHand = true

    --Round status
    self.faceValue = faceValue --Le numéro de face que le dé représente
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function BasketOfEggs:triggerEffect(round)
    round.handScore = round.handScore + self.pointsValue
    
end

function BasketOfEggs:fullHandEffect(round)
    round.handScore = round.handScore * 1.5
end

FaceTypes.BasketOfEggs = BasketOfEggs


return FaceTypes