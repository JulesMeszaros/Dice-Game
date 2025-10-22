local StickerObject = require("src.classes.StickerObject")

local StickerTypes = {}

local FlameSticker = setmetatable({}, { __index = StickerObject })
FlameSticker.__index = FlameSticker

function FlameSticker:new()
	local self = setmetatable(StickerObject:new(), FlameSticker)

	return self
end

StickerTypes.FlameSticker = FlameSticker

return StickerTypes
