local Dice = require("src.classes.FaceTypes.Dice")

local CalculatePoints = {}

function CalculatePoints.numberBasePoints(number, faces, dices, drawedDices)
    --Calcul Pour les nombres simples
    
    local score = 0
    local usedDices = {}

    for dice,f in next,drawedDices do
        if(f==number)then
             -- incrementing the score
            score = score + number
            -- adding the dice to the table of dices used for this face
            table.insert(usedDices, dice) 
        end
    end
    
    return {score, usedDices}
end

function CalculatePoints.brelanBasePoints(faces, dices, drawedDices)
    --Calcul pour le Brelan (3 faces similaires)
    local score = 0
    local usedDices = {}

    local distrib = getValueDistribution(drawedDices)

    local maxDistrib = 0
    local maxDistribN = 0

    for n,v in next,distrib do --get max distributed number
        if v > maxDistrib then
            maxDistrib = v
            maxDistribN = n
        end
    end

    if(maxDistrib>=3)then --On vérifie que le numero le plus représenté est superieur ou égal à 3
        for dice,f in next,drawedDices do
            score = score + f
            table.insert(usedDices, dice)
        end
    else
        score = 0
    end

    return {score, usedDices}
end

function CalculatePoints.fullBasePoints(faces, dices, drawedDices)
    local score = 0
    local usedDices = {}

    distrib = getValueDistribution(drawedDices)

    --On vérifie qu'on a a la fois une face présente 3 fois et une autre présente 2 fois
    hasFull = hasAllValues(distrib, {3, 2})

    if(hasFull)then
        score = 25

        for dice,f in next,drawedDices do
            table.insert(usedDices, dice)
        end
    end
    
    return {score, usedDices}
end

function CalculatePoints.carreBasePoints(faces, dices, drawedDices)
    local score = 0
    local usedDices = {}

    local maxDistrib = 0
    local maxDistribN = 0

    distrib = getValueDistribution(drawedDices)

    for n,v in next,distrib do --get max distributed number
        if v > maxDistrib then
            maxDistrib = v
            maxDistribN = n
        end
    end

    if(maxDistrib>=4)then --On vérifie que le numero le plus représenté est superieur ou égal à 3
        for dice,f in next,drawedDices do
            score = score + f
            if(f==maxDistribN)then
                table.insert(usedDices, dice)
            end
        end
    else
        score = 0

    end

    return {score, usedDices}
end

function CalculatePoints.pttSuiteBasePoints(faces, dices, drawedDices)
    local score = 0
    local usedDices = {}

    drawedNumbers = {}
    for f,n in next,drawedDices do
        table.insert(drawedNumbers, n)
    end

    suite = getStraight(drawedNumbers, 4)

    if(suite)then
        score = 30
        for i,j in next,suite do
            for dice,f in next,drawedDices do
                if(f==j)then
                    table.insert(usedDices, dice)
                end
            end
        end
    else 
        score = 0
    end

    return {score, usedDices}
end

function CalculatePoints.gdSuiteBasePoints(faces, dices, drawedDices)
    local score = 0
    local usedDices = {}

    drawedNumbers = {}
    for f,n in next,drawedDices do
        table.insert(drawedNumbers, n)
    end

    suite = getStraight(drawedNumbers, 5)

    if(suite)then
        score = 40
        for dice,j in next,drawedDices do
            table.insert(usedDices, dice)
        end
    else 
        score = 0
    end

    return {score, usedDices}
end

function CalculatePoints.chanceBasePoints(faces, dices, drawedDices)
    local score = 0
    local usedDices = {}

    for dice,f in next,drawedDices do
        score = score + f
        table.insert(usedDices, dice)
    end

    return {score, usedDices}
end

function CalculatePoints.yatzeeBasePoints(faces, dices, drawedDices)
    local score = 0
    local usedDices = {}

    local maxDistrib = 0
    local maxDistribN = 0

    distrib = getValueDistribution(drawedDices)

    for n,v in next,distrib do --get max distributed number
        if v > maxDistrib then
            maxDistrib = v
            maxDistribN = n
        end
    end

    if(maxDistrib>=5)then --On vérifie que le numero le plus représenté est superieur ou égal à 3
        score = 50
        for dice,f in next,drawedDices do
            table.insert(usedDices, dice)
        end
    else
        score = 0

    end

    return {score, usedDices}
end

--==UTILS==--

function getValueDistribution(tbl)
    local distribution = {}

    for _, value in pairs(tbl) do
        if type(value) == "number" then
            distribution[value] = (distribution[value] or 0) + 1
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
        if n < minVal then minVal = n end
        if n > maxVal then maxVal = n end
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