local StickerObject = require("src.classes.StickerObject")

local StickerTypes = {}

--Flame Sticker

local FlameSticker = setmetatable({}, { __index = StickerObject })
FlameSticker.__index = FlameSticker

function FlameSticker:new()
	local self = setmetatable(StickerObject:new(), FlameSticker)

	self.sprite = "src/assets/sprites/stickers/Flame.png"

	self.name = "Flame Sticker"
	self.description = "Placeholder flame sticker... Placeholder Description... yay!~"

	return self
end

StickerTypes.FlameSticker = FlameSticker

--MoneyBag Sticker

local MoneyBagSticker = setmetatable({}, { __index = StickerObject })
MoneyBagSticker.__index = MoneyBagSticker

function MoneyBagSticker:new()
	local self = setmetatable(StickerObject:new(), MoneyBagSticker)

	self.sprite = "src/assets/sprites/stickers/MoneyBag.png"

	self.name = "Money Bag Sticker"
	self.description = "Gives an additional 5$ at the end of each office."

	return self
end

function MoneyBagSticker:buyEffect(run)
	run.additionalMoney = run.additionalMoney + 5
end
StickerTypes.MoneyBagSticker = MoneyBagSticker

return StickerTypes
