local CiggieObject = require("src.classes.CiggieObject")

local CiggieTypes = {}

--Base Ciggie--
local BaseCiggie = setmetatable({}, {__index = CiggieObject})
BaseCiggie.__index = BaseCiggie

function BaseCiggie:new()
    local self = setmetatable(CiggieObject.new(), BaseCiggie)

    self.name="Base Ciggie"
    self.description="Adds one additionnal reroll to the current hand"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/basicCiggie.png")
    return self
end

function BaseCiggie:effect(round)
    round.availableRerolls = round.availableRerolls+1
end

CiggieTypes.BaseCiggie = BaseCiggie

--Blue Ciggie--

local BlueCiggie = setmetatable({}, {__index = CiggieObject})
BlueCiggie.__index = BlueCiggie

function BlueCiggie:new()
    local self = setmetatable(CiggieObject.new(), BlueCiggie)

    self.name="Blue Ciggie"
    self.description="Adds two additionnal reroll to the current hand"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/blueCiggie.png")
    return self
end

function BlueCiggie:effect(round)
    round.availableRerolls = round.availableRerolls+2
end

CiggieTypes.BlueCiggie = BlueCiggie

--Golden Ciggie--

local GoldenCiggie = setmetatable({}, {__index = CiggieObject})
GoldenCiggie.__index = GoldenCiggie

function GoldenCiggie:new()
    local self = setmetatable(CiggieObject.new(), GoldenCiggie)

    self.name="Golden Ciggie"
    self.description="Doubles your current balance"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/goldenCiggie.png")
    return self
end

function GoldenCiggie:effect(round)
    round.run.money = round.run.money+round.run.money
end

CiggieTypes.GoldenCiggie = GoldenCiggie

return CiggieTypes