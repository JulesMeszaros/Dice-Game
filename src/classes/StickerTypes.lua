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

	self.name = "Salary Bonus"
	self.description = "Gives an additional 5$ at the end of each office."

	return self
end

function MoneyBagSticker:buyEffect(run)
	run.additionalMoney = run.additionalMoney + 5
end
StickerTypes.MoneyBagSticker = MoneyBagSticker

--RerollAdder Sticker

local RerollAdderSticker = setmetatable({}, { __index = StickerObject })
RerollAdderSticker.__index = RerollAdderSticker

function RerollAdderSticker:new()
	local self = setmetatable(StickerObject:new(), RerollAdderSticker)

	self.sprite = "src/assets/sprites/stickers/Repeat.png"

	self.name = "Last Chance"
	self.description = "Adds an additional reroll per hand"

	return self
end

function RerollAdderSticker:buyEffect(run)
	run.baseRerolls = run.baseRerolls + 1
	print("reroll added !")
end
StickerTypes.RerollAdderSticker = RerollAdderSticker

--ShopReroll Sticker

local ShopRerollSticker = setmetatable({}, { __index = StickerObject })
ShopRerollSticker.__index = ShopRerollSticker

function ShopRerollSticker:new()
	local self = setmetatable(StickerObject:new(), ShopRerollSticker)

	self.sprite = "src/assets/sprites/stickers/Plus.png"

	self.name = "On The House"
	self.description = "Sets the base price for the shop reroll to 0$."

	return self
end

function ShopRerollSticker:buyEffect(run)
	run.baseShopRerollPrice = 0
end
StickerTypes.ShopRerollSticker = ShopRerollSticker

--ThirteenthMonth Sticker

local ThirteenthMonthSticker = setmetatable({}, { __index = StickerObject })
ThirteenthMonthSticker.__index = ThirteenthMonthSticker

function ThirteenthMonthSticker:new()
	local self = setmetatable(StickerObject:new(), ThirteenthMonthSticker)

	self.sprite = "src/assets/sprites/stickers/Coin.png"

	self.name = "13th Month"
	self.description = "+10$ at the end of each office."
	self.holographic = true

	return self
end

function ThirteenthMonthSticker:buyEffect(run)
	run.additionalMoney = run.additionalMoney + 10
end
StickerTypes.ThirteenthMonthSticker = ThirteenthMonthSticker

return StickerTypes
