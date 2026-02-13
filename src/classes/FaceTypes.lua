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
	self.description = "[[+10pts]]"

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
	if Constants.OVERPOWER == true then
		addScore(round, 10000000000000000000000000000)
	end
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
	self.description = "[[+20pts]]"

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
	self.tier = "Uncommon"
	self.description = "[[+50pts]]"

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
	self.tier = "Common"
	self.id = 4

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

function BlueDice:triggerEffect(round)
	addScore(round, 2 * round.run.usedRerolls)
end

function BlueDice:getDescription(run)
	return "[[+2pts]] per used rerolls this building (currently : [[" .. tostring(2 * run.usedRerolls) .. "pts]] )."
end

FaceTypes.BlueDice = BlueDice

--==GOLD FACE==--

local GoldDice = setmetatable({}, { __index = FaceObject })
GoldDice.__index = GoldDice

function GoldDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), GoldDice)

	--Metadatas about the BlackStar
	self.name = "Gold Dice"
	self.tier = "Common"
	self.id = 5
	self.description = "[[+10pts]]. When triggered, adds 5€ to the balance"

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
	addMoney(round, 5)
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
	self.tier = "Uncommon"
	self.id = 6
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
	if round.playedFigure == Constants.FIGURES.DELUXE then
		local sumScore = 0
		for i, k in next, round.usedDices do
			sumScore = sumScore + k:getCurrentFaceObject().pointsValue
		end

		addScore(round, sumScore)
	end

	addScore(round, self.pointsValue)
end

--FaceTypes.DeluxeDice = DeluxeDice

--==STRIKE OF LUCK==--
local StrikeOfLuck = setmetatable({}, { __index = FaceObject })
StrikeOfLuck.__index = StrikeOfLuck

function StrikeOfLuck:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), StrikeOfLuck)

	--Metadatas about the BlackStar
	self.name = "Strike Of Luck"
	self.tier = "Common"
	self.id = 7
	self.description = "[[+10pts]], adds a random ciggie to the inventory"

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
	if table.getn(round.run.ciggiesObjects) < round.run.maxCiggies then
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
	self.tier = "Rare"
	self.id = 8
	self.description = "Triggers the scoring dice to its left again."

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
	for i, dice in next, dicesOrder do
		--On vérifie si le dé actuel de la boucle n'est pas ce dé
		if dice:getCurrentFaceObject() == self then
			--Si oui on arrete
			break
		end
		--On ajoute le dé à leftDice
		leftDice = dice
	end

	--S'il y a un dé à gauche, on l'ajoute au tout début de la queue de triggers
	if leftDice then
		table.insert(round.dicesTriggerQueue, 1, leftDice)
		table.insert(round.diceFacesTriggerQueue, 1, round.terrain.diceFaces[leftDice])
	end
end

FaceTypes.Copyprinter = Copyprinter

--==Apparition==--
local Apparition = setmetatable({}, { __index = FaceObject })
Apparition.__index = Apparition

function Apparition:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Apparition)

	--Metadatas about the BlackStar
	self.name = "Apparition"
	self.tier = "Uncommon"
	self.id = 10
	self.description = "Multiplies the hand score by ((2))."

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
	self.id = 11
	self.tier = "Common"
	self.description = "[[+30pts]]"

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

--==Clockwork Dice==--
local ClockWorkDice = setmetatable({}, { __index = FaceObject })
ClockWorkDice.__index = ClockWorkDice

function ClockWorkDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), ClockWorkDice)

	--Metadatas about the ClockWorkDice
	self.name = "Clockwork Dice"
	self.id = 12
	self.tier = "Common"
	self.description =
		"[[+20pts]] multiplied by this face's number. Decreases the face number by one the first time you score this Face in an Office."

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

	if self.faceValue > 1 and self.roundTriggered <= 1 then
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
	self.id = 13
	self.tier = "Common"
	self.description = "((x1)). This factor is upgraded by ((0.1)) each time a cigarette is smoked"

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
	multiplyScore(round, (1 + 0.1 * round.run.totalUsedCiggie))
end

function AshtrayDice:getDescription(run)
	return "x(("
		.. (1 + 0.1 * run.totalUsedCiggie)
		.. ")). This factor is upgraded by ((0.1)) each time a cigarette is smoked"
end

FaceTypes.AshtrayDice = AshtrayDice

--==Steel Dice==--
local SteelDice = setmetatable({}, { __index = FaceObject })
SteelDice.__index = SteelDice

function SteelDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), SteelDice)

	--Metadatas about the SteelDice
	self.name = "Steel Dice"
	self.id = 14
	self.tier = "Common"
	self.description = "Adds [[10pts]] per € under 10€"

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
	addScore(round, math.max(0, 10 - round.run.money) * 10)
end

function SteelDice:getDescription(run)
	return "[[+10pts]] for each $ under 10$ (currently : [[+" .. (math.max(0, 10 - run.money) * 10) .. "pts]])"
end

FaceTypes.SteelDice = SteelDice

--==Double Down==--
local DoubleDown = setmetatable({}, { __index = FaceObject })
DoubleDown.__index = DoubleDown

