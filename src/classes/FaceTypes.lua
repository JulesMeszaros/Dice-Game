local Fonts = require("src.utils.Fonts")
local UI = require("src.utils.scripts.UI")
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

function WhiteDice:buildTriggerEffects(round)
	return {
		{
			type = "score",
			fn = function()
				addScore(round, self.pointsValue, self)
				if Constants.OVERPOWER == true then
					addScore(round, 10000000000000000000000000000, self)
				end
			end,
		},
	}
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

function ChunkyDice:buildTriggerEffects(round)
	return {
		{
			type = "score",
			fn = function()
				addScore(round, self.pointsValue, self)
			end,
		},
	}
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

function MassiveDice:buildTriggerEffects(round)
	return {
		{
			type = "score",
			fn = function()
				addScore(round, self.pointsValue, self)
			end,
		},
	}
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

function BlueDice:getDescription(run)
	return "[[+2pts]] per used rerolls this building (currently : [[" .. tostring(2 * run.usedRerolls) .. "pts]] )."
end

function BlueDice:buildTriggerEffects(round)
	return {
		{
			type = "score",
			fn = function()
				addScore(round, 2 * round.run.usedRerolls, self)
			end,
		},
	}
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

function GoldDice:buildTriggerEffects(round)
	return {
		{
			type = "score",
			fn = function()
				addScore(round, self.pointsValue, self)
			end,
		},
		{
			type = "money",
			fn = function()
				addMoney(round, 5, self)
			end,
		},
	}
end

FaceTypes.GoldDice = GoldDice

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

	addScore(round, self.pointsValue, self)
end

function StrikeOfLuck:buildTriggerEffects(round)
	return {
		{
			type = "score",
			fn = function()
				addScore(round, self.pointsValue, self)
			end,
		},
		{ --Ajout de la cigarette random
			type = "other",
			fn = function()
				if table.getn(round.run.ciggiesObjects) < round.run.maxCiggies then
					local c = GenerateRandom.CiggieObject()
					table.insert(round.run.ciggiesObjects, c)
					round.terrain:generateCiggiesUI()
				end
			end,
		},
	}
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

function Copyprinter:buildTriggerEffects(round)
	return {
		{
			type = "other",
			fn = function()
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
			end,
		},
	}
end

--FaceTypes.Copyprinter = Copyprinter

--UTILS--
function multiplyScore(round, f, face)
	round.handScore = round.handScore * f
	table.insert(
		round.terrain.triggerTexts,
		UI.Text.TextWavy:new("X" .. f .. "", round.terrain.diceFaces[face.diceObject].x + round.terrain.diceMatx, 500, {
			font = Fonts.soraRewardTotal,
			colorStart = { 232 / 255, 79 / 255, 79 / 255, 1 },
			revealSpeed = 0.15,
			lifetime = 0.5,
			popAngleStart = 0,
			centered = true,
			popOvershoot = 0.4,
			popStart = 1,
		})
	)
end

function addScore(round, f, face)
	round.handScore = round.handScore + f
	table.insert(
		round.terrain.triggerTexts,
		UI.Text.TextWavy:new(
			"+" .. f .. "pts",
			round.terrain.diceFaces[face.diceObject].x + round.terrain.diceMatx,
			500,
			{
				font = Fonts.soraRewardTotal,
				colorStart = { 232 / 255, 79 / 255, 79 / 255, 1 },
				revealSpeed = 0.15,
				lifetime = 0.5,
				popAngleStart = 0,
				centered = true,
				popOvershoot = 0.4,
				popStart = 1,
			}
		)
	)
end

function addMoney(round, m, face)
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
