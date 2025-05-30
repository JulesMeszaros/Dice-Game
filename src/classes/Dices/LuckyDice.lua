local Dice = require("src.classes.Dices.Dice")

local LuckyDice = setmetatable({}, { __index = Dice })
LuckyDice.__index = LuckyDice

function LuckyDice:new()
    local self = setmetatable(Dice:new(), LuckyDice)

    self.name = "Lucky Dice"
    self.id = 2

    --Metadatas about the graphics of the dice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/LuckyDiceTileset.png")
    self.spriteSheet:setFilter("nearest", "nearest")

    return self
end

function LuckyDice:triggerEffect(round)
    round:addToScore(2*self.currentFace)
end

return LuckyDice