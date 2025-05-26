local Dice = require("src.classes.Dices.Dice")

local FrutigerDice = setmetatable({}, { __index = Dice })
FrutigerDice.__index = FrutigerDice

function FrutigerDice:new()
    local self = setmetatable(Dice:new(), FrutigerDice)

    self.name = "Lucky Dice"

    --Metadatas about the graphics of the dice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/LuckyDiceTileset.png")
    self.spriteSheet:setFilter("nearest", "nearest")

    return self
end

return FrutigerDice