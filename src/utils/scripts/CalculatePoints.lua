local CalculatePoints = {}

function CalculatePoints.numberBasePoints(number, dices, level)
	local score = 0
	local usedDices = {}

	local left = number - 1
	local right = number + 1

	-- wrap-around
	if left < 1 then
		left = 6
	end
	if right > 6 then
		right = 1
	end

	for k, d in next, dices do
		local face = d:getCurrentFaceObject()

		if face.blank == false then
			local value = face.faceValue

			if value == number then
				score = score + number
				table.insert(usedDices, d)
			elseif G.currentRun.adjacentNumericalDices == true and (value == left or value == right) then
				score = score + number
				table.insert(usedDices, d)
			end
		else
			if face.name == "Star Dice" then
				score = score + number
			end
			table.insert(usedDices, d)
		end
	end

	if G.currentRun.additionalNumericDice == true and score > 0 then
		score = score + number
	end

	score = level * score

	if number == 1 and G.currentRun.onesBaseBonus == true and score > 0 then
		score = score + 50
	end

	if G.currentRun.lastPlayedFigure == number and G.currentRun.consecutiveFigureMult == true then
		score = score * 2
	end

	return { score, usedDices }
end

function CalculatePoints.brelanBasePoints(dices, level)
	local score = 0
	local usedDices = {}

	local distrib = getValueDistribution(dices)

	local maxDistrib = 0
	local maxDistribN = 0

	for n, v in next, distrib do
		if v > maxDistrib then
			maxDistrib = v
			maxDistribN = n
		elseif v == maxDistrib and n > maxDistribN then
			maxDistribN = n
		end
	end

	-- vrai brelan
	if maxDistrib >= 3 then
		for k, d in next, dices do
			if d:getCurrentFaceObject().blank == false then
				if d:getCurrentFaceObject().faceValue == maxDistribN and #usedDices < 3 then
					score = score + d:getCurrentFaceObject().faceValue
					table.insert(usedDices, d)
				end
			else
				table.insert(usedDices, d)
			end
		end

	-- facilitateur : paire = brelan
	elseif G.currentRun.ThreeOAKFaciliter == true and maxDistrib == 2 then
		for k, d in next, dices do
			if d:getCurrentFaceObject().blank == false then
				if d:getCurrentFaceObject().faceValue == maxDistribN and #usedDices < 2 then
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

	if G.currentRun.lastPlayedFigure == 8 and G.currentRun.consecutiveFigureMult == true then
		score = score * 2
	end

	return { score, usedDices }
end

function CalculatePoints.fullBasePoints(dices, level)
	local score = 0
	local usedDices = {}

	local distrib = getValueDistribution(dices)

	-- FULL classique (3 + 2)
	local hasFull = hasAllValues(distrib, { 3, 2 })

	if hasFull then
		score = 25

		for _, dice in pairs(dices) do
			table.insert(usedDices, dice)
		end
	end

	-- THINK DIFFERENT : double paire
	if not hasFull and G.game.run.thinkDifferent == true then
		local pairsValues = {}

		for value, count in pairs(distrib) do
			if count >= 2 then
				table.insert(pairsValues, value)
			end
		end
		-- si on a au moins deux paires
		if #pairsValues >= 2 then
			local sum = 0
			for _, dice in pairs(dices) do
				for _, v in ipairs(pairsValues) do
					if dice:getCurrentFaceObject().faceValue == v then
						table.insert(usedDices, dice)
						break
					end
				end
			end

			score = 25
			print(sum)
		end
	end

	score = score * level

	if G.currentRun.lastPlayedFigure == 10 and G.currentRun.consecutiveFigureMult == true then
		score = score * 2
	end

	return { score, usedDices }
end

function CalculatePoints.carreBasePoints(dices, level)
	local score = 0
	local usedDices = {}

	local distrib = getValueDistribution(dices)

	local maxDistrib = 0
	local maxDistribN = 0

	for n, v in next, distrib do
		if v > maxDistrib then
			maxDistrib = v
			maxDistribN = n
		elseif v == maxDistrib and n > maxDistribN then
			maxDistribN = n
		end
	end

	-- carré normal
	if maxDistrib >= 4 then
		for k, d in next, dices do
			if d:getCurrentFaceObject().blank == false then
				if d:getCurrentFaceObject().faceValue == maxDistribN and #usedDices < 4 then
					score = score + d:getCurrentFaceObject().faceValue
					table.insert(usedDices, d)
				end
			else
				table.insert(usedDices, d)
			end
		end

	-- facilitateur : brelan = carré
	elseif G.currentRun.FourOAKFaciliter == true and maxDistrib == 3 then
		for k, d in next, dices do
			if d:getCurrentFaceObject().blank == false then
				if d:getCurrentFaceObject().faceValue == maxDistribN and #usedDices < 3 then
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

	if G.currentRun.lastPlayedFigure == 9 and G.currentRun.consecutiveFigureMult == true then
		score = score * 2
	end

	return { score, usedDices }
end

function CalculatePoints.pttSuiteBasePoints(dices, level)
	local score = 0
	local usedDices = {}
	local drawedNumbers = {}
	local usedNumbers = { false, false, false, false, false, false }

	for f, n in next, dices do
		if n:getCurrentFaceObject().blank == false then
			table.insert(drawedNumbers, n:getCurrentFaceObject().faceValue)
		end
	end

	local neededLength = 4
	if G.currentRun.smlStraightsFaciliter == true then
		neededLength = 3
	end

	local suite = getStraight(drawedNumbers, neededLength)

	if suite then
		score = 30
		for dice, f in next, dices do
			if f:getCurrentFaceObject().blank == false then
				for i, j in next, suite do
					if
						f:getCurrentFaceObject().faceValue == j
						and usedNumbers[f:getCurrentFaceObject().faceValue] == false
					then
						table.insert(usedDices, f)
						usedNumbers[f:getCurrentFaceObject().faceValue] = true
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

	if G.currentRun.lastPlayedFigure == 11 and G.currentRun.consecutiveFigureMult == true then
		score = score * 2
	end

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
	if G.currentRun.lastPlayedFigure == 12 and G.currentRun.consecutiveFigureMult == true then
		score = score * 2
	end

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
	if G.currentRun.lastPlayedFigure == 7 and G.currentRun.consecutiveFigureMult == true then
		score = score * 2
	end

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

	if G.currentRun.lastPlayedFigure == 13 and G.currentRun.consecutiveFigureMult == true then
		score = score * 2
	end

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
