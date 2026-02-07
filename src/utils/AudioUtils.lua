local AudioFiles = require("src.utils.AudioFiles")

local AudioUtils = {}
AudioUtils.__index = AudioUtils

function AudioUtils:new()
	local self = setmetatable({}, AudioUtils)

	self.sfxVolume = 1
	self.musicVolume = 1
	self.volume = 1

	--Creation des sources audio pour les bruits de Hover des dés
	self.dicesHoverSounds = {}
	for i, decoder in next, AudioFiles.DICE_HOVER do
		table.insert(self.dicesHoverSounds, love.audio.newSource(decoder, "static"))
	end

	--Creation des sources audio pour les bruits de Selection des dés
	self.dicesSelectSounds = {}
	for i, decoder in next, AudioFiles.DICE_SELECTION do
		table.insert(self.dicesSelectSounds, love.audio.newSource(decoder, "static"))
	end

	--Creation des sources audio pour les bruits de deelection des dés
	self.dicesDeselectSounds = {}
	for i, decoder in next, AudioFiles.DICE_DESELECTION do
		table.insert(self.dicesDeselectSounds, love.audio.newSource(decoder, "static"))
	end

	return self
end

function AudioUtils:buttonSound(state)
	local decoder = AudioFiles.MOUSE_CLICK_1
	if state == false then
		decoder = AudioFiles.MOUSE_CLICK_2
	end
	local source = love.audio.newSource(decoder, "static")
	self:playSound(source)
end

function AudioUtils:playSound(source)
	source:setVolume(self.sfxVolume * self.volume)
	source:play()
end

function AudioUtils:playHoverSound()
	local hoverSoundIndex = math.random(1, #self.dicesHoverSounds)
	self:playSound(self.dicesHoverSounds[hoverSoundIndex])
end

function AudioUtils:playSelectSound()
	local soundIndex = math.random(1, #self.dicesSelectSounds)
	self:playSound(self.dicesSelectSounds[soundIndex])
end

function AudioUtils:playDeselectSound()
	local soundIndex = math.random(1, #self.dicesDeselectSounds)
	self:playSound(self.dicesDeselectSounds[soundIndex])
end

return AudioUtils
