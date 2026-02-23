--[[
    This class represents the basic white dice face.
    It is used as the default class for every dice faces, who inherits
    from this one.
]]
local UI = require("src.utils.scripts.UI")
local AnimationUtils = require("src.utils.scripts.Animations")

local FaceObject = {}
FaceObject.__index = FaceObject

function FaceObject:new()
	local self = setmetatable({}, FaceObject)

	self.objectType = "Dice Face"

	--Metadatas about the FaceObject
	self.name = "FACE OBJECT"
	self.id = 0
	self.tier = "??"
	self.description = "???"

	--Metadatas about the graphics of the FaceObject
	self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Base Dice.png")
	self.spriteSheet:setFilter("linear", "linear")
	self.faceDimmension = 120 --sets the dimmensions for a face of the FaceObject in px (in the png)
	self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
		{ 120, 120 }, -- 1
		{ 0, 120 }, -- 2
		{ 120, 240 }, -- 3
		{ 120, 0 }, -- 4
		{ 240, 120 }, -- 5
		{ 120, 360 }, -- 6
	}

	--Booleans status
	self.disabled = false
	--About the type of effects the dice has
	self.backup = false
	self.ghost = false
	self.replay = false
	self.blank = false
	self.fullHand = false
	self.fullDice = false
	self.first = false
	self.unique = false

	self.totaldisabled = 0

	--Numbered status
	self.faceValue = 1 --This is the face represented by the face (the number shown)
	self.pointsValue = 0 --This is the points scored by the dice
	self.totalTriggered = 0
	self.roundTriggered = 0
	return self
end

--==Trigger functions==--

--Utils

--Detecte si il est premier
function FaceObject:isFirst(round)
	local _, dicesOrder = round:getDicesOrder(round.usedDices)
	return self == dicesOrder[1]:getCurrentFaceObject()
end

--Detexte s'il est unique dans la main
function FaceObject:isUnique(round)
	local _, dicesOrder = round:getDicesOrder(round.usedDices)
	for _, dice in next, dicesOrder do
		if dice:getCurrentFaceObject() ~= self and dice:getCurrentFaceObject().name == self.name then
			return false
		end
	end
	return true
end

--Detecte s'il est full hand (surement jamais utilisé...)
function FaceObject:isFullHand(round)
	local _, dicesOrder = round:getDicesOrder(round.usedDices)
	for _, dice in next, dicesOrder do
		if dice:getCurrentFaceObject().name ~= self.name then
			return false
		end
	end
	return true
end

--Construction de la chaîne d'effets (vides)
function FaceObject:buildTriggerEffects(round)
	return {}
end
function FaceObject:buildFirstEffects(round)
	return {}
end
function FaceObject:buildReplayEffects(round)
	return {}
end
function FaceObject:buildFullHandEffects(round)
	return {}
end
function FaceObject:buildUniqueEffects(round)
	return {}
end

function FaceObject:buildEffects(round)
	--Cette fonction construit la chaine d'effet totale de la face de dé, en commencant par les effets first, puis replay, puis fullHand, puis unique, puis classiques.
	--Elle retourne une liste d'effets dans une grande liste.
	local effects = {}

	-- Compteurs incrémentés à chaque trigger, peu importe la source
	self.totalTriggered = self.totalTriggered + 1
	self.roundTriggered = self.roundTriggered + 1

	-- Stats de save
	if G.saveManager.data["stats"]["dices"][self.id] then
		G.saveManager.data["stats"]["dices"][self.id] = G.saveManager.data["stats"]["dices"][self.id] + 1
	else
		G.saveManager.data["stats"]["dices"][self.id] = 1
	end

	local function append(list)
		for _, e in next, list do
			table.insert(effects, e)
		end
	end

	if self.first == true and self:isFirst(round) then
		append(self:buildFirstEffects(round))
	end

	if self.roundTriggered > 1 and self.replay == true then
		append(self:buildReplayEffects(round))
	end

	if self.fullHand == true and self:isFullHand(round) then
		append(self:buildFullHandEffects(round))
	end

	if self.unique == true and self:isUnique(round) then
		append(self:buildUniqueEffects(round))
	end

	append(self:buildTriggerEffects(round))

	return effects
