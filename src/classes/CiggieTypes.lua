local Constants = require("src.utils.Constants")
local CiggieObject = require("src.classes.CiggieObject")

local CiggieTypes = {}

--Base Ciggie--
local BaseCiggie = setmetatable({}, {__index = CiggieObject})
BaseCiggie.__index = BaseCiggie

function BaseCiggie:new()
    local self = setmetatable(CiggieObject.new(), BaseCiggie)

    self.usableIn = Constants.RUN_STATES.ROUND

    self.name="Free Roller"
    self.description="Adds one additionnal reroll to the current hand"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Free Roller Cigarette.png")
    return self
end

function BaseCiggie:effect(round)
    round.availableRerolls = round.availableRerolls+1
end

CiggieTypes.BaseCiggie = BaseCiggie

--Golden Ciggie--

local GoldenCiggie = setmetatable({}, {__index = CiggieObject})
GoldenCiggie.__index = GoldenCiggie

function GoldenCiggie:new()
    local self = setmetatable(CiggieObject.new(), GoldenCiggie)

    self.usableIn = "any"

    self.name="Fortune"
    self.description="Adds 5$ to the balance"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Fortune Cigarette.png")
    return self
end

function GoldenCiggie:effect(screen)
    screen.run.money = screen.run.money+5
end

CiggieTypes.GoldenCiggie = GoldenCiggie

return CiggieTypes