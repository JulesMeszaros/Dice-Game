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

function Sticker:startRoundEffect() end

function Sticker:endRoundEffect() end

function Sticker:figurePlayedEffect() end

function Sticker:startTriggerEffect() end

function Sticker:endTriggerEffect() end

function Sticker:diceTriggeredEffect() end

function Sticker:rerollEffect() end

function Sticker:caseEffect() end

function Sticker:ciggieUsedEffect() end

function Sticker:coffeeUsedEffect() end

function Sticker:diceFaceBoughtEffect() end

--Effet qui se déclenche une seule fois, au moment ou le sticker est acheté et placé sur le badge
function Sticker:buyEffect() end

return Sticker
