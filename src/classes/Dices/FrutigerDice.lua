local Dice = require("src.classes.Dices.Dice")

local FrutigerDice = setmetatable({}, { __index = Dice })
FrutigerDice.__index = FrutigerDice

function FrutigerDice:new()
    local self = setmetatable(Dice:new(), FrutigerDice)

    self.name = "Frutiger Aero Dice"

    --Metadatas about the graphics of the dice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/frutiger_dice.png")
    self.spriteSheet:setFilter("linear", "linear")

    return self
end

return FrutigerDice