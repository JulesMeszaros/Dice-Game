local Constants = require("src.utils.constants")
local FaceTypes = require("src.classes.FaceTypes.FaceTypes")
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
    local baseReward = 3 + math.random(0, 3)
    --Generate target score
    local targetScore = deskRank*5 + 20*self.floorNumber + (math.random(0, 3) * 10)
    --Generate desk number
    local deskNumber = self.floorNumber*100+deskRank*10+math.random(0,9)

    local r = Round:new(1, self.floorNumber, deskNumber, self.run.gameCanvas, self.run, baseReward, targetScore, self.run.diceObjects, Constants.ROUND_TYPES.BASE, self:generateReward(2))
    r.roundType = Constants.ROUND_TYPES.BASE
    return r
end

function Floor:generateBoss()
    local baseReward = 10 + math.random(0, 3)
    local targetScore = 50 + 20*self.floorNumber + (math.random(0, 3) * 10)

    local deskNumber = self.floorNumber*100+99

    local r = Round:new(1, self.floorNumber, deskNumber, self.run.gameCanvas, self.run, baseReward, targetScore, self.run.diceObjects, Constants.ROUND_TYPES.BOSS, self:generateReward(2))
    r.roundType = Constants.ROUND_TYPES.BOSS
    
    return r
end

function Floor:generateReward(maxFaces)
    --Generate faceType reward
    local keys = {}
    for key, _ in pairs(FaceTypes) do
        table.insert(keys, key)
    end
    local faceRewards = {}
    local nbrFace = math.random(1, maxFaces)
    for i=1, nbrFace do
        local randomFaceKey = keys[math.random(#keys)]
        local randomFaceType = FaceTypes[randomFaceKey] --On récupère une face type au hasard
        local randomFaceValue = math.random(1,6) --La face numérique
        local randomAdditionnalScore = math.random(1,6) --Le score en + de la face

        local randomFaceObject = randomFaceType:new(randomFaceValue, randomAdditionnalScore+randomFaceValue)

        table.insert(faceRewards, randomFaceObject)
    end
    return faceRewards
end

return Floor