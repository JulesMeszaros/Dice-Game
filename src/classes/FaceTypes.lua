local FaceObject = require("src.classes.FaceObject")
local Constants = require("src.utils.Constants")
local CiggieTypes = require("src.classes.CiggieTypes")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")

local FaceTypes = {}

--==COMMON==--

--==WHITE FACE==--
local WhiteDice = setmetatable({}, { __index = FaceObject })
WhiteDice.__index = WhiteDice

function WhiteDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), WhiteDice)

    --Metadatas about the WhiteDice
    self.name = "White Face"
    self.id = 1
    self.tier = "Common"
    self.description = "Scoring : [[+10pts]]"

    --Metadatas about the graphics of the WhiteDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Base Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the WhiteDice in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = pointsValue --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function WhiteDice:triggerEffect(round)
    --Complementary effect triggered by the face
    addScore(round, self.pointsValue)
end

FaceTypes.WhiteDice = WhiteDice



--==CHUNKY DICE==--
local ChunkyDice = setmetatable({}, { __index = FaceObject })
ChunkyDice.__index = ChunkyDice

function ChunkyDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), ChunkyDice)

    --Metadatas about the ChunkyDice
    self.name = "Chunky Dice"
    self.id = 2
    self.tier = "Common"
    self.description = "Scoring : [[+20pts]]"

    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Chunky Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 20 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end


function ChunkyDice:triggerEffect(round)
    --Complementary effect triggered by the face
    addScore(round, self.pointsValue)
end

FaceTypes.ChunkyDice = ChunkyDice


--==MASSIVE DICE==--
local MassiveDice = setmetatable({}, { __index = FaceObject })
MassiveDice.__index = MassiveDice

function MassiveDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), MassiveDice)

    --Metadatas about the ChunkyDice
    self.name = "Massive Dice"
    self.id = 3
    self.tier = "Common"
    self.description = "Scoring : [[+50pts]]"

    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Massive Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 50 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end


function MassiveDice:triggerEffect(round)
    --Complementary effect triggered by the face
    addScore(round, self.pointsValue)
    
end

FaceTypes.MassiveDice = MassiveDice


--==BLUE FACE==--

local BlueDice = setmetatable({}, { __index = FaceObject })
BlueDice.__index = BlueDice

function BlueDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), BlueDice)

    --Metadatas about the BlackStar
    self.name = "Blue Dice"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "Scoring : [[+10pts]]. \n Passive : Adds [[2pts]] per used rerolls this building to its points value (currently : 0)"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Blue Dice.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

    
    
    --Round status
    self.faceValue = faceValue --Le numéro de face que le dé représente
    self.pointsValue = 1 --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function BlueDice:update(dt, run)
    self.pointsValue = 1+(2*run.usedRerolls)

end

function BlueDice:triggerEffect(round)
    addScore(round, self.pointsValue)
end

function BlueDice:getDescription(run)
    return "Scoring : [["..tostring(2*run.usedRerolls).."pts]]. \n Passive : Adds [[2pts]] per used rerolls this building to its points value)"
end

FaceTypes.BlueDice = BlueDice

--==GOLD FACE==--

local GoldDice = setmetatable({}, { __index = FaceObject })
GoldDice.__index = GoldDice

function GoldDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), GoldDice)

    --Metadatas about the BlackStar
    self.name = "Gold Face"
    self.tier = "Common"
    self.id = 2
    self.description = "[[+10pts]]. When triggered, adds 2€ to the balance"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Gold Dice.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

    
    
    --Round status
    self.faceValue = faceValue --Le numéro de face que le dé représente
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function GoldDice:triggerEffect(round)
    --Ajoute 1€ au solde banquaire
    addMoney(round, 2)
    addScore(round, self.pointsValue)
end

FaceTypes.GoldDice = GoldDice

--==DELUXE FACE==--

local DeluxeDice = setmetatable({}, { __index = FaceObject })
DeluxeDice.__index = DeluxeDice

function DeluxeDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), DeluxeDice)

    --Metadatas about the BlackStar
    self.name = "Deluxe Face"
    self.tier = "Common"
    self.id = 5
    self.description = "Scoring: This Face adds the Point Value of every other scoring Face to the Total Score."

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Deluxe Dice.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

    
    
    --Round status
    self.faceValue = faceValue --Le numéro de face que le dé représente
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function DeluxeDice:triggerEffect(round)    
    if(round.playedFigure == Constants.FIGURES.DELUXE)then
        local sumScore = 0
        for i,k in next,round.usedDices do
            sumScore = sumScore+k:getCurrentFaceObject().pointsValue
        end

        addScore(round, sumScore)

    end

    addScore(round, self.pointsValue)

