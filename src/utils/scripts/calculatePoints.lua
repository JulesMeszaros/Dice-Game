local Dice = require("src.classes.Dice")

local CalculatePoints = {}

function CalculatePoints.numberBasePoints(number)
    return number
end

function CalculatePoints.brelanBasePoints()
    return 1
end

function CalculatePoints.fullBasePoints()
    return 2
end

function CalculatePoints.carreBasePoints()
    return 3
end

function CalculatePoints.pttSuiteBasePoints()
    return 4
end

function CalculatePoints.gdSuiteBasePoints()
    return 4
end

function CalculatePoints.chanceBasePoints()
    return 4
end

function CalculatePoints.yatzeeBasePoints()
    return 5
end

return CalculatePoints