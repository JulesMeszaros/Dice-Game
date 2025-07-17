local Constants = require("src.utils.Constants")
local CiggieObject = require("src.classes.CiggieObject")

local CiggieTypes = {}

--Free Roller--
local FreeRoller = setmetatable({}, {__index = CiggieObject})
FreeRoller.__index = FreeRoller

function FreeRoller:new()
    local self = setmetatable(CiggieObject.new(), FreeRoller)

    self.usableIn = Constants.RUN_STATES.ROUND

    self.name="Free Roller"
    self.description="Adds one additionnal reroll to the current hand"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Free Roller Cigarette.png")
    return self
end

function FreeRoller:effect(screen)
    screen.round.availableRerolls = screen.round.availableRerolls+1
end

CiggieTypes.FreeRoller = FreeRoller

--Fortune--

local Fortune = setmetatable({}, {__index = CiggieObject})
Fortune.__index = Fortune

function Fortune:new()
    local self = setmetatable(CiggieObject.new(), Fortune)

    self.usableIn = "any"

    self.name="Fortune"
    self.description="Adds 5$ to the balance"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Fortune Cigarette.png")
    return self
end

function Fortune:effect(screen)
    screen.run.money = screen.run.money+5
end

CiggieTypes.Fortune = Fortune

return CiggieTypes