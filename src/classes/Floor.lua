local Constants = require("src.utils.Constants")
local FaceTypes = require("src.classes.FaceTypes")
local Round = require("src.classes.Round")
local CalculateTargets = require("src.utils.scripts.CalculateTargets")

local Floor = {}
Floor.__index = Floor

function Floor:new(floornumber, run)
    local self = setmetatable({}, Floor)

    self.run = run
    self.floorNumber = floornumber
    self.desks = {}
    self.boss = self:generateBoss()

    --Create the set of desks (4x3) TODO: changer a 2
    for i = 1, Constants.DESKS_BY_FLOOR do
        local choices = {}
        for j = 1, 4 do
            local r = self:generateDesks(i)
            table.insert(choices, r)
        end
        table.insert(self.desks, choices)
    end

    return self
end

function Floor:generateDesks(deskRank)
    --Generate money reward
    local baseReward = 1 + deskRank * 2
    --Generate target score
    local targetScore = 0
    --Generate desk number
    local deskNumber = self.floorNumber*100+deskRank*10+math.random(0,9)

    --Generate target
    if(deskRank == 1) then
        targetScore = CalculateTargets.firstOffice(self.floorNumber)
    elseif (deskRank==2) then
        targetScore = CalculateTargets.secondOffice(self.floorNumber)
    end

    local r = Round:new(1, self.floorNumber, deskNumber, self.run.gameCanvas, self.run, baseReward, targetScore, self.run.diceObjects, Constants.ROUND_TYPES.BASE, self:generateReward(2))
    r.roundType = Constants.ROUND_TYPES.BASE
    return r
end

function Floor:generateBoss()
    local baseReward = 7
    local targetScore = CalculateTargets.manager(self.floorNumber)

    local deskNumber = self.floorNumber*100+99

    local r = Round:new(1, self.floorNumber, deskNumber, self.run.gameCanvas, self.run, baseReward, targetScore, self.run.diceObjects, Constants.ROUND_TYPES.BOSS, self:generateReward(2))
    r.roundType = Constants.ROUND_TYPES.BOSS
    
    return r
end

function Floor:generateReward()
    --Generate faceType reward
    local keys = {}
    for key, _ in pairs(FaceTypes) do
        if(key~="WhiteFace")then
            table.insert(keys, key)
        end
    end
    local faceRewards = {}
    local nbrFace = 2 --Toujours deux faces.
    for i=1, nbrFace do
        local randomFaceKey = keys[math.random(#keys)]
        local randomFaceType = FaceTypes[randomFaceKey] --On récupère une face type au hasard
        local randomFaceValue = math.random(1,6) --La face numérique

        local randomFaceObject = randomFaceType:new(randomFaceValue, 10)

        table.insert(faceRewards, randomFaceObject)
    end
    return faceRewards
end

return Floor