function DoubleDown:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), DoubleDown)

	--Metadatas about the DoubleDown
	self.name = "Double Down"
	self.id = 16
	self.tier = "Common"
	self.description = "[[+50pts]] per even dices in scored hand"

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

	for i, dice in next, dicesOrder do
		if dice:getCurrentFaceObject().faceValue % 2 == 0 then
			n = n + 1
		end
	end

	addScore(round, n * 50)
end

FaceTypes.DoubleDown = DoubleDown

--==Odd Job==--
local OddJob = setmetatable({}, { __index = FaceObject })
OddJob.__index = OddJob

function OddJob:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), OddJob)

	--Metadatas about the OddJob
	self.name = "Odd Job"
	self.id = 15
	self.tier = "Common"
	self.description = "[[+50pts]] per odd dices in scored hand"

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

	for i, dice in next, dicesOrder do
		if dice:getCurrentFaceObject().faceValue % 2 > 0 then
			n = n + 1
		end
	end

	addScore(round, n * 50)
end

FaceTypes.OddJob = OddJob

--==Music Dice==--
local MusicDice = setmetatable({}, { __index = FaceObject })
MusicDice.__index = MusicDice

function MusicDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), MusicDice)

	--Metadatas about the MusicDice
	self.name = "Music Dice"
	self.id = 17
	self.tier = "Common"
	self.description = "[[+10pts]], (X2)) if played hand contains exactly 4 dices"

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
	if table.getn(round.selectedDices) == 4 then
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
	self.id = 18
	self.tier = "Uncommon"
	self.description = "[[+10pts]]. Unique : ((X3))"

	--Metadatas about the graphics of the Signature
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Signature Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the Signature in px (in the png)

	self.unique = true

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
	self.id = 19
	self.tier = "Common"

	--Metadatas about the graphics of the SniperDice
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Crosshairs Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the SniperDice in px (in the png)

	self.backup = true
	self.backupScoreValue = 1.2

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
	multiplyScore(round, self.backupScoreValue)
	self.backupScoreValue = self.backupScoreValue + 0.2
end

function SniperDice:getDescription(run)
	return "Backup : ((X" .. self.backupScoreValue .. ")). Value goes up by ((0.2pts))"
end

FaceTypes.SniperDice = SniperDice

--==Spotlight==--
local Spotlight = setmetatable({}, { __index = FaceObject })
Spotlight.__index = Spotlight

function Spotlight:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Spotlight)

	--Metadatas about the Spotlight
	self.name = "Spotlight"
	self.id = 20
	self.tier = "Common"

	--Metadatas about the graphics of the Spotlight
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Spotlight Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.description = "First : ((X3)). Scoring: [[+10pts]]"
	self.faceDimmension = 120 --sets the dimmensions for a face of the Spotlight in px (in the png)

	self.first = true

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
	multiplyScore(round, 3)
end

FaceTypes.Spotlight = Spotlight

--==RiskyBusiness==--
local RiskyBusiness = setmetatable({}, { __index = FaceObject })
RiskyBusiness.__index = RiskyBusiness

function RiskyBusiness:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), RiskyBusiness)

	--Metadatas about the RiskyBusiness
	self.name = "Risky Business"
	self.id = 21
	self.tier = "Uncommon"

	--Metadatas about the graphics of the RiskyBusiness
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Risky Business.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.description = "[[+100pts]], -10$."
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
	removeMoney(round, 5)
end

FaceTypes.RiskyBusiness = RiskyBusiness

--==CryptoDice==--
local CryptoDice = setmetatable({}, { __index = FaceObject })
CryptoDice.__index = CryptoDice

function CryptoDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), CryptoDice)

	--Metadatas about the CryptoDice
	self.name = "Crypto Dice"
	self.id = 22
	self.tier = "Uncommon"

	--Metadatas about the graphics of the CryptoDice
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Crypto Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.description = "((x3)), lowers the money to 0$"
	self.faceDimmension = 120 --sets the dimmensions for a face of the CryptoDice in px (in the png)

	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0
	return self
end

function CryptoDice:triggerEffect(round)
	--Complementary effect triggered by the face
	multiplyScore(round, 3)
	if round.run.money > 0 then
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
	self.id = 23
	self.tier = "Common"

	--Metadatas about the graphics of the Patience
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Patience.png")
	self.spriteSheet:setFilter("linear", "linear")
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
	upgradeStat(self, "pointsValue", 30)
end

function Patience:getDescription(run)
	return "[[+" .. tostring(self.pointsValue) .. "pts]], this value is increased by [[30pts]] each time it's triggered"
end

FaceTypes.Patience = Patience

--==Data Dice==--
local DataDice = setmetatable({}, { __index = FaceObject })
DataDice.__index = DataDice

function DataDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), DataDice)

	--Metadatas about the DataDice
	self.name = "Data Dice"
	self.id = 24
	self.tier = "Common"

	--Metadatas about the graphics of the DataDice
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Number Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.description =
		"Scoring : [[+10pts]], increases by [[10pts]] if figure is a numbered figure (1, 2, 3,...) decreases by [[10pts]] if not."
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
		upgradeStat(self, "pointsValue", 10)
	else
		if self.pointsValue >= 10 then
			upgradeStat(self, "pointsValue", -10)
		end
	end
	addScore(round, self.pointsValue)