end

FaceTypes.DeluxeDice = DeluxeDice

--==STRIKE OF LUCK==--
local StrikeOfLuck = setmetatable({}, { __index = FaceObject })
StrikeOfLuck.__index = StrikeOfLuck

function StrikeOfLuck:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), StrikeOfLuck)

    --Metadatas about the BlackStar
    self.name = "Strike Of Luck"
    self.tier = "Common"
    self.id = 5
    self.description = "Scoring : [[+10pts]], adds a random ciggie to the inventory"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Strike of Luck.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

    
    
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
    self.description = "Full Hand: Multiplies the total score by ((1,5))."

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Milk Dice.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

    
    
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
    self.description = "Scoring : Multiplies the hand score by ((2)). \n Ghost"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Apparition.png")
    self.spriteSheet:setFilter("linear", "linear")

    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

    
    
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
    self.description = "Scoring : [[+30pts]]\n Blank"

    --Metadatas about the graphics of the BlackStar
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Black Star.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)
    
    
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
    self.description = "Scoring : Adds [[20pts]] multiplied by this face's number to the score. Passive : decreases the face number by one the first time you score this Face in the Office."

    --Metadatas about the graphics of the ClockWorkDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Clockwork Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the ClockWorkDice in px (in the png)
    
    

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
    self.description = "Scoring : Multiplies the total score by ((1)). This factor is upgraded by ((0.1)) each time a cigarette is smoked"

    --Metadatas about the graphics of the AshtrayDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Ashtray Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the AshtrayDice in px (in the png)
    
    

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

function AshtrayDice:getDescription(run)
    return "Scoring : Multiplies the total score by (("..(1+(0.1)*run.totalUsedCiggie)..")). This factor is upgraded by ((0.1)) each time a cigarette is smoked"
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
    self.description = "Scoring : Adds [[10pts]] per € under 10€"

    --Metadatas about the graphics of the SteelDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Steel Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the SteelDice in px (in the png)
    
    

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

function SteelDice:getDescription(run)
    return "Scoring : Adds [[10pts]] per € under 10€ (currently : [["..(math.max(0, 10 - run.money)*10).."pts]])"
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
    self.description = "Scoring : Adds [[10pts]] per even dices in scored hand"

    --Metadatas about the graphics of the DoubleDown
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Double Down.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the DoubleDown in px (in the png)
    
    

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
    self.description = "Scoring : Adds [[10pts]] per odd dices in scored hand"

    --Metadatas about the graphics of the OddJob
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Odd Job.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the OddJob in px (in the png)
    
    

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
    self.description = "Scoring : [[+10pts]], multiplies the score by ((2)) if played hand contains exactly 4 dices"

    --Metadatas about the graphics of the MusicDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Tempo Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the MusicDice in px (in the png)
    
    

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
    self.description = "Unique : Multiplies the hand score by ((3)). Scoring: [[+10pts]]."

    --Metadatas about the graphics of the Signature
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Signature Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the Signature in px (in the png)
    
    
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
    
    
    self.backup=true
    self.backupScoreValue = 10
    self.description = "Backup : Adds [[10pts]] to the score. Value goes up by [[5]]. Currently : [["..tostring(self.backupScoreValue)..' pts]]'

    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function SniperDice:triggerEffect(round)
    --Complementary effect triggered by the face

end

function SniperDice:backupEffect(round)
    addScore(round, self.backupScoreValue)
    self.backupScoreValue = self.backupScoreValue + 5
end

function SniperDice:getDescription(run)
    return "Backup : Adds [["..self.backupScoreValue.."pts]] to the score. Value goes up by [[5pts]]"
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
    self.description = "First : Multiplies the hand score by ((2)). Scoring: [[+10pts]]"
    self.faceDimmension = 120 --sets the dimmensions for a face of the Spotlight in px (in the png)
    
    
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
    self.description = "Scoring : [[+100pts]], -10$."
    self.faceDimmension = 120 --sets the dimmensions for a face of the RiskyBusiness in px (in the png)
    
    
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
    self.name = "Crypto Dice"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the CryptoDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Crypto Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : Multiplies the hand score by ((2)), lowers the money to 0$"
    self.faceDimmension = 120 --sets the dimmensions for a face of the CryptoDice in px (in the png)
    
    
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
end

