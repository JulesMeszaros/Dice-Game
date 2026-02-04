local AudioFiles = require("src.utils.AudioFiles")

local AudioUtils = {}
AudioUtils.__index = AudioUtils

function AudioUtils:new()
	local self = setmetatable({}, AudioUtils)

	--Creation des sources audio pour les bruits de Hover des dés
	self.dicesHoverSounds = {}
	print(AudioFiles.DICE_HOVER)
	for i, decoder in next, AudioFiles.DICE_HOVER do
		table.insert(self.dicesHoverSounds, love.audio.newSource(decoder, "static"))
	end

	return self
end

function AudioUtils:playSound(source)
	source:play()
end

function AudioUtils:playHoverSound()
	local hoverSoundIndex = math.random(1, #self.dicesHoverSounds)
	self:playSound(self.dicesHoverSounds[hoverSoundIndex])
end

return AudioUtils