end

function DataDice:getDescription(run)
	return "[[+"
		.. tostring(self.pointsValue)
		.. "pts]], this value increases by [[10pts]] if the played figure is a numbered figure, decreases by [[10pts]] if not."
end

FaceTypes.DataDice = DataDice

--==Stock Option==--
local StockOption = setmetatable({}, { __index = FaceObject })
StockOption.__index = StockOption

function StockOption:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), StockOption)

	--Metadatas about the StockOption
	self.name = "Stock Option"
	self.id = 25
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

	if i == 0 then
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
	self.id = 26
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

	if round.playedFigure == Constants.FIGURES.SMALL_SUITE or round.playedFigure == Constants.LARGE_SUITE then
		upgradeStat(self, "pointsValue", 30)
		print("upgrade", round.playedFigure)
	end

	addScore(round, self.pointsValue)
end

function RainbowDice:getDescription(run)
	return "Scoring : [[+"
		.. tostring(self.pointsValue)
		.. "pts]], goes up by 30pts if played in a small or large straight."
end

FaceTypes.RainbowDice = RainbowDice

--==Magic Dice==--
local MagicDice = setmetatable({}, { __index = FaceObject })
MagicDice.__index = MagicDice

function MagicDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), MagicDice)

	--Metadatas about the MagicDice
	self.name = "Magic Dice"
	self.id = 27
	self.tier = "Rare"

	--Metadatas about the graphics of the MagicDice
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Magic Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.description =
		"Scoring : Multiplies the score by the ((number or magic wands held)), if the number is at least 2."
	self.faceDimmension = 120 --sets the dimmensions for a face of the MagicDice in px (in the png)

	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0
	return self
end

function MagicDice:triggerEffect(round)
	--Complementary effect triggered by the face

	if table.getn(round.run.ciggiesObjects) >= 2 then
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
	self.id = 28
	self.tier = "Uncommon"

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
	local i = math.floor(round.run.money / 10)
	local f = i * 1.5
	if f > 0 then
		multiplyScore(round, f)
	end
end

function ReturnOnInvestment:getDescription(run)
	return "Backup : Multiplies the score by ((1.5)) for each 10$ in bank (currently : (("
		.. tostring(math.floor(run.money / 10) * 1.5)
		.. ")))"
end

FaceTypes.ReturnOnInvestment = ReturnOnInvestment

--==Loyalty Card==--
local LoyaltyCard = setmetatable({}, { __index = FaceObject })
LoyaltyCard.__index = LoyaltyCard

function LoyaltyCard:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), LoyaltyCard)

	--Metadatas about the LoyaltyCard
	self.name = "Loyalty Card"
	self.id = 29
	self.tier = "Common"

	--Metadatas about the graphics of the LoyaltyCard
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Royalty Card.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.description = "Scoring : Gives the level of the played figure in $. [[+10pts]]"
	self.faceDimmension = 120 --sets the dimmensions for a face of the LoyaltyCard in px (in the png)

	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0
	return self
end

function LoyaltyCard:triggerEffect(round)
	local level = round.run.figuresInfos[round.playedFigure].level

	addMoney(round, level)
	addScore(round, self.pointsValue)
end

FaceTypes.LoyaltyCard = LoyaltyCard

--==Mirror Dice==--
local MirrorDice = setmetatable({}, { __index = FaceObject })
MirrorDice.__index = MirrorDice

function MirrorDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), MirrorDice)

	--Metadatas about the MirrorDice
	self.name = "Mirror Dice"
	self.id = 30
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
	for i, d in next, sortedFaces do
		if d.representedObject.faceValue == self.faceValue then
			sameDices = sameDices + 1
		end
	end

	--On upgrade la pointsValue du dé
	upgradeStat(self, "pointsValue", (sameDices - 1) * 5)
	addScore(round, self.pointsValue)
end

function MirrorDice:getDescription(run)
	return "Scoring : [[+"
		.. tostring(self.pointsValue)
		.. "pts]], gains [[5pts]] by played dice with the same number as this one"
end

FaceTypes.MirrorDice = MirrorDice

--==Lucky Cookie==--
local CookieDice = setmetatable({}, { __index = FaceObject })
CookieDice.__index = CookieDice

function CookieDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), CookieDice)

	--Metadatas about the CookieDice
	self.name = "Lucky Cookie"
	self.id = 31
	self.tier = "Uncommon"

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

	if i == 1 then
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
	self.id = 32
	self.tier = "Uncommon"

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
	addScore(round, 10 + (15 * round.run.totalUsedCoffees))
end

function InsomniacDice:getDescription(run)
	return "Scoring : [[+"
		.. tostring(10 + (10 * run.totalUsedCoffees))
		.. "pts]], goes up by [[15pts]] for each coffee used in this building."
end

FaceTypes.InsomniacDice = InsomniacDice

--==Twin Flame==--
local TwinFlame = setmetatable({}, { __index = FaceObject })
TwinFlame.__index = TwinFlame

