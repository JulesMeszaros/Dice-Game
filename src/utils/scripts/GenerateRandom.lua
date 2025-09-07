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
		if #pool == 0 then
			break
		end
		local idx = math.random(1, #pool)
		table.insert(numbers, pool[idx])
		table.remove(pool, idx)
	end
	return numbers
end

function GenerateRandom.faceObject(forbiddenKeys)
	local randomRarity = math.random(1, 100)
	local listToPick = G.commonDices
	if randomRarity <= 75 then
		listToPick = G.commonDices
	elseif randomRarity <= 95 then
		listToPick = G.uncommonDices
	else
		listToPick = G.rareDices
	end

	--Get the list of keys
	local keys = {}
	for key, _ in pairs(listToPick) do
		local isForbidden = false
		for i, fk in next, forbiddenKeys do
			if fk == key then
				isForbidden = true
			end
		end

		if isForbidden == false then
			table.insert(keys, _)
		end
	end

	local randomFaceKey = keys[math.random(#keys)]
	local randomFaceType = G.faceTypes[randomFaceKey] --On récupère une face type au hasard
	local randomFaceValue = math.random(1, 6) --La face numérique

	local randomFaceObject = randomFaceType:new(randomFaceValue, 10)

	print(randomRarity, randomFaceKey, randomFaceValue)

	return randomFaceObject
end

return GenerateRandom

