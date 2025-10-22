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
	print("starttrigger")
end

function Sticker:endTriggerEffect()
	print("endtrigger")
end

function Sticker:diceTriggeredEffect()
	print("diceTrigger")
end

function Sticker:rerollEffect()
	print("reroll")
end

function Sticker:caseEffect()
	print("caseeffect")
end

function Sticker:ciggieUsedEffect()
	print("ciggieUsed")
end

function Sticker:coffeeUsedEffect()
	print("coffeUsed")
end

function Sticker:diceFaceBoughtEffect()
	print("diceFaceBought")
end

--Effet qui se déclenche une seule fois, au moment ou le sticker est acheté et placé sur le terrain
function Sticker:buyEffect()
	print("sticker bought")
end

return Sticker
