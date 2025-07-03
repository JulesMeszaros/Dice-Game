local CiggieTypes = require("src.classes.CiggieTypes")

local GenerateRandom = {}

--Generate random Ciggie
function GenerateRandom.CiggieObject()
    --Get the list of keys
    local keys = {}
    for key, _ in pairs(CiggieTypes) do
        table.insert(keys, key)
    end

    local randomCiggieKey = keys[math.random(#keys)]
    local randomCiggieType = CiggieTypes[randomCiggieKey] --On récupère une face type au hasard

    local randomCiggieObject = randomCiggieType:new()

    return randomCiggieObject
end

return GenerateRandom