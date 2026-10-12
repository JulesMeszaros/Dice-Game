local Sticker = {}
Sticker.__index = Sticker

function Sticker:new()
	--TODO: implement this class
	local self = setmetatable({}, Sticker)
	self.sprite = "src/assets/sprites/stickers/Flame.png"
	self.name = "Sticker"
	self.description = "This is a placeholder Sticker. You Are not supposed to see this.... woops"
	--Variable décrivant si le sticker est holographique ou non
	self.holographic = false
	--Si le sticker est holographique, quel est le sticker qu'il améliore
	self.baseSticker = nil

	self.objectType = "Sticker"
	return self
end

function Sticker:getDescription()
	return self.description
end

function Sticker:unlockCondition(run)
	return true
end

--Effects
function Sticker:startRoundEffect(run) end

function Sticker:endRoundEffect(run) end

function Sticker:figurePlayedEffect(run) end

function Sticker:startTriggerEffect(run) end

function Sticker:endTriggerEffect(run) end

function Sticker:diceTriggeredEffect(run) end

function Sticker:rerollEffect(run) end

function Sticker:caseEffect(run) end

function Sticker:ciggieUsedEffect(run) end

function Sticker:coffeeUsedEffect(run) end

function Sticker:diceFaceBoughtEffect(run) end

--Effet qui se déclenche une seule fois, au moment ou le sticker est acheté et placé sur le terrain
function Sticker:buyEffect(run) end

return Sticker
