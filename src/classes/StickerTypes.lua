local StickerObject = require("src.classes.StickerObject")

local StickerTypes = {}

--Flame Sticker (placeholder)

local FlameSticker = setmetatable({}, { __index = StickerObject })
FlameSticker.__index = FlameSticker

function FlameSticker:new()
	local self = setmetatable(StickerObject:new(), FlameSticker)

	self.sprite = "src/assets/sprites/stickers/Flame.png"

	self.name = "Flame Sticker"
	self.description = "Placeholder flame sticker... Placeholder Description... yay!~"

	return self
end

--StickerTypes.FlameSticker = FlameSticker

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

function ThirteenthMonthSticker:unlockCondition(run)
	return checkForSticker(run, StickerTypes.MoneyBagSticker)
end

function ThirteenthMonthSticker:buyEffect(run)
	run.additionalMoney = run.additionalMoney + 10
end
StickerTypes.ThirteenthMonthSticker = ThirteenthMonthSticker

--HelpingHand Sticker

local HelpingHandSticker = setmetatable({}, { __index = StickerObject })
HelpingHandSticker.__index = HelpingHandSticker

function HelpingHandSticker:new()
	local self = setmetatable(StickerObject:new(), HelpingHandSticker)

	self.sprite = "src/assets/sprites/stickers/Thumbs Up.png"

	self.name = "Helping Hand"
	self.description = "+1 additionnal hand per office/"

	return self
end

function HelpingHandSticker:buyEffect(run)
	run.baseHands = run.baseHands + 1
end
StickerTypes.HelpingHandSticker = HelpingHandSticker

--MorningBrew Sticker

local MorningBrewSticker = setmetatable({}, { __index = StickerObject })
MorningBrewSticker.__index = MorningBrewSticker

function MorningBrewSticker:new()
	local self = setmetatable(StickerObject:new(), MorningBrewSticker)

	self.sprite = "src/assets/sprites/stickers/CoffeeCup.png"

	self.name = "Morning Brew"
	self.description = "The most played figure always appears in the first generation of the shop"

	return self
end

function MorningBrewSticker:buyEffect(run)
	run.morningBrewSticker = true
end
StickerTypes.MorningBrewSticker = MorningBrewSticker

function checkForSticker(run, stickerType)
	local stickerObject = stickerType:new()

	local stickerInInventory = false
	for i, sticker in next, run.stickers do
		if stickerObject.name == sticker.name then
			stickerInInventory = true
		end
	end

	return stickerInInventory
end

--HardSkills Sticker

local HardSkillsSticker = setmetatable({}, { __index = StickerObject })
HardSkillsSticker.__index = HardSkillsSticker

function HardSkillsSticker:new()
	local self = setmetatable(StickerObject:new(), HardSkillsSticker)

	self.sprite = "src/assets/sprites/stickers/Bolt.png"

	self.name = "Hard Skills"
	self.description = "Sets the limit to the upgrade of figures to 4 hands by floor."

	return self
end

function HardSkillsSticker:buyEffect(run)
	run.maxFiguresPossible = run.maxFiguresPossible + 1
end

StickerTypes.HardSkillsSticker = HardSkillsSticker

--DeepPockets Sticker

local DeepPocketsSticker = setmetatable({}, { __index = StickerObject })
DeepPocketsSticker.__index = DeepPocketsSticker

function DeepPocketsSticker:new()
	local self = setmetatable(StickerObject:new(), DeepPocketsSticker)

	self.sprite = "src/assets/sprites/stickers/Star.png"

	self.name = "Deep Pockets"
	self.description = "Gains one slot in your Magic Wands storage."

	return self
end

function DeepPocketsSticker:buyEffect(run)
	run.maxCiggies = run.maxCiggies + 1
end

StickerTypes.DeepPocketsSticker = DeepPocketsSticker

return StickerTypes
