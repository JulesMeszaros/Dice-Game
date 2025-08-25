local Sticker = {}
Sticker.__index = Sticker

function Sticker:new()
	--TODO: implement this class
	local self = setmetatable({}, Sticker)

	self.name = "Sticker"
	self.description = "This is a placeholder Sticker. You Are not supposed to see this.... woops"
	self.holographic = false

	return self
end

function Sticker:startRoundEffect() end

function Sticker:endRoundEffect() end

function Sticker:startTriggerEffect() end

function Sticker:endTriggerEffect() end

function Sticker:rerollEffect() end

return Sticker
