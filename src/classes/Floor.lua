local Constants = require("src.utils.constants")

local Round = require("src.classes.Round")

local Floor = {}
Floor.__index = Floor

function Floor:new(floornumber, run)
    local self = setmetatable({}, Floor)

    self.run = run
    self.floorNumber = floornumber
    self.desks = {}
    self.boss = self:generateBoss()

    --Create the set of desks (3x3)
    for i = 1, 3 do
        local choices = {}
        for j = 1, 3 do
            local r = self:generateDesks(i)
            table.insert(choices, r)
        end
        table.insert(self.desks, choices)
    end

    return self
end

function Floor:generateDesks(deskRank)
    local baseReward = 3 + math.random(0, 3)
    local targetScore = deskRank*5 + 20*self.floorNumber + (math.random(0, 3) * 10)
    local deskNumber = self.floorNumber*100+math.random(0, 98)

    local r = Round:new(1, self.floorNumber, deskNumber, self.run.gameCanvas, self.run, baseReward, targetScore, self.run.diceObjects, Constants.ROUND_TYPES.BASE)
    r.roundType = Constants.ROUND_TYPES.BASE
    return r
end

function Floor:generateBoss()
    local baseReward = 10 + math.random(0, 3)
    local targetScore = 50 + 20*self.floorNumber + (math.random(0, 3) * 10)

    local deskNumber = self.floorNumber*100+99

    local r = Round:new(1, self.floorNumber, deskNumber, self.run.gameCanvas, self.run, baseReward, targetScore, self.run.diceObjects, Constants.ROUND_TYPES.BOSS)
    r.roundType = Constants.ROUND_TYPES.BOSS
    
    return r
end

return Floor