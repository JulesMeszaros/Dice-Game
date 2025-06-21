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
    print(self.sprite)
    print("base")
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
    print("blue")
    return self
end

function BlueCiggie:effect(round)
    round.availableRerolls = round.availableRerolls+2
end

CiggieTypes.BlueCiggie = BlueCiggie

return CiggieTypes