function TwinFlame:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), TwinFlame)

	--Metadatas about the TwinFlame
	self.name = "Twin Flame"
	self.id = 33
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

	if table.getn(round.run.ciggiesObjects) < round.run.maxCiggies and table.getn(round.run.ciggiesObjects) > 0 then
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
	self.id = 34
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

	--On vérifie que le premier dé joué n'est pas celui-là
	if dicesOrder[1] ~= self.diceObject then
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
	self.id = 35
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
	return 50 * run.totalDisabled
end

function Necromancer:getDescription(run)
	return "Scoring : [[+"
		.. self:getPointsValue(run)
		.. "]]. Passive : Goes up by [[50pts]] each time a dice gets disabled"
end

FaceTypes.Necromancer = Necromancer

--==SixthSense==--
local SixthSense = setmetatable({}, { __index = FaceObject })
SixthSense.__index = SixthSense

function SixthSense:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), SixthSense)

	--Metadatas about the SixthSense
	self.name = "Sixth Sense"
	self.id = 36
	self.tier = "Uncommon"

	--Metadatas about the graphics of the SixthSense
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Ghost Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the SixthSense in px (in the png)

	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function SixthSense:triggerEffect(round)
	addScore(round, self:getPointsValue(round.run))
end

function SixthSense:getDescription(run)
	--Get the current number of disabled dices
	local i = 0

	for _, dice in next, run.diceObjects do
		for j, face in next, dice:getAllFaces() do
			if face.disabled == true then
				i = i + 1
			end
		end
	end

	return "Scoring : [[+"
		.. tostring(self:getPointsValue(run))
		.. "pts]]. Passive : Goes up by [[30pts]] for each dice face in deck currently disabled. (currently : "
		.. tostring(i)
		.. ")"
end

function SixthSense:getPointsValue(run)
	--Get the current number of disabled dices
	local i = 0

	for _, dice in next, run.diceObjects do
		for j, face in next, dice:getAllFaces() do
			if face.disabled == true then
				i = i + 1
			end
		end
	end

	return i * 30
end

FaceTypes.SixthSense = SixthSense

--==Sacrifice==--
local Sacrifice = setmetatable({}, { __index = FaceObject })
Sacrifice.__index = Sacrifice

function Sacrifice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Sacrifice)

	--Metadatas about the Sacrifice
	self.name = "Sacrifice"
	self.id = 37
	self.tier = "Rare"

	--Metadatas about the graphics of the Sacrifice
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Marble Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the Sacrifice in px (in the png)

	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 0 --This is the points scored by the dice
	self.totalTriggered = 0

	self.backup = true

	return self
end

function Sacrifice:triggerEffect(round)
	local i = 0
	for n, dice in next, round.run.diceObjects do
		if dice:getCurrentFaceObject() and dice:getCurrentFaceObject().ghost == true then
			i = i + 1
		end
	end

	multiplyScore(round, 1 + (i * 1.5))
end

function Sacrifice:backupEffect(round)
	local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)

	dicesOrder[1]:getCurrentFaceObject().ghost = true
end

function Sacrifice:getDescription(run)
	return "Scoring : Multiplies the score by ((1.5)) for each Ghost dice in hand or on the play mat. Backup : Adds Ghost effect to leftmost scored dice."
end

FaceTypes.Sacrifice = Sacrifice

--==CheckeredDice==--
local CheckeredDice = setmetatable({}, { __index = FaceObject })
CheckeredDice.__index = CheckeredDice

function CheckeredDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), CheckeredDice)

	--Metadatas about the CheckeredDice
	self.name = "Checkered Dice"
	self.id = 38
	self.tier = "Common"

	--Metadatas about the graphics of the CheckeredDice
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Checkered Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the CheckeredDice in px (in the png)
	self.description = "Scoring : +100pts if the played figure has exactly one remaining hand left."
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function CheckeredDice:triggerEffect(round)
	addScore(round, self:getPointsValue(run))
	if round.run.availableFigures[round.playedFigure] == 0 then
		addScore(round, 100)
	end
end

FaceTypes.CheckeredDice = CheckeredDice

--==Star Dice==--
local StarDice = setmetatable({}, { __index = FaceObject })
StarDice.__index = StarDice

function StarDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), StarDice)

	--Metadatas about the StarDice
	self.name = "Star Dice"
	self.id = 39
	self.tier = "Rare"

	--Metadatas about the graphics of the StarDice
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Star Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the StarDice in px (in the png)
	self.description = "Scoring : [[+20pts]]. Can be counted as any number for numbered figures."
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 20 --This is the points scored by the dice
	self.totalTriggered = 0

	self.blank = true

	return self
end

function StarDice:triggerEffect(round)
	addScore(round, self:getPointsValue(run))
end

FaceTypes.StarDice = StarDice

--==Resurection==--
local Resurection = setmetatable({}, { __index = FaceObject })
Resurection.__index = Resurection

function Resurection:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Resurection)

	--Metadatas about the Resurection
	self.name = "Resurection"
	self.id = 40
	self.tier = "Rare"

	--Metadatas about the graphics of the Resurection
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Resurection.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the Resurection in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.first = true

	return self
end

