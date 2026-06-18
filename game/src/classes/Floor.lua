local FaceTypes = require("src.classes.FaceTypes")
local CiggieTypes = require("src.classes.CiggieTypes")
local Constants = require("src.utils.Constants")
local FaceTypes = require("src.classes.FaceTypes")
local Round = require("src.classes.Round")
local CalculateTargets = require("src.utils.scripts.CalculateTargets")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")
local Floor = {}
Floor.__index = Floor

function Floor:new(floornumber, run)
  local self = setmetatable({}, Floor)

  self.run = run
  self.floorNumber = floornumber
  self.run.floorNumber = floornumber
  self.desks = {}
  self.boss = self:generateBoss()

  --Create the set of desks (4x3) TODO: changer a 2
  for i = 1, Constants.DESKS_BY_FLOOR do
    local choices = {}
    --Desk 1, roujours basique
    local r = self:generateDesks(i, 0)
    table.insert(choices, r)
    --Desk 2, basique ou medium
    r = self:generateDesks(i, math.random(0, 1))
    table.insert(choices, r)
    --Desk 3, medium ou hard
    r = self:generateDesks(i, math.random(1, 2))
    table.insert(choices, r)
    --Desk 4, hard
    r = self:generateDesks(i, 2)
    table.insert(choices, r)

    table.insert(self.desks, choices)
  end

  return self
end

function Floor:generateDesks(deskRank, difficulty)
  --Generate money reward
  local baseReward = 1 + deskRank * 2
  --Generate target score
  local targetScore = 0
  --Generate desk number
  local deskNumber = self.floorNumber * 100 + deskRank * 10 + 10 --G.rngEnemies:random(0, 9)

  --Generate target
  if deskRank == 1 then
    targetScore = CalculateTargets.firstOffice(self.floorNumber)
  elseif deskRank == 2 then
    targetScore = CalculateTargets.secondOffice(self.floorNumber)
  end

  --Rareté des rewards
  local c = 79
  local u = 20
  local r = 1

  if difficulty == 1 then
    c = 0
    u = 70
    r = 25
  elseif difficulty == 2 then
    c = 0
    u = 25
    r = 75
  end

  local r = Round:new(
    1,
    self.floorNumber,
    deskNumber,
    self.run.gameCanvas,
    self.run,
    baseReward,
    targetScore,
    self.run.diceObjects,
    Constants.ROUND_TYPES.BASE,
    self:generateReward(c, u, r, deskRank),
    difficulty or 0
  )
  r.roundType = Constants.ROUND_TYPES.BASE

  --Récompenses fixes pour les rounds de tutorial
  if self.run.tutorial then
    --Premier round : Turnns
    if self.run.floorNumber == 1 and deskRank == 1 then
      r.ciggieReward = CiggieTypes.Turnns:new()
    end
    --Deuxième round : Ebb
    if self.run.floorNumber == 1 and deskRank == 2 then
      r.ciggieReward = CiggieTypes.Ebb:new()
    end
  end

  return r
end

function Floor:generateBoss()
  local baseReward = 7
  local targetScore = CalculateTargets.manager(self.floorNumber)

  local deskNumber = self.floorNumber * 100 + 99

  local r = Round:new(
    1,
    self.floorNumber,
    deskNumber,
    self.run.gameCanvas,
    self.run,
    baseReward,
    targetScore,
    self.run.diceObjects,
    Constants.ROUND_TYPES.BOSS,
    self:generateReward(0, 70, 30, 3)
  )
  r.roundType = Constants.ROUND_TYPES.BOSS

  return r
end

function Floor:generateReward(c, u, r, deskrank)
  --Cas de tutorial, premier round, premier etage
  print(self.run.roundNumber)
  if self.run.tutorial and self.floorNumber == 1 and deskrank == 1 then
    return {
      FaceTypes.MassiveDice:new(6, 10),
      FaceTypes.GoldDice:new(4, 10),
    }
  end

  local common = c or 75
  local uncommon = u or 20
  local rare = r or 5 --Les parametres représentent le pourcentage de chances d'avoir un common, uncommon, ou rare
  return {
    GenerateRandom.faceObjectReward({ "WhiteDice" }, common, uncommon, rare),
    GenerateRandom.faceObjectReward({ "WhiteDice" }, common, uncommon, rare),
  }
end

return Floor
