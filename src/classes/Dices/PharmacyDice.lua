local Dice = require("src.classes.Dices.Dice")

local PharmacyDice = setmetatable({}, { __index = Dice })
PharmacyDice.__index = PharmacyDice

function PharmacyDice:new()
    local self = setmetatable(Dice:new(), PharmacyDice)

    self.name = "Pharmacy Dice"
    self.id = 3

    --Metadatas about the graphics of the dice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/PharmacyDiceTileset.png")
    self.spriteSheet:setFilter("nearest", "nearest")
    return self
end

function PharmacyDice:triggerEffect(round)
    round:addToScore(round.roundScore)
end

return PharmacyDice