local Sticker = {}
Sticker.__index = Sticker

function Sticker:new()
	--TODO: implement this class
	local self = setmetatable({}, Sticker)
	self.sprite = "src/assets/sprites/stickers/Flame.png"
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
function Sticker:startRoundEffect(run)
	print("StartRound")
end

function Sticker:endRoundEffect(run)
	print("endRound")
end

function Sticker:figurePlayedEffect(run)
	print("figurePlyed")
end

function Sticker:startTriggerEffect(run)
	--A implementer
	print("starttrigger")
end

function Sticker:endTriggerEffect(run)
	--A implementer
	print("endtrigger")
end

function Sticker:diceTriggeredEffect(run)
	--A implementer
	print("diceTrigger")
end

function Sticker:rerollEffect(run)
	--A implementer
	print("reroll")
end

function Sticker:caseEffect(run)
	--A implementer
	print("caseeffect")
end

function Sticker:ciggieUsedEffect(run)
	--A implementer
	print("ciggieUsed")
end

function Sticker:coffeeUsedEffect(run)
	--A implementer
	print("coffeUsed")
end

function Sticker:diceFaceBoughtEffect(run)
	--A implementer
	print("diceFaceBought")
end

--Effet qui se déclenche une seule fois, au moment ou le sticker est acheté et placé sur le terrain
function Sticker:buyEffect(run)
	--A implementer
	print("sticker bought")
end

return Sticker
