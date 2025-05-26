local Dice = require("src.classes.Dices.Dice")

local EvilDice = setmetatable({}, { __index = Dice })
EvilDice.__index = EvilDice

function EvilDice:new()
    local self = setmetatable(Dice:new(), EvilDice)

    self.name = "Reverse Dice"

    --Metadatas about the graphics of the dice
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/ReverseDiceTileset.png")
    self.spriteSheet:setFilter("nearest", "nearest")
    return self
end

return EvilDice