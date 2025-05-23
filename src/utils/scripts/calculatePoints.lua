local Dice = require("src.classes.Dice")
local Run = require("src.classes.Run")

local CalculatePoints = {}

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

function CalculatePoints.chanceBasePoints()
    return 4
end

function CalculatePoints.yatzeeBasePoints()
    return 5
end

return CalculatePoints