FaceTypes.CryptoDice = CryptoDice

--==Patience==--
local Patience = setmetatable({}, { __index = FaceObject })
Patience.__index = Patience

function Patience:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), Patience)

    --Metadatas about the Patience
    self.name = "Patience"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the Patience
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Patience.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : [[+10pts]], increase this value by [[5pts]]"
    self.faceDimmension = 120 --sets the dimmensions for a face of the Patience in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function Patience:triggerEffect(round)
    --Complementary effect triggered by the face
    addScore(round, self.pointsValue)
    upgradeStat(self, 'pointsValue', 5)
end

function Patience:getDescription(run)
    return "Scoring : [[+"..tostring(self.pointsValue).."pts]], increase this value by [[5pts]]"
end

FaceTypes.Patience = Patience

--==Data Dice==--
local DataDice = setmetatable({}, { __index = FaceObject })
DataDice.__index = DataDice

function DataDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), DataDice)

    --Metadatas about the DataDice
    self.name = "Data Dice"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the DataDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Number Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : [[+10pts]], increases by [[10pts]] if figure is a numbered figure (1, 2, 3,...) decreases by [[10pts]] if not."
    self.faceDimmension = 120 --sets the dimmensions for a face of the DataDice in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function DataDice:triggerEffect(round)
    --Complementary effect triggered by the face
    if round.playedFigure < 7 then
        upgradeStat(self, 'pointsValue', 10)
        print("upgrade")
    else
        if(self.pointsValue>=10)then
            upgradeStat(self, 'pointsValue', -10)
            print("downgrade")
        end
    end
    addScore(round, self.pointsValue)
end

function DataDice:getDescription(run)
    return "Scoring : [[+"..tostring(self.pointsValue).."pts]], increases by [[10pts]] if figure is a numbered figure, decreases by  if not."
end

FaceTypes.DataDice = DataDice

--==Stock Option==--
local StockOption = setmetatable({}, { __index = FaceObject })
StockOption.__index = StockOption

function StockOption:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), StockOption)

    --Metadatas about the StockOption
    self.name = "Stock Option"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the StockOption
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Stock Option.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : [[+10pts]], 1/2 Chances of giving 10$, or loosing 5$."
    self.faceDimmension = 120 --sets the dimmensions for a face of the StockOption in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function StockOption:triggerEffect(round)
    --Complementary effect triggered by the face
    
    local i = math.random(0, 1)

    if(i==0)then
        addMoney(round, 10)
    else
        removeMoney(round, 5)
    end

    addScore(round, self.pointsValue)
end

FaceTypes.StockOption = StockOption

--==Rainbow Dice==--
local RainbowDice = setmetatable({}, { __index = FaceObject })
RainbowDice.__index = RainbowDice

function RainbowDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), RainbowDice)

    --Metadatas about the RainbowDice
    self.name = "Rainbow Dice"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the RainbowDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Straight Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : [[+10pts]], goes up by 30pts if played in a small or large straight."
    self.faceDimmension = 120 --sets the dimmensions for a face of the RainbowDice in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function RainbowDice:triggerEffect(round)
    --Complementary effect triggered by the face
    
    if(round.playedFigure == Constants.FIGURES.SMALL_SUITE or round.playedFigure == Constants.LARGE_SUITE) then
        upgradeStat(self, 'pointsValue', 30)
        print('upgrade', round.playedFigure)
    end

    addScore(round, self.pointsValue)
end

function RainbowDice:getDescription(run)
    return "Scoring : [[+"..tostring(self.pointsValue).."pts]], goes up by 30pts if played in a small or large straight."
end

FaceTypes.RainbowDice = RainbowDice

--==Magic Dice==--
local MagicDice = setmetatable({}, { __index = FaceObject })
MagicDice.__index = MagicDice

function MagicDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), MagicDice)

    --Metadatas about the MagicDice
    self.name = "Magic Dice"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the MagicDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Magic Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : Multiplies the score by the ((number or magic wands held)), if the number is at least 2."
    self.faceDimmension = 120 --sets the dimmensions for a face of the MagicDice in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function MagicDice:triggerEffect(round)
    --Complementary effect triggered by the face
    
    if(table.getn(round.run.ciggiesObjects)>=2) then
        multiplyScore(round, table.getn(round.run.ciggiesObjects))
    end
