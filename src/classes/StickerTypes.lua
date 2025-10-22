local StickerObject = require("src.classes.StickerObject")

local StickerTypes = {}

local FlameSticker = setmetatable({}, { __index = StickerObject })
FlameSticker.__index = FlameSticker

function FlameSticker:new()
	local self = setmetatable(StickerObject:new(), FlameSticker)

	self.name = "Flame Sticker"
	self.description = "Placeholder flame sticker... Placeholder Description... yay!~"

	return self
end

StickerTypes.FlameSticker = FlameSticker

return StickerTypes
