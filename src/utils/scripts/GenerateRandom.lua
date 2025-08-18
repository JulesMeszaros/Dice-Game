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

function GenerateRandom.generateUniqueNumbers(min, max, n)
    local numbers = {}
    local pool = {}
    for i = min, max do
        table.insert(pool, i)
    end
    for i = 1, n do
        if #pool == 0 then break end
        local idx = math.random(1, #pool)
        table.insert(numbers, pool[idx])
        table.remove(pool, idx)
    end
    return numbers
end

return GenerateRandom