end

FaceTypes.MagicDice = MagicDice

--==Return On Invenstment==--
local ReturnOnInvestment = setmetatable({}, { __index = FaceObject })
ReturnOnInvestment.__index = ReturnOnInvestment

function ReturnOnInvestment:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), ReturnOnInvestment)

    --Metadatas about the ReturnOnInvestment
    self.name = "Return On Invenstment"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the ReturnOnInvestment
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Return On Invenstment.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Backup : Multiplies the score by ((1.5)) for each 10$ in bank."
    self.faceDimmension = 120 --sets the dimmensions for a face of the ReturnOnInvestment in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    self.backup = true
    return self
end

function ReturnOnInvestment:backupEffect(round)
    local i = math.floor(round.run.money/10)
    local f = i*1.5
    if(f>0)then
        multiplyScore(round, f)
    end

end

function ReturnOnInvestment:getDescription(run)
    return "Backup : Multiplies the score by ((1.5)) for each 10$ in bank (currently : (("..tostring(math.floor(run.money/10)*1.5)..")))"
end

FaceTypes.ReturnOnInvestment = ReturnOnInvestment

--==Royalty Card==--
local RoyaltyCard = setmetatable({}, { __index = FaceObject })
RoyaltyCard.__index = RoyaltyCard

function RoyaltyCard:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), RoyaltyCard)

    --Metadatas about the RoyaltyCard
    self.name = "Royalty Card"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the RoyaltyCard
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Royalty Card.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : Gives the level of the played figure in $. [[+10pts]]"
    self.faceDimmension = 120 --sets the dimmensions for a face of the RoyaltyCard in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function RoyaltyCard:triggerEffect(round)
    local level = round.run.figuresInfos[round.playedFigure].level

    addMoney(round, level)
    addScore(round, self.pointsValue)
end

FaceTypes.RoyaltyCard = RoyaltyCard

--==Mirror Dice==--
local MirrorDice = setmetatable({}, { __index = FaceObject })
MirrorDice.__index = MirrorDice

function MirrorDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), MirrorDice)

    --Metadatas about the MirrorDice
    self.name = "Mirror Dice"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the MirrorDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Mirror Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : [[+10pts]], gains [[5pts]] by played dice with the same number as this one"
    self.faceDimmension = 120 --sets the dimmensions for a face of the MirrorDice in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function MirrorDice:triggerEffect(round)
    local sameDices = 0
    local sortedFaces, sortedDices = round:getDicesOrder(round.usedDices)
    
    --On récupère le nombre de dé avec le meme numéro de face
    for i,d in next, sortedFaces do
        if(d.representedObject.faceValue == self.faceValue) then sameDices = sameDices +1 end
    end
    print(sameDices)

    --On upgrade la pointsValue du dé
    upgradeStat(self, "pointsValue", (sameDices-1)*5)
    addScore(round, self.pointsValue)

end

function MirrorDice:getDescription(run)
    return "Scoring : [[+"..tostring(self.pointsValue).."pts]], gains [[5pts]] by played dice with the same number as this one"
end

FaceTypes.MirrorDice = MirrorDice

--==Lucky Cookie==--
local CookieDice = setmetatable({}, { __index = FaceObject })
CookieDice.__index = CookieDice

function CookieDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), CookieDice)

    --Metadatas about the CookieDice
    self.name = "Lucky Cookie"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the CookieDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Cookie Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Scoring : [[+10pts]], 1/3 chances of upgrading the played figure by one level"
    self.faceDimmension = 120 --sets the dimmensions for a face of the CookieDice in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function CookieDice:triggerEffect(round)
    local i = math.floor(math.random(1, 3))

    if(i==1) then
        round.run:levelUpFigure(round.playedFigure)
    end

    addScore(round, self.pointsValue)

end

FaceTypes.CookieDice = CookieDice

--==Insomniac Dice==--
local InsomniacDice = setmetatable({}, { __index = FaceObject })
InsomniacDice.__index = InsomniacDice

function InsomniacDice:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), InsomniacDice)

    --Metadatas about the InsomniacDice
    self.name = "Insomniac Dice"
    self.id = 1
    self.tier = "Common"

    --Metadatas about the graphics of the InsomniacDice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Eclipse Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = " "
    self.faceDimmension = 120 --sets the dimmensions for a face of the InsomniacDice in px (in the png)
    
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function InsomniacDice:triggerEffect(round)
    print(round.run.totalUsedCoffees)
    addScore(round, 10+(15*round.run.totalUsedCoffees))
