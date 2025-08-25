local Sticker = {}
Sticker.__index = Sticker

function Sticker:new()
	local self = setmetatable({}, Sticker)

	self.name = "Sticker"
	self.description = "This is a placeholder Sticker. You Are not supposed to see this.... woops"
	self.holographic = false

	return self
end

return Sticker