function Resurection:triggerEffect(round)
	addScore(round, self:getPointsValue(run))
end

function Resurection:firstEffect(round)
	for _, dice in next, round.run.diceObjects do
		dice:getCurrentFaceObject().disabled = false
		dice:getCurrentFaceObject().wasJustReenabled = true
	end
end

function Resurection:getDescription(run)
	return "Scoring : [[+"
		.. self:getPointsValue(run)
		.. "]]. First : reenables every disabled dice face in the play mat."
end

FaceTypes.Resurection = Resurection

--==Adrenaline==--
local Adrenaline = setmetatable({}, { __index = FaceObject })
Adrenaline.__index = Adrenaline

function Adrenaline:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Adrenaline)

	--Metadatas about the Resurection
	self.name = "Adrenaline"
	self.id = 41
	self.tier = "Common"

	--Metadatas about the graphics of the Adrenaline
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Adrenaline.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the Resurection in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function Adrenaline:triggerEffect(round)
	addScore(round, self:getPointsValue(run))
	if round.remainingHands <= 1 then
		multiplyScore(round, 3)
	end
end

function Adrenaline:getDescription(run)
	return "Scoring : [[+" .. self:getPointsValue(run) .. "]]. If this is the last turn, ((x3))."
end

FaceTypes.Adrenaline = Adrenaline

--==NegativeDice==--
local NegativeDice = setmetatable({}, { __index = FaceObject })
NegativeDice.__index = NegativeDice

function NegativeDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), NegativeDice)

	--Metadatas about the Resurection
	self.name = "Negative Dice"
	self.id = 42
	self.tier = "Uncommon"

	--Metadatas about the graphics of the NegativeDice
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Negative Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the NegativeDice in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function NegativeDice:triggerEffect(round)
	local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)

	local i = 5
	for _, face in next, facesOrder do
		if face.representedObject.name ~= "Negative Dice" then
			i = i - 1
		end
	end

	multiplyScore(round, math.max(1, i))
end

function NegativeDice:getDescription(run)
	return "Scoring : Multiplies the hand score for each empty space in played hand"
end

FaceTypes.NegativeDice = NegativeDice

--==BountyHunter==--
local BountyHunter = setmetatable({}, { __index = FaceObject })
BountyHunter.__index = BountyHunter

function BountyHunter:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), BountyHunter)

	--Metadatas about the Resurection
	self.name = "BountyHunter"
	self.id = 43
	self.tier = "Uncommon"

	--Metadatas about the graphics of the BountyHunter
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Bounty Hunter Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the BountyHunter in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function BountyHunter:triggerEffect(round)
	addScore(round, self:getPointsValue(run))

	if round.playedFigure <= 6 then
		if round.playedFigure <= 6 then
			addMoney(round, 5)
		end
	else
		if round.playedFigure == round.bountyHunterFigure then
			addMoney(round, 5)
		end
	end
end

function BountyHunter:getDescription(run)
	if run.currentState == Constants.RUN_STATES.ROUND then
		return "Scoring : Adds 5$ if scored in a "
			.. Constants.FIGURES_LABELS[run.currentRound.bountyHunterFigure]
			.. "."
	else
		return "Scoring : Adds 5$ if scored in a selected figure (selected figure changes each hand)"
	end
end

FaceTypes.BountyHunter = BountyHunter
--
--==Upcycling==--
local Upcycling = setmetatable({}, { __index = FaceObject })
Upcycling.__index = Upcycling

function Upcycling:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Upcycling)

	--Metadatas about the Resurection
	self.name = "Upcycling"
	self.id = 44
	self.tier = "Uncommon"

	--Metadatas about the graphics of the Upcycling
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Upcycling Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the Upcycling in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function Upcycling:triggerEffect(round)
	addScore(round, 50 * round.availableRerolls)
end

function Upcycling:getDescription(run)
	return "Adds [[50pts]] per remaining reroll."
end

FaceTypes.Upcycling = Upcycling

--==Ectoplasm==--
local Ectoplasm = setmetatable({}, { __index = FaceObject })
Ectoplasm.__index = Ectoplasm

function Ectoplasm:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Ectoplasm)

	--Metadatas about the Resurection
	self.name = "Ectoplasm"
	self.id = 45
	self.tier = "Uncommon"

	--Metadatas about the graphics of the Ectoplasm
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Ectoplasm.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the Ectoplasm in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.ghost = true

	return self
end

function Ectoplasm:triggerEffect(round)
	addScore(round, 200)
end

function Ectoplasm:getDescription(run)
	return "((+200pts))"
end

FaceTypes.Ectoplasm = Ectoplasm

--==Die And Retry==--
local DieAndRetry = setmetatable({}, { __index = FaceObject })
DieAndRetry.__index = DieAndRetry

function DieAndRetry:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), DieAndRetry)

	--Metadatas about the Resurection
	self.name = "Die And Retry"
	self.id = 46
	self.tier = "Uncommon"

	--Metadatas about the graphics of the UndeadDice
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Die And Retry.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the UndeadDice in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.ghost = true

	return self
end

function DieAndRetry:triggerEffect(round)
	multiplyScore(round, math.max(1, 2 * self.totaldisabled))
