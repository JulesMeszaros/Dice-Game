local Dice = require("src.classes.Dices.Dice")

local ReverseDice = setmetatable({}, { __index = Dice })
ReverseDice.__index = ReverseDice

function ReverseDice:new()
    local self = setmetatable(Dice:new(), ReverseDice)

    self.name = "Reverse Dice"
    self.id = 4

    --Metadatas about the graphics of the dice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/ReverseDiceTileset.png")
    self.spriteSheet:setFilter("nearest", "nearest")
    return self
end

function ReverseDice:triggerEffect(round)
    --Stops the triggering phase abruptly
    round.diceFacesTriggerQueue = {} --Dice queue for the triggers. get modified during the trigger phase
    round.dicesTriggerQueue = {}  --Same but for the dices

end

return ReverseDice