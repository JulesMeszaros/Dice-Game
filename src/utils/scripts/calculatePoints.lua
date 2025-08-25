local CalculatePoints = {}

function CalculatePoints.numberBasePoints(number, dices, level)
	--Calcul Pour les nombres simples
	local score = 0
	local usedDices = {}

	for k, d in next, dices do
		if d:getCurrentFaceObject().blank == false then
			if d:getCurrentFaceObject().faceValue == number then
				-- incrementing the score
				score = score + number
				-- adding the dice to the table of dices used for this face
				table.insert(usedDices, d)
			end
		else
			if d:getCurrentFaceObject().name == "Star Dice" then
				score = score + number
			end
			table.insert(usedDices, d)
		end
	end

	score = level * score

	return { score, usedDices }
end

function CalculatePoints.brelanBasePoints(dices, level)
	--Calcul pour le Brelan (3 faces similaires)
	local score = 0
	local usedDices = {}

	local distrib = getValueDistribution(dices)

	local maxDistrib = 0
	local maxDistribN = 0

	for n, v in next, distrib do --get max distributed number
		if v > maxDistrib then
			maxDistrib = v
			maxDistribN = n
		end
	end

	if maxDistrib >= 3 then --On vérifie que le numero le plus représenté est superieur ou égal à 3
		for k, d in next, dices do
			if d:getCurrentFaceObject().blank == false then
				if d:getCurrentFaceObject().faceValue == maxDistribN then
					score = score + d:getCurrentFaceObject().faceValue
					table.insert(usedDices, d)
				end
			else
				table.insert(usedDices, d)
			end
		end
	else
		score = 0
	end

	score = level * score

	return { score, usedDices }
end

function CalculatePoints.fullBasePoints(dices, level)
	local score = 0
	local usedDices = {}

	local distrib = getValueDistribution(dices)

	--On vérifie qu'on a a la fois une face présente 3 fois et une autre présente 2 fois
	hasFull = hasAllValues(distrib, { 3, 2 })

	if hasFull then
		score = 25

		for dice, f in next, dices do
			table.insert(usedDices, f)
		end
	end

	score = level * score

	return { score, usedDices }
end

function CalculatePoints.carreBasePoints(dices, level)
	local score = 0
	local usedDices = {}

	local maxDistrib = 0
	local maxDistribN = 0

	local distrib = getValueDistribution(dices)

	for n, v in next, distrib do --get max distributed number
		if v > maxDistrib then
			maxDistrib = v
			maxDistribN = n
		end
	end

	if maxDistrib >= 4 then --On vérifie que le numero le plus représenté est superieur ou égal à 3
		for dice, d in next, dices do
			if d:getCurrentFaceObject().blank == false then
				if d:getCurrentFaceObject().faceValue == maxDistribN then
					score = score + d:getCurrentFaceObject().faceValue
					table.insert(usedDices, d)
				end
			else
				table.insert(usedDices, d)
			end
		end
	else
		score = 0
	end

	score = level * score

	return { score, usedDices }
end

function CalculatePoints.pttSuiteBasePoints(dices, level)
	local score = 0
	local usedDices = {}
	local drawedNumbers = {}

	for f, n in next, dices do
		if n:getCurrentFaceObject().blank == false then
			table.insert(drawedNumbers, n:getCurrentFaceObject().faceValue)
		end
	end

	local suite = getStraight(drawedNumbers, 4)
	--Ajouter une condition pour ne pas compter deux fois un meme nombre
	if suite then
		score = 30
		for dice, f in next, dices do
			if f:getCurrentFaceObject().blank == false then
				for i, j in next, suite do
					if f:getCurrentFaceObject().faceValue == j then
						table.insert(usedDices, f)
					end
				end
			else
				table.insert(usedDices, f)
			end
		end
	else
		score = 0
	end

	score = level * score

	return { score, usedDices }
end

function CalculatePoints.gdSuiteBasePoints(dices, level)
	local score = 0
	local usedDices = {}
	local drawedNumbers = {}

	for f, n in next, dices do
		if n:getCurrentFaceObject().blank == false then
			table.insert(drawedNumbers, n:getCurrentFaceObject().faceValue)
		end
	end

	local suite = getStraight(drawedNumbers, 5)

	if suite then
		score = 40
		for dice, j in next, dices do
			table.insert(usedDices, j)
		end
	else
		score = 0
	end

	score = level * score

	return { score, usedDices }
end

function CalculatePoints.chanceBasePoints(dices, level)
	local score = 0
	local usedDices = {}

	for k, d in next, dices do
		if d:getCurrentFaceObject().blank == false then
			score = score + d:getCurrentFaceObject().faceValue
			table.insert(usedDices, d)
		else
			table.insert(usedDices, d)
		end
	end

	score = level * score

	return { score, usedDices }
end

function CalculatePoints.yatzeeBasePoints(dices, level)
	local score = 0
	local usedDices = {}

	local maxDistrib = 0
	local maxDistribN = 0

	distrib = getValueDistribution(dices)

	for n, v in next, distrib do --get max distributed number
		if v > maxDistrib then
			maxDistrib = v
			maxDistribN = n
		end
	end

	if maxDistrib >= 5 then --On vérifie que le numero le plus représenté est superieur ou égal à 3
		score = 50
		for d, f in next, dices do
			table.insert(usedDices, f)
		end
	else
		score = 0
	end

	score = level * score

	return { score, usedDices }
end

--==UTILS==--

function getValueDistribution(tbl)
	local distribution = {}

	for _, dice in pairs(tbl) do
		if dice:getCurrentFaceObject().blank == false then
			distribution[dice:getCurrentFaceObject().faceValue] = (
				distribution[dice:getCurrentFaceObject().faceValue] or 0
			) + 1
		end
	end

	return distribution
end

function hasValue(tbl, valueToCheck)
	for _, value in pairs(tbl) do
		if value == valueToCheck then
			return true
		end
	end
	return false
end

function hasAllValues(tbl, valuesToCheck)
	for _, v in ipairs(valuesToCheck) do
		if not hasValue(tbl, v) then
			return false
		end
	end
	return true
end

function getStraight(numbers, targetLength)
	-- Étape 1 : créer un set pour ignorer les doublons
	local present = {}
	local minVal, maxVal = math.huge, -math.huge
	for _, n in ipairs(numbers) do
		present[n] = true
		if n < minVal then
			minVal = n
		end
		if n > maxVal then
			maxVal = n
		end
	end

	-- Étape 2 : chercher une suite
	for start = minVal, maxVal - targetLength + 1 do
		local sequence = {}
		for i = start, start + targetLength - 1 do
			if present[i] then
				table.insert(sequence, i)
			else
				break
			end
		end
		if #sequence == targetLength then
			return sequence
		end
	end

	return nil
end

return CalculatePoints