end

function InsomniacDice:getDescription(run)
    return "Scoring : [[+"..tostring(10+(15*run.totalUsedCoffees)).."pts]], goes up by [[15pts]] for each coffee used in this building."
end

FaceTypes.InsomniacDice = InsomniacDice

--==Twin Flame==--
local TwinFlame = setmetatable({}, { __index = FaceObject })
TwinFlame.__index = TwinFlame

function TwinFlame:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), TwinFlame)

    --Metadatas about the TwinFlame
    self.name = "Twin Flame"
    self.id = 1
    self.tier = "Rare"

    --Metadatas about the graphics of the TwinFlame
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Twin Flame.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "[[+10pts]], clones a random magic wand in hand."
    self.faceDimmension = 120 --sets the dimmensions for a face of the TwinFlame in px (in the png)
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    return self
end

function TwinFlame:triggerEffect(round)
    addScore(round, self:getPointsValue(round.run))

    if(table.getn(round.run.ciggiesObjects)<Constants.BASE_MAX_CIGGIES and table.getn(round.run.ciggiesObjects)>0)then
        local randomCiggie = round.run.ciggiesObjects[math.random(1, #round.run.ciggiesObjects)]

        table.insert(round.run.ciggiesObjects, getmetatable(randomCiggie):new())
        round.terrain:generateCiggiesUI()
    end
end

FaceTypes.TwinFlame = TwinFlame

--==Fax Machine==--
local FaxMachine = setmetatable({}, { __index = FaceObject })
FaxMachine.__index = FaxMachine

function FaxMachine:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), FaxMachine)

    --Metadatas about the FaxMachine
    self.name = "Fax Machine"
    self.id = 1
    self.tier = "Rare"

    --Metadatas about the graphics of the FaxMachine
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Fax Machine.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = "Retriggers the first scored dice"
    self.faceDimmension = 120 --sets the dimmensions for a face of the FaxMachine in px (in the png)
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    
    self.blank = true
    return self
end

function FaxMachine:triggerEffect(round)
    local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)

    print(dicesOrder[1]:getCurrentFaceObject().faceValue)
    --On vérifie que le premier dé joué n'est pas celui-là
    if(dicesOrder[1] ~= self.diceObject)then
        table.insert(round.dicesTriggerQueue, 1, dicesOrder[1])
        table.insert(round.diceFacesTriggerQueue, 1, round.terrain.diceFaces[dicesOrder[1]])
    end
    
end

FaceTypes.FaxMachine = FaxMachine

--==Necromancer==--
local Necromancer = setmetatable({}, { __index = FaceObject })
Necromancer.__index = Necromancer

function Necromancer:new(faceValue, pointsValue)
    local self = setmetatable(FaceObject:new(), Necromancer)

    --Metadatas about the Necromancer
    self.name = "Necromancer Dice"
    self.id = 1
    self.tier = "Rare"

    --Metadatas about the graphics of the Necromancer
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Necromancer Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.description = " "
    self.faceDimmension = 120 --sets the dimmensions for a face of the Necromancer in px (in the png)
    
    --Numbered status
    self.faceValue = faceValue --This is the face represented by the face (the number shown)
    self.pointsValue = 10 --This is the points scored by the dice
    self.totalTriggered = 0
    
    return self
end

function Necromancer:triggerEffect(round)
    local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)

    addScore(round, self:getPointsValue(round.run))
    
end

function Necromancer:getPointsValue(run)
    return 50*run.totalDisabled
end

function Necromancer:getDescription(run)
    return "Scoring : [[+"..self:getPointsValue(run).."]]. Passive : Goes up by [[50pts]] each time a dice gets disabled"
end

FaceTypes.Necromancer = Necromancer





--UTILS--
function multiplyScore(round, f)
    round.handScore = round.handScore * f
end

function addScore(round, f)
    round.handScore = round.handScore + f
end

function addMoney(round, m)
    round.terrain:setMoneyTo(round.run.money + m)
end

function removeMoney(round, m)
    round.terrain:setMoneyTo(round.run.money - m)
end

function setMoney(round, m)
    round.run.money = 0
end

function upgradeStat(object, stat, v)
    object[stat] = object[stat] + v
end

return FaceTypes