end

function DieAndRetry:getDescription(run)
	return "Scoring : Multiplies the hand by ((2)), multiplied by the number of times this dice was disabled (currently : ((x"
		.. math.max(1, 2 * self.totaldisabled)
		.. "))"
end

FaceTypes.DieAndRetry = DieAndRetry

--==InvisibleHand==--
local InvisibleHand = setmetatable({}, { __index = FaceObject })
InvisibleHand.__index = InvisibleHand

function InvisibleHand:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), InvisibleHand)

	--Metadatas about the Resurection
	self.name = "Invisible Hand"
	self.id = 47
	self.tier = "Uncommon"

	--Metadatas about the graphics of the InvisibleHand
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Invisible Hand Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the InvisibleHand in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function InvisibleHand:triggerEffect(round)
	addScore(round, round.run.totalspent)
end

function InvisibleHand:getDescription(run)
	return "Adds [[+1pts]] per 1$ spent this building (currently : [[" .. tostring(run.totalspent) .. "]])"
end

FaceTypes.InvisibleHand = InvisibleHand
--Undead Dice--
local UndeadDice = setmetatable({}, { __index = FaceObject })

UndeadDice.__index = UndeadDice
function UndeadDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), UndeadDice)

	--Metadatas about the Resurection
	self.name = "Undead Dice"
	self.id = 48
	self.tier = "Uncommon"

	--Metadatas about the graphics of the
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Undead Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the UndeadDice in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function UndeadDice:triggerEffect(round)
	local i = 0
	for _, dice in next, round.run.diceObjects do
		for __, face in next, dice:getAllFaces() do
			if face.disabled == true then
				i = i + 1
			end
		end
	end
	multiplyScore(round, math.max(1, 2 * i))
end

function UndeadDice:getDescription(run)
	local i = 0
	for _, dice in next, run.diceObjects do
		for __, face in next, dice:getAllFaces() do
			if face.disabled == true then
				i = i + 1
			end
		end
	end

	return "Scoring : Multiplies the hand by ((2)), multiplied by the current number of disabled dices in deck (currently : (("
		.. math.max(1, 2 * i)
		.. "))"
end

FaceTypes.UndeadDice = UndeadDice

--All In--
local AllIn = setmetatable({}, { __index = FaceObject })

AllIn.__index = AllIn
function AllIn:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), AllIn)

	--Metadatas about the Resurection
	self.name = "All In"
	self.id = 49
	self.tier = "Uncommon"

	--Metadatas about the graphics of the
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/All In.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the AllIn in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function AllIn:triggerEffect(round)
	local i = round.run.availableFigures[round.playedFigure] + 1
	round.run.availableFigures[round.playedFigure] = 0
	multiplyScore(round, math.max(1, 2 * i))
end

function AllIn:getDescription(run)
	return "Every Figure Use of the played Figure is spent. ((X2)) for each spent Figure Use."
end

FaceTypes.AllIn = AllIn

--All In--
local Poltergeist = setmetatable({}, { __index = FaceObject })

Poltergeist.__index = Poltergeist
function Poltergeist:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Poltergeist)

	--Metadatas about the Resurection
	self.name = "Poltergeist"
	self.id = 50
	self.tier = "Uncommon"

	--Metadatas about the graphics of the
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Poltergeist.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the Poltergeist in px (in the png)
	--Numbered status
	self.faceValue = faceValue --This is the face represented by the face (the number shown)
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0
	self.description = "Scoring : [[+20pts]]. Refunds the figure use."

	self.ghost = true

	return self
end

function Poltergeist:triggerEffect(round)
	addScore(round, 20)
	if round.handRefunded == false then
		round.handRefunded = true
		round.run.availableFigures[round.playedFigure] = round.run.availableFigures[round.playedFigure] + 1
	end
end

FaceTypes.Poltergeist = Poltergeist

--==Fortune Dice==--
local FortuneDice = setmetatable({}, { __index = FaceObject })
FortuneDice.__index = FortuneDice

function FortuneDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), FortuneDice)

	--Metadatas about the BlackStar
	self.name = "Fortune Dice"
	self.tier = "Rare"
	self.id = 51
	self.description = "Scoring : Adds a Fortune Magic Wand to the inventory"

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Fortune Dice.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.blank = true

	return self
end

function FortuneDice:triggerEffect(round)
	if table.getn(round.run.ciggiesObjects) < round.run.maxCiggies then
		local c = CiggieTypes.Fortune:new()
		table.insert(round.run.ciggiesObjects, c)
		round.terrain:generateCiggiesUI()
	end

	multiplyScore(round, math.max(1, 1.5 * math.floor(round.run.money / 10)))

	addScore(round, self.pointsValue)
end

function FortuneDice:getDescription(run)
	return "Adds a Fortune Magic Wand to inventory. Adds ((X0.5)) for each 10$ in bank (currently : ((X"
		.. tostring(math.max(1, 1.5 * math.floor(run.money / 10)))
		.. ")))"
end
--==Dime Dice==--
local DimeDice = setmetatable({}, { __index = FaceObject })
DimeDice.__index = DimeDice

function DimeDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), DimeDice)

	--Metadatas about the BlackStar
	self.name = "Dime Dice"
	self.tier = "Common"
	self.id = 53
	self.description = "Scoring : [[+10pts]], +2$ per played dice with the same number as this one."

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Dime Dice.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function DimeDice:triggerEffect(round)
	local i = 0

	for _, dice in next, round.selectedDices do
		if dice:getCurrentFaceObject().faceValue == self.faceValue then
			i = i + 1
		end
	end
	addMoney(round, i * 2)
	addScore(round, self.pointsValue)
end

FaceTypes.DimeDice = DimeDice
FaceTypes.FortuneDice = FortuneDice

--==Capitalist Dice==--
local CapitalistDice = setmetatable({}, { __index = FaceObject })
CapitalistDice.__index = CapitalistDice

function CapitalistDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), CapitalistDice)

	--Metadatas about the BlackStar
	self.name = "Capitalist Dice"
	self.tier = "Uncommon"
	self.id = 53

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Capitalist Dice.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function CapitalistDice:triggerEffect(round)
	local m = math.floor(round.run.money * 2)
	addScore(round, m)
end

function CapitalistDice:getDescription(run)
	return "Scoring : [[+2pts]] par $ in bank (currently : [[+" .. tostring(math.floor(run.money * 2)) .. "pts]])"
end

FaceTypes.CapitalistDice = CapitalistDice

--==Lucky Star==--
local LuckyStar = setmetatable({}, { __index = FaceObject })
LuckyStar.__index = LuckyStar

function LuckyStar:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), LuckyStar)

	--Metadatas about the BlackStar
	self.name = "Lucky Star"
	self.tier = "Common"
	self.id = 54

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Lucky Star.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.description = "Scoring : [[+10pts]], ((x3)) if played hand is a Chance"
	self.blank = true
	return self
end

function LuckyStar:triggerEffect(round)
	addScore(round, 10)
	if round.playedFigure == Constants.FIGURES.CHANCE then
		multiplyScore(round, 3)
	end
end

FaceTypes.LuckyStar = LuckyStar

--==Lucky Star==--
local Doom = setmetatable({}, { __index = FaceObject })
Doom.__index = Doom

function Doom:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Doom)

	--Metadatas about the BlackStar
	self.name = "Doom"
	self.tier = "Uncommon"
	self.id = 55

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Doom Dice.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.description = "Scoring : [[+100pts]], Backup : ((x3))."

	self.backup = true
	self.ghost = true

	return self
end

function Doom:triggerEffect(round)
	addScore(round, 100)
end

function Doom:backupEffect(round)
	multiplyScore(round, 3)
end

FaceTypes.Doom = Doom

--==Godspeed==--
local Godspeed = setmetatable({}, { __index = FaceObject })
Godspeed.__index = Godspeed

function Godspeed:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Godspeed)

	--Metadatas about the BlackStar
	self.name = "Godspeed"
	self.tier = "Rare"
	self.id = 56

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Godspeed.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.description = "Scoring : [[+100pts]], Backup : ((x3))."

	return self
end

function Godspeed:triggerEffect(round)
	local nbTurns = round.remainingHands
	round.remainingHands = 1
	multiplyScore(round, 5 * nbTurns)
end

function Godspeed:getDescription(run)
	return "Lowers your turns left to 0. Multiplies the score ((by 5)) for each turn discarded."
end

FaceTypes.Godspeed = Godspeed

--==WitchDice==--
local WitchDice = setmetatable({}, { __index = FaceObject })
WitchDice.__index = WitchDice

function WitchDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), WitchDice)

	--Metadatas about the BlackStar
	self.name = "Witch Dice"
	self.tier = "Rare"
	self.id = 57

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Witch Dice.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.description = "Scoring : [[+50pts]] for each Magic Wand Used in this office."

	return self
end

function WitchDice:triggerEffect(round)
	addScore(round, round.usedCiggiesRound * 50)
end

FaceTypes.WitchDice = WitchDice
--==WizardDice==--
local WizardDice = setmetatable({}, { __index = FaceObject })
WizardDice.__index = WizardDice

function WizardDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), WizardDice)

	--Metadatas about the BlackStar
	self.name = "Wizard Dice"
	self.tier = "Rare"
	self.id = 58

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Wizard Dice.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.description = "Scoring : [[X1.5pts]] for each Magic Wand Used in this office."

	return self
end

function WizardDice:triggerEffect(round)
	multiplyScore(round, math.max(1, round.usedCiggiesRound * 1.5))
end

FaceTypes.WizardDice = WizardDice
--==RecursiveDice==--
local RecursiveDice = setmetatable({}, { __index = FaceObject })
RecursiveDice.__index = RecursiveDice

function RecursiveDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), RecursiveDice)

	--Metadatas about the BlackStar
	self.name = "Recursive Dice"
	self.tier = "Rare"
	self.id = 59

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Recursive Dice.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function RecursiveDice:triggerEffect(round)
	local i = round.run.figuresInfos[round.playedFigure].playcount
	addScore(round, i * 20)
end

function RecursiveDice:getDescription(run)
	return "Scoring : adds [[20pts]] for each time the played figure was used this run."
end
FaceTypes.RecursiveDice = RecursiveDice

--==Echo==--
local Echo = setmetatable({}, { __index = FaceObject })
Echo.__index = Echo

function Echo:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Echo)

	--Metadatas about the BlackStar
	self.name = "Echo"
	self.tier = "Common"
	self.id = 60

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Echo.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.currentFigure = 0
	self.consecutiveCount = 0
	return self
end

function Echo:triggerEffect(round)
	if round.playedFigure == self.currentFigure then
		self.consecutiveCount = self.consecutiveCount + 1
	else
		self.currentFigure = round.playedFigure
		self.consecutiveCount = 1
	end
	addScore(round, 50 * self.consecutiveCount)
end

function Echo:getDescription(run)
	return "Scoring : adds [[50pts]] for each consecutive times this dice was scored in the played figure."
end

FaceTypes.Echo = Echo

--==CrossedOut==--
local CrossedOut = setmetatable({}, { __index = FaceObject })
CrossedOut.__index = CrossedOut

function CrossedOut:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), CrossedOut)

	--Metadatas about the BlackStar
	self.name = "Crossed Out"
	self.tier = "Common"
	self.id = 61

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Crossed Out.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.blank = true

	return self
end

function CrossedOut:triggerEffect(round)
	local i = 0
	for j = 1, 13 do
		if round.run.availableFigures[j] == 0 then
			i = i + 1
		end
	end

	addScore(round, i * 50)
end

function CrossedOut:getDescription(run)
	local i = 0
	for j = 1, 13 do
		if run.availableFigures[j] == 0 then
			i = i + 1
		end
	end

	return "Scoring : adds [[50pts]] for each currently unplayable figure (currently: [["
		.. tostring(50 * i)
		.. "pts]])"
end
FaceTypes.CrossedOut = CrossedOut

--==Time Dice==--
local TimeDice = setmetatable({}, { __index = FaceObject })
TimeDice.__index = TimeDice

function TimeDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), TimeDice)

	--Metadatas about the BlackStar
	self.name = "Time Dice"
	self.tier = "Rare"
	self.id = 62
	self.description = "Scoring : Adds a Time Magic Wand to the inventory"

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Time Dice.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	self.blank = true

	return self
end

function TimeDice:triggerEffect(round)
	if table.getn(round.run.ciggiesObjects) < round.run.maxCiggies then
		local c = CiggieTypes.Time:new()
		table.insert(round.run.ciggiesObjects, c)
		round.terrain:generateCiggiesUI()
	end

	local i = 0
	for j = 1, 13 do
		i = i + round.run.baseAvailableHands[j]
	end

	multiplyScore(round, math.max(1, 0.1 * i))
end

function TimeDice:getDescription(run)
	local i = 0
	for j = 1, 13 do
		i = i + run.baseAvailableHands[j]
	end
	return "Adds a Time Magic Wand to inventory. Adds ((X0.1)) for total playable figure (currently : ((X"
		.. tostring(i * 0.1)
		.. ")))"
end

FaceTypes.TimeDice = TimeDice

--==Hivemind==--
local Hivemind = setmetatable({}, { __index = FaceObject })
Hivemind.__index = Hivemind

function Hivemind:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), Hivemind)

	--Metadatas about the BlackStar
	self.name = "Hivemind"
	self.tier = "Common"
	self.id = 63

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Hivemind.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function Hivemind:triggerEffect(round)
	round.run.hivemindTriggers = round.run.hivemindTriggers + 1
	addScore(round, round.run.hivemindTriggers * 20)
end

function Hivemind:getDescription(run)
	return "[[+20pts]] for each time this dice type was triggering this run (currently : [[+"
		.. tostring(20 * run.hivemindTriggers)
		.. "pts]]."
end

FaceTypes.Hivemind = Hivemind

--==DiamondDice==--
local DiamondDice = setmetatable({}, { __index = FaceObject })
DiamondDice.__index = DiamondDice

function DiamondDice:new(faceValue, pointsValue)
	local self = setmetatable(FaceObject:new(), DiamondDice)

	--Metadatas about the BlackStar
	self.name = "Diamond Dice"
	self.tier = "Uncommon"
	self.id = 64

	--Metadatas about the graphics of the BlackStar
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Diamond Dice.png")
	self.spriteSheet:setFilter("linear", "linear")

	self.faceDimmension = 120 --sets the dimmensions for a face of the BlackStar in px (in the png)

	--Round status
	self.faceValue = faceValue --Le numéro de face que le dé représente
	self.pointsValue = 10 --This is the points scored by the dice
	self.totalTriggered = 0

	return self
end

function DiamondDice:triggerEffect(round)
	addScore(round, 10)
	addMoney(round, math.min(20, math.floor(round.run.money / 3)))
end

function DiamondDice:getDescription(run)
	return "[[+10pts]]. Adds 1$ for every 3$ in bank. Currently : +"
		.. tostring(math.min(20, math.floor(run.money / 3)))
		.. "$ (max : 20$)."
end

FaceTypes.DiamondDice = DiamondDice

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