end

function FaceObject:resetStats()
	self.roundTriggered = 0
	self.disabled = false
end

function FaceObject:trigger(round)
	local rx = AnimationUtils.randomInRange(0, 2)
	local ry = math.abs(AnimationUtils.randomInRange(2, 3))

	--Animations
	-- randomValue is now in the requested range
	UI.ScreenWave(rx, ry)

	--Incrémente les variables numériques
	self.totalTriggered = self.totalTriggered + 1
	self.roundTriggered = self.roundTriggered + 1

	--Incrementation du trigger pour la save de stats
	if G.saveManager.data["stats"]["dices"][self.id] then
		G.saveManager.data["stats"]["dices"][self.id] = G.saveManager.data["stats"]["dices"][self.id] + 1
	else
		G.saveManager.data["stats"]["dices"][self.id] = 1
	end

	--Déclenche l'effet first si possible
	if self.first == true then
		local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)
		if self == dicesOrder[1]:getCurrentFaceObject() then
			self:firstEffect(round)
		end
	end

	--Déclenche l'effet replay si possible
	if self.roundTriggered > 1 and self.replay == true then
		self:replayEffect(round)
	end

	--Declanche l'effet fullHand si possible
	if self.fullHand then
		local fullHand = true
		local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)
		for i, dice in next, dicesOrder do
			if dice:getCurrentFaceObject().name ~= self.name then
				fullHand = false
			end
		end

		if fullHand == true then
			self:fullHandEffect(round)
		end
	end

	--Declanche l'effet unique si possible
	if self.unique then
		local unique = true
		local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)
		for i, dice in next, dicesOrder do
			if dice:getCurrentFaceObject() ~= self and dice:getCurrentFaceObject().name == self.name then
				unique = false
				break
			end
		end

		if unique == true then
			self:uniqueEffect(round)
		end
	end

	--Déclenche l'effet de trigger
	self:triggerEffect(round)
end

function FaceObject:triggerBackup(round, uiFace)
	-- Pour l'effet backup
	self:backupEffect(round)
	uiFace.animator:addDelay(0.0, function()
		uiFace.targetedScale = 1
		uiFace.round:triggerNextBackupDice()
	end)
end

--Triggers effects

function FaceObject:triggerEffect(round)
	--Complementary effect triggered by the face
	return
end

function FaceObject:backupEffect(round) end

function FaceObject:fullHandEffect(round) end

function FaceObject:replayEffect(round) end

function FaceObject:uniqueEffect(round)
	--Effect that triggers only if the dice is the only dice this type in scored hand
end

function FaceObject:firstEffect(round)
	--Effet qui se trigger si le dé est le scoré le plus à gauche
end

--Sprite
function FaceObject:getSpriteSheet()
	return self.spriteSheet
end

function FaceObject:getQuad(i)
	quad = love.graphics.newQuad(
		self.faceSpritesCoordinates[i][1],
		self.faceSpritesCoordinates[i][2], -- x, y dans l'image source
		200,
		200, -- largeur, hauteur de la portion
		self.spriteSheet:getDimensions() -- taille totale de l'image
	)
	return quad
end

function FaceObject:getFaceDim()
	return self.faceDimmension
end

function FaceObject:setDiceObject(diceObject)
	self.diceObject = diceObject
end

function FaceObject:setFacePoints(n)
	self.pointsValue = n
end

function FaceObject:getDescription(run)
	local d = self.description or "[[No description.]]"
	return d
end

function FaceObject:getPointsValue(run)
	local p = self.pointsValue or 0
	return p
end

return FaceObject
