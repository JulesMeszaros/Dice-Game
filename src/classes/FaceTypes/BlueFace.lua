local WhiteFace = require("src.classes.FaceTypes.WhiteFace")

local BlueFace = setmetatable({}, { __index = WhiteFace })
BlueFace.__index = BlueFace

function BlueFace:new(faceValue, pointsValue)
    local self = setmetatable(WhiteFace:new(), BlueFace)

    --Metadatas about the WhiteFace
    self.name = "Blue Face"
    self.tier = "Uncommon"
    self.id = 2
    self.description = "Triggers the previously triggered dice again (doesn't work with other Blue Faces)"

    --Metadatas about the graphics of the WhiteFace
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/BlueDiceTileset120.png")
    self.spriteSheet:setFilter("nearest", "nearest")

    self.faceDimmension = 120 --sets the dimmensions for a face of the WhiteFace in px (in the png)

    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    --Round status
    self.faceValue = faceValue --Le numéro de face que le dé représente
    self.pointsValue = pointsValue --This is the points scored by the dice
    self.totalTriggered = 0

    return self
end

function BlueFace:triggerEffect(round)
    --On rettriger le dé précédement trigger, s'il n'est pas un blue face
    if(table.getn(round.triggerDiceHistory) > 0 and round.triggerDiceHistory[table.getn(round.triggerDiceHistory)].currentFaceObject.name ~= "Blue Face") then
        table.insert(round.dicesTriggerQueue, 2, round.triggerDiceHistory[table.getn(round.triggerDiceHistory)])
        table.insert(round.diceFacesTriggerQueue, 2, round.triggerFaceHistory[table.getn(round.triggerFaceHistory)])
    end
end

function getAllData(t, prevData)
  -- if prevData == nil, start empty, otherwise start with prevData
  local data = prevData or {}

  -- copy all the attributes from t
  for k,v in pairs(t) do
    data[k] = data[k] or v
  end

  -- get t's metatable, or exit if not existing
  local mt = getmetatable(t)
  if type(mt)~='table' then return data end

  -- get the __index from mt, or exit if not table
  local index = mt.__index
  if type(index)~='table' then return data end

  -- include the data from index into data, recursively, and return
  return getAllData(index, data)
end

return BlueFace