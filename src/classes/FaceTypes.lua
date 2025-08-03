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
    addScore(round, self.pointsValue)
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
    addScore(round, self.pointsValue)
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
    addScore(round, self.pointsValue)
    
end

FaceTypes.MassiveFace = MassiveFace


--==BLUE FACE==--

local BlueFace = setmetatable({}, { __index = FaceObject })
BlueFace.__index = BlueFace

function BlueFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), BlueFace)

    --Metadatas about the BlackStar
    self.name = "Blue Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "Scoring : +10pts. \n Passive : Adds 2 points per used rerolls this building to its points value (currently : 0)"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Blue Dice.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

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
    self.pointsValue = 1+(2*run.usedRerolls)
    self.description = "Scoring : +10pts. \n Passive : Adds 2 point per used rerolls this building to its points value (currently : "..tostring(2*run.usedRerolls)..')'

end

function BlueFace:triggerEffect(round)
    addScore(round, self.pointsValue)
end

FaceTypes.BlueFace = BlueFace

--==GOLD FACE==--

local GoldFace = setmetatable({}, { __index = FaceObject })
GoldFace.__index = GoldFace

function GoldFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), GoldFace)

    --Metadatas about the BlackStar
    self.name = "Gold Face"
    self.tier = "Common"
    self.id = 2
    self.description = "+10pts. When triggered, adds 2€ to the balance"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Gold Dice.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

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

function GoldFace:triggerEffect(round)
    --Ajoute 1€ au solde banquaire
    addMoney(round, 2)
    addScore(round, self.pointsValue)
end

FaceTypes.GoldFace = GoldFace

--==DELUXE FACE==--

local DeluxeFace = setmetatable({}, { __index = FaceObject })
DeluxeFace.__index = DeluxeFace

function DeluxeFace:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), DeluxeFace)

    --Metadatas about the BlackStar
    self.name = "Deluxe Face"
    self.tier = "Common"
    self.id = 5
    self.description = "Scoring: This Face adds the Point Value of every other scoring Face to the Total Score."

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Deluxe Dice.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

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
    if(round.playedFigure == Constants.FIGURES.DELUXE)then
        local sumScore = 0
        for i,k in next,round.usedDices do
            sumScore = sumScore+k:getCurrentFaceObject().pointsValue
        end

        addScore(round, sumScore)

    end

    addScore(round, self.pointsValue)

end

FaceTypes.DeluxeFace = DeluxeFace

--==STRIKE OF LUCK==--
local StrikeOfLuck = setmetatable({}, { __index = FaceObject })
StrikeOfLuck.__index = StrikeOfLuck

function StrikeOfLuck:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), StrikeOfLuck)

    --Metadatas about the BlackStar
    self.name = "Strike Of Luck"
    self.tier = "Common"
    self.id = 5
    self.description = "Scoring: Adds a random ciggie to the inventory. \n +10pts"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Strike of Luck.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

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

    addScore(round, self.pointsValue)

end

FaceTypes.StrikeOfLuck = StrikeOfLuck

--==Copyprinter==--
local Copyprinter = setmetatable({}, { __index = FaceObject })
Copyprinter.__index = Copyprinter

function Copyprinter:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), Copyprinter)

    --Metadatas about the BlackStar
    self.name = "Copyprinter"
    self.tier = "Uncommon"
    self.id = 5
    self.description = "Scoring: Triggers the scoring dice to its left again. \n Blank"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Copyprinter.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    self.blank = true

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

end

FaceTypes.Copyprinter = Copyprinter

--==BasketOfEggs==--
local BasketOfEggs = setmetatable({}, { __index = FaceObject })
BasketOfEggs.__index = BasketOfEggs

function BasketOfEggs:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), BasketOfEggs)

    --Metadatas about the BlackStar
    self.name = "Basket Of Eggs"
    self.tier = "Uncommon"
    self.id = 5
    self.description = "Full Hand: Multiplies the total score by 1,5."

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Milk Dice.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

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
    addScore(round, self.pointsValue)
    
end

function BasketOfEggs:fullHandEffect(round)
    multiplyScore(round, 1.5)
end

FaceTypes.BasketOfEggs = BasketOfEggs

--==Apparition==--
local Apparition = setmetatable({}, { __index = FaceObject })
Apparition.__index = Apparition

function Apparition:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), Apparition)

    --Metadatas about the BlackStar
    self.name = "Apparition"
    self.tier = "Uncommon"
    self.id = 5
    self.description = "Scoring : Multiplies the hand score by 2. \n Ghost"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Apparition.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    self.ghost = true

    --Round status
    self.faceValue = faceValue --Le numéro de face que le dé représente
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function Apparition:triggerEffect(round)
    multiplyScore(round, 2)
end

FaceTypes.Apparition = Apparition

--==Black Star==--
local BlackStar = setmetatable({}, { __index = FaceObject })
BlackStar.__index = BlackStar

function BlackStar:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), BlackStar)

    --Metadatas about the BlackStar
    self.name = "Black Star"
    self.id = 1
    self.tier = "Common"
    self.description = "Scoring : +30pts \n Blank"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Black Star.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)
    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    self.blank = true

    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 30 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function BlackStar:triggerEffect(round)
    --Complementary effect triggered by the face
    addScore(round, self.pointsValue)
end

FaceTypes.BlackStar = BlackStar

--==Black Star==--
local ClockWorkDice = setmetatable({}, { __index = FaceObject })
ClockWorkDice.__index = ClockWorkDice

function ClockWorkDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), ClockWorkDice)

    --Metadatas about the ClockWorkDice
    self.name = "Clockwork Dice"
    self.id = 1
    self.tier = "Common"
    self.description = "Scoring : Adds 10pts multiplied by this face's number to the score. Passive : decreases the face number by one the first time you score this Face in the Office."

    --Metadatas about the graphics of the ClockWorkDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Clockwork Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the ClockWorkDice in px (in the png)
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

function ClockWorkDice:triggerEffect(round)
    --Complementary effect triggered by the face
    addScore(round, self.pointsValue * self.faceValue)

    if(self.faceValue>1 and self.roundTriggered<=1)then
        --Decrease the face value by one
        self.faceValue = self.faceValue - 1
        --Update the sprite
        round.terrain.diceFaces[self.diceObject]:updateSprite()
    end
end

FaceTypes.ClockWorkDice = ClockWorkDice

--==Ashtray Dice==--
local AshtrayDice = setmetatable({}, { __index = FaceObject })
AshtrayDice.__index = AshtrayDice

function AshtrayDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), AshtrayDice)

    --Metadatas about the AshtrayDice
    self.name = "Ashtray Dice"
    self.id = 1
    self.tier = "Common"
    self.description = "Scoring : Multiplies the total score by 1. This factor is upgraded by 0.1 each time a cigarette is smoked"

    --Metadatas about the graphics of the AshtrayDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Ashtray Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the AshtrayDice in px (in the png)
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
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function AshtrayDice:triggerEffect(round)
    --Complementary effect triggered by the face
    multiplyScore(round, (1+(0.1)*round.run.totalUsedCiggie))
end

FaceTypes.AshtrayDice = AshtrayDice

--==Steel Dice==--
local SteelDice = setmetatable({}, { __index = FaceObject })
SteelDice.__index = SteelDice

function SteelDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), SteelDice)

    --Metadatas about the SteelDice
    self.name = "Steel Dice"
    self.id = 1
    self.tier = "Common"
    self.description = "Scoring : Adds 10 points per € under 10€"

    --Metadatas about the graphics of the SteelDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Steel Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the SteelDice in px (in the png)
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
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function SteelDice:triggerEffect(round)
    --Complementary effect triggered by the face
    addScore(round, math.max(0, 10 - round.run.money)*10)
end

FaceTypes.SteelDice = SteelDice

--==Double Down==--
local DoubleDown = setmetatable({}, { __index = FaceObject })
DoubleDown.__index = DoubleDown

function DoubleDown:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), DoubleDown)

    --Metadatas about the DoubleDown
    self.name = "Double Down"
    self.id = 1
    self.tier = "Common"
    self.description = "Scoring : Adds 10 points per even dices in scored hand"

    --Metadatas about the graphics of the DoubleDown
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Double Down.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the DoubleDown in px (in the png)
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
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function DoubleDown:triggerEffect(round)
    --Complementary effect triggered by the face
    local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)

    local n = 0

    for i,dice in next,dicesOrder do
        if(dice:getCurrentFaceObject().faceValue%2 == 0)then
            n = n+1
        end
    end

    addScore(round, n*10)
end

FaceTypes.DoubleDown = DoubleDown

--==Odd Job==--
local OddJob = setmetatable({}, { __index = FaceObject })
OddJob.__index = OddJob

function OddJob:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), OddJob)

    --Metadatas about the OddJob
    self.name = "Odd Job"
    self.id = 1
    self.tier = "Common"
    self.description = "Scoring : Adds 10 points per odd dices in scored hand"

    --Metadatas about the graphics of the OddJob
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Odd Job.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the OddJob in px (in the png)
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
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function OddJob:triggerEffect(round)
    --Complementary effect triggered by the face
    local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)

    local n = 0

    for i,dice in next,dicesOrder do
        if(dice:getCurrentFaceObject().faceValue%2 > 0)then
            n = n+1
        end
    end

    addScore(round, n*10)

end

FaceTypes.OddJob = OddJob

--==Music Dice==--
local MusicDice = setmetatable({}, { __index = FaceObject })
MusicDice.__index = MusicDice

function MusicDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), MusicDice)

    --Metadatas about the MusicDice
    self.name = "Music Dice"
    self.id = 1
    self.tier = "Common"
    self.description = "Scoring : +10pts, multiplies the score by 2 if played hand contains exactly 4 dices"

    --Metadatas about the graphics of the MusicDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Tempo Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the MusicDice in px (in the png)
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
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function MusicDice:triggerEffect(round)
    --Complementary effect triggered by the face

    --Multiplie le score par deux si il y a exactement 4 dés sélectionnés
    if(table.getn(round.selectedDices) == 4) then
        multiplyScore(round, 2)
    end

    addScore(round, self.pointsValue)

end

FaceTypes.MusicDice = MusicDice

--==Signature==--
local Signature = setmetatable({}, { __index = FaceObject })
Signature.__index = Signature

function Signature:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), Signature)

    --Metadatas about the Signature
    self.name = "Signature"
    self.id = 1
    self.tier = "Common"
    self.description = "Unique : Multiplies the hand score by 3. Scoring: +10pts."

    --Metadatas about the graphics of the Signature
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Signature Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the Signature in px (in the png)
    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    self.unique=true

    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function Signature:triggerEffect(round)
    --Complementary effect triggered by the face

    addScore(round, self.pointsValue)

end

function Signature:uniqueEffect(round)
    multiplyScore(round, 3)
end

FaceTypes.Signature = Signature

--==Sniper Dice==--
local SniperDice = setmetatable({}, { __index = FaceObject })
SniperDice.__index = SniperDice

function SniperDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), SniperDice)

    --Metadatas about the SniperDice
    self.name = "SniperDice"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the SniperDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Crosshairs Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the SniperDice in px (in the png)
    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    self.backup=true
    self.backupScoreValue = 10
    self.description = "Backup : Adds 10 points to the score. Value goes up by 5. Currently : "..tostring(self.backupScoreValue)..' pts'

    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function SniperDice:update(dt, run)
    self.description = "Backup : Adds 10 points to the score. Value goes up by 5. Currently : "..tostring(self.backupScoreValue)..' pts'
end

function SniperDice:triggerEffect(round)
    --Complementary effect triggered by the face

end

function SniperDice:backupEffect(round)
    addScore(round, self.backupScoreValue)
    self.backupScoreValue = self.backupScoreValue + 5
end

FaceTypes.SniperDice = SniperDice

--==Spotlight==--
local Spotlight = setmetatable({}, { __index = FaceObject })
Spotlight.__index = Spotlight

function Spotlight:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), Spotlight)

    --Metadatas about the Spotlight
    self.name = "Spotlight"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the Spotlight
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Spotlight Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "First : Multiplies the hand score by 2. Scoring: +10pts"
    self.faceDimmension = 120 --sets the dimmensions for a face of the Spotlight in px (in the png)
    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    self.first=true

    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function Spotlight:triggerEffect(round)
    --Complementary effect triggered by the face
    addScore(round, self.pointsValue)
end

function Spotlight:firstEffect(round)
    multiplyScore(round, 2)
end

FaceTypes.Spotlight = Spotlight

--==RiskyBusiness==--
local RiskyBusiness = setmetatable({}, { __index = FaceObject })
RiskyBusiness.__index = RiskyBusiness

function RiskyBusiness:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), RiskyBusiness)

    --Metadatas about the RiskyBusiness
    self.name = "Risky Business"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the RiskyBusiness
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Risky Business.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : +100pts, -10$."
    self.faceDimmension = 120 --sets the dimmensions for a face of the RiskyBusiness in px (in the png)
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
    self.pointsValue = 100 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function RiskyBusiness:triggerEffect(round)
    --Complementary effect triggered by the face
    addScore(round, self.pointsValue)
    removeMoney(round, 10)
end

FaceTypes.RiskyBusiness = RiskyBusiness

--==CryptoDice==--
local CryptoDice = setmetatable({}, { __index = FaceObject })
CryptoDice.__index = CryptoDice

function CryptoDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), CryptoDice)

    --Metadatas about the CryptoDice
    self.name = "Risky Business"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the CryptoDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Crypto Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : +100pts, -10$."
    self.faceDimmension = 120 --sets the dimmensions for a face of the CryptoDice in px (in the png)
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
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function CryptoDice:triggerEffect(round)
    --Complementary effect triggered by the face
    multiplyScore(round, 2)
    if(round.run.money > 0)then
        setMoney(round, 0)
    end
    addScore(round, self.pointsValue)

end

FaceTypes.CryptoDice = CryptoDice

--UTILS--
function multiplyScore(round, f)
    round.handScore = round.handScore * f
end

function addScore(round, f)
    round.handScore = round.handScore + f
end

function addMoney(round, m)
    round.run.money = round.run.money + m
end

function removeMoney(round, m)
    round.run.money = round.run.money - m
end

function setMoney(round, m)
    round.run.money = 0
end

return FaceTypes