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

	self.sprite = "src/assets/sprites/stickers/Moneybag.png"

	self.name = "Bonus Check"
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
	self.description = "+3$ at the end of each office."
	self.holographic = true

	return self
end

function ThirteenthMonthSticker:unlockCondition(run)
	return checkForSticker(run, StickerTypes.MoneyBagSticker)
end

function ThirteenthMonthSticker:buyEffect(run)
	run.additionalMoney = run.additionalMoney + 3
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

--BackToBack Sticker

local BackToBackSticker = setmetatable({}, { __index = StickerObject })
BackToBackSticker.__index = BackToBackSticker

function BackToBackSticker:new()
	local self = setmetatable(StickerObject:new(), BackToBackSticker)

	self.sprite = "src/assets/sprites/stickers/Cloud.png"

	self.name = "Back To Back"
	self.description = "Magic Wands have 1 out of 4 chance of being cloned when used."

	return self
end

function BackToBackSticker:ciggieUsedEffect(run)
	print(run.lastUsedCiggie.name)
	local randomInt = math.random(1, 4)

	if randomInt == 4 and table.getn(run.ciggiesObjects) < run.maxCiggies then
		table.insert(run.ciggiesObjects, getmetatable(run.lastUsedCiggie):new())
		if run.currentRound then
			run.currentRound.terrain:generateCiggiesUI()
		end
		if run.shop then
			run.shop:generateCiggiesUI()
		end
		if run.customizationScreen then
			run.customizationScreen:generateCiggiesUI()
		end
		if run.deskChoice then
			run.deskChoice:generateCiggiesUI()
		end
	end
end

StickerTypes.BackToBackSticker = BackToBackSticker

--ThinkDifferent Sticker

local ThinkDifferentSticker = setmetatable({}, { __index = StickerObject })
ThinkDifferentSticker.__index = ThinkDifferentSticker

function ThinkDifferentSticker:new()
	local self = setmetatable(StickerObject:new(), ThinkDifferentSticker)

	self.sprite = "src/assets/sprites/stickers/Lightbulb.png"

	self.name = "Think Different"
	self.description = "Full Houses can be played with two pairs of dices."
	self.holographic = true
	return self
end

function ThinkDifferentSticker:buyEffect(run)
	run.thinkDifferent = true
end

function ThinkDifferentSticker:unlockCOndition(run)
	return true
end

StickerTypes.ThinkDifferentSticker = ThinkDifferentSticker

--Clover Sticker
local CloverSticker = setmetatable({}, { __index = StickerObject })
CloverSticker.__index = CloverSticker

function CloverSticker:new()
	local self = setmetatable(StickerObject:new(), CloverSticker)

	self.sprite = "src/assets/sprites/stickers/Clover1.png"

	self.name = "Clover"
	self.description = "Gives an additionnal hand per floor to the Chance."
	self.holographic = false
	return self
end

function CloverSticker:buyEffect(run)
	run.baseAvailableHands[7] = run.baseAvailableHands[7] + 1
	run.availableFigures[7] = run.availableFigures[7] + 1
end

StickerTypes.CloverSticker = CloverSticker

--Shamrock Sticker
local ShamrockSticker = setmetatable({}, { __index = StickerObject })
ShamrockSticker.__index = ShamrockSticker

function ShamrockSticker:new()
	local self = setmetatable(StickerObject:new(), ShamrockSticker)

	self.sprite = "src/assets/sprites/stickers/Clover2.png"

	self.name = "Shamrock"
	self.description = "Gives another additionnal hand per floor to the Chance."
	self.holographic = true
	return self
end

function ShamrockSticker:buyEffect(run)
	run.baseAvailableHands[7] = run.baseAvailableHands[7] + 1
	run.availableFigures[7] = run.availableFigures[7] + 1
end

function ShamrockSticker:unlockCondition(run)
	return checkForSticker(run, StickerTypes.CloverSticker)
end

StickerTypes.ShamrockSticker = ShamrockSticker

--Bandaid Sticker
local BandaidSticker = setmetatable({}, { __index = StickerObject })
BandaidSticker.__index = BandaidSticker

function BandaidSticker:new()
	local self = setmetatable(StickerObject:new(), BandaidSticker)

	self.sprite = "src/assets/sprites/stickers/Bandaid.png"

	self.name = "Bandaid"
	self.description = "Three Of A Kind can be played with two dices. Four Of A Kind can be played with three."
	return self
end

function BandaidSticker:buyEffect(run)
	run.ThreeOAKFaciliter = true
	run.FourOAKFaciliter = true
end

StickerTypes.BandaidSticker = BandaidSticker
return StickerTypes
