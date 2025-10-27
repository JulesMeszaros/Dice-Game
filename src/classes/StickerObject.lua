local Sticker = {}
Sticker.__index = Sticker

function Sticker:new()
	--TODO: implement this class
	local self = setmetatable({}, Sticker)

	self.name = "Sticker"
	self.description = "This is a placeholder Sticker. You Are not supposed to see this.... woops"
	self.holographic = false
	self.objectType = "Sticker"
	return self
end

function Sticker:getDescription()
	return self.description
end

--Effects
function Sticker:startRoundEffect()
	print("StartRound")
end

function Sticker:endRoundEffect()
	print("endRound")
end

function Sticker:figurePlayedEffect()
	print("figurePlyed")
end

function Sticker:startTriggerEffect()
	--A implementer
	print("starttrigger")
end

function Sticker:endTriggerEffect()
	--A implementer
	print("endtrigger")
end

function Sticker:diceTriggeredEffect()
	--A implementer
	print("diceTrigger")
end

function Sticker:rerollEffect()
	--A implementer
	print("reroll")
end

function Sticker:caseEffect()
	--A implementer
	print("caseeffect")
end

function Sticker:ciggieUsedEffect()
	--A implementer
	print("ciggieUsed")
end

function Sticker:coffeeUsedEffect()
	--A implementer
	print("coffeUsed")
end

function Sticker:diceFaceBoughtEffect()
	--A implementer
	print("diceFaceBought")
end

--Effet qui se déclenche une seule fois, au moment ou le sticker est acheté et placé sur le terrain
function Sticker:buyEffect()
	--A implementer
	print("sticker bought")
end

return Sticker
