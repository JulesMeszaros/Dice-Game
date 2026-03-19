local Names = require("src.utils.Names")
local CiggieTypes = require("src.classes.CiggieTypes")

local GenerateRandom = {}

--Convertion de text vers seed
function GenerateRandom.stringToSeed(str)
	local hash = 5381 -- constante DJB2
	for i = 1, #str do
		hash = ((hash * 33) + string.byte(str, i)) % 4294967296
	end
	return hash
end

function GenerateRandom.randomSeedText()
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local result = ""

	for i = 1, 8 do
		local randomIndex = math.random(1, #chars)
		result = result .. string.sub(chars, randomIndex, randomIndex)
	end

	return result
end

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

function GenerateRandom.generateUniqueNumbers(min, max, n, method)
	local numbers = {}
	local pool = {}
	for i = min, max do
		table.insert(pool, i)
	end
	for i = 1, n do
		if #pool == 0 then
			break
		end
		local idx = math.random(1, #pool)
		table.insert(numbers, pool[idx])
		table.remove(pool, idx)
	end
	return numbers
end

function GenerateRandom.generateUniqueNumbersShop(min, max, n)
	local numbers = {}
	local pool = {}
	for i = min, max do
		table.insert(pool, i)
	end
	for i = 1, n do
		if #pool == 0 then
			break
		end
		local idx = G.rngShop:random(1, #pool)
		table.insert(numbers, pool[idx])
		table.remove(pool, idx)
	end
	return numbers
end

function GenerateRandom.faceObjectReward(forbiddenKeys, c, u, r) --Les parametres c u r representent respectivement la proba d'avoir une face common, uncommon, ou rare.
	local commonRate = c or 75
	local uncommonRate = u or 20
	local rareRate = r or 5
	local totalRate = commonRate + uncommonRate + rareRate

	local randomRarity = G.rngEnemies:random(1, 100)
	local listToPick = G.commonDices
	if randomRarity <= (commonRate / totalRate) * 100 then
		listToPick = G.commonDices
	elseif randomRarity <= ((commonRate + uncommonRate) / totalRate) * 100 then
		listToPick = G.uncommonDices
	else
		listToPick = G.rareDices
	end

	--Get the list of keys
	local keys = {}
	for key, _ in pairs(listToPick) do
		local isForbidden = false
		for i, fk in next, forbiddenKeys do
			if fk == _ then
				isForbidden = true
			end
		end

		if isForbidden == false then
			table.insert(keys, _)
		end
	end

	local k = G.rngEnemies:random(1, #keys)
	local randomFaceKey = keys[G.rngEnemies:random(1, k)]
	local randomFaceType = G.faceTypes[randomFaceKey] --On récupère une face type au hasard
	local randomFaceValue = G.rngEnemies:random(1, 6) --La face numérique

	local randomFaceObject = randomFaceType:new(randomFaceValue, 10)

	return randomFaceObject
end

function GenerateRandom.sorted(list)
	table.sort(list, function(a, b)
		return a < b
	end)
	return list
end

function GenerateRandom.faceObjectShop(forbiddenKeys, c, u, r) --Les parametres c u r representent respectivement la proba d'avoir une face common, uncommon, ou rare.
	local commonRate = c or 75
	local uncommonRate = u or 20
	local rareRate = r or 5
	local totalRate = commonRate + uncommonRate + rareRate

	local randomRarity = G.rngShop:random(1, 100)
	local listToPick = G.commonDices
	if randomRarity <= (commonRate / totalRate) * 100 then
		listToPick = G.commonDices
	elseif randomRarity <= ((commonRate + uncommonRate) / totalRate) * 100 then
		listToPick = G.uncommonDices
	else
		listToPick = G.rareDices
	end

	--Get the list of keys
	local keys = {}
	for key, _ in pairs(listToPick) do
		local isForbidden = false
		for i, fk in next, forbiddenKeys do
			if fk == _ then
				isForbidden = true
			end
		end

		if isForbidden == false then
			table.insert(keys, _)
		end
	end

	local randomFaceKey = keys[G.rngShop:random(#keys)]
	local randomFaceType = G.faceTypes[randomFaceKey] --On récupère une face type au hasard
	local randomFaceValue = G.rngShop:random(1, 6) --La face numérique

	local randomFaceObject = randomFaceType:new(randomFaceValue, 10)

	return randomFaceObject
end

function GenerateRandom.name()
	local prenomPrefix = Names.Prefixs[math.random(#Names.Prefixs)]
	local prenomSuffix = Names.Suffixes[math.random(#Names.Suffixes)]
	local nomPrefix = Names.Prefixs[math.random(#Names.Prefixs)]
	local nomSuffix = Names.Suffixes[math.random(#Names.Suffixes)]

	return prenomPrefix .. prenomSuffix .. " " .. nomPrefix .. nomSuffix
end
return GenerateRandom
