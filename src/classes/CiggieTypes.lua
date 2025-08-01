local Constants = require("src.utils.Constants")
local CiggieObject = require("src.classes.CiggieObject")

local CiggieTypes = {}

--Free Roller--
local FreeRoller = setmetatable({}, {__index = CiggieObject})
FreeRoller.__index = FreeRoller

function FreeRoller:new()
    local self = setmetatable(CiggieObject.new(), FreeRoller)

    self.usableIn = Constants.RUN_STATES.ROUND

    self.type = self

    self.name="Free Roller"
    self.description="Adds one additionnal reroll to the current hand"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Free Roller Cigarette.png")
    return self
end

function FreeRoller:effect(screen)
    screen.round.availableRerolls = screen.round.availableRerolls+1
end

CiggieTypes.FreeRoller = FreeRoller

--Turnns--
local Turnns = setmetatable({}, {__index = CiggieObject})
Turnns.__index = Turnns

function Turnns:new()
    local self = setmetatable(CiggieObject.new(), Turnns)
    self.type = self

    self.usableIn = Constants.RUN_STATES.ROUND

    self.name="Turnn's"
    self.description="Adds one additionnal turn to the current round"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Turnn's Cigarette.png")
    return self
end

function Turnns:effect(screen)
    screen.round.remainingHands = screen.round.remainingHands+1
end

CiggieTypes.Turnns = Turnns

--Fortune--

local Fortune = setmetatable({}, {__index = CiggieObject})
Fortune.__index = Fortune

function Fortune:new()
    local self = setmetatable(CiggieObject.new(), Fortune)
    self.type = self

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

--Rockmans--

local Rockmans = setmetatable({}, {__index = CiggieObject})
Rockmans.__index = Rockmans

function Rockmans:new()
    local self = setmetatable(CiggieObject.new(), Rockmans)

    self.usableIn = "any"

    self.name="Rockmans"
    self.description="Clones one of your cigarettes (if space left)"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Rockmans Cigarette.png")
    return self
end


function Rockmans:effect(screen)
    local randomCiggie = getRandomExcluding(screen.run.ciggiesObjects, self)
    
    table.insert(screen.run.ciggiesObjects, getmetatable(randomCiggie):new())
    print(table.getn(screen.run.ciggiesObjects))
end

CiggieTypes.Rockmans = Rockmans

--Time--

local Time = setmetatable({}, {__index = CiggieObject})
Time.__index = Time

function Time:new()
    local self = setmetatable(CiggieObject.new(), Time)

    self.usableIn = {Constants.RUN_STATES.ROUND, Constants.RUN_STATES.SHOP, Constants.RUN_STATES.ROUND_CHOICE}

    self.name="Time"
    self.description="Lets you add one additionnal hand per round to a choosen figure"

    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Time Cigarette.png")
    return self
end

function Time:effect(screen)
    screen.addingAvailableHand = true
end

CiggieTypes.Time = Time

--UTILS--
function getRandomExcluding(list, excluded)
    local filtered = {}
    for _, value in ipairs(list) do
        if value ~= excluded then
            table.insert(filtered, value)
        end
    end

    if #filtered == 0 then return nil end -- aucun choix possible

    return filtered[math.random(#filtered)]
end


return CiggieTypes

