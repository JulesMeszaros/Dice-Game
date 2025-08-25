local Sticker = {}
Sticker.__index = Sticker

function Sticker:new()
	local self = setmetatable({}, Sticker)

	return self
end

return Sticker
