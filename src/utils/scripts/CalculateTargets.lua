local CalculateTarget = {}

--Constantes
local firstTarget = 80 --target de base du premier bureau du premier étage
local secondOfficeFactor = 1.3 --facteur multipliant du score du premier bureau de l'étage pour obtenir le deuxieme bureau
local managerFactor = 1.7 --Facteur multipliant pour obtenir le score du manager par rapport au premier bureau de l'étage
local factorPerThreeFloors = 0.3 --Tout les trois étages, le score du premier bureau est multiplié par ce facteur
local baseFloorMultiplier = 1.5

function firstOffice(floor)
    if(floor==1) then
        return 80
    else
        local floorMultiplier = baseFloorMultiplier + (math.floor(floor/3)*factorPerThreeFloors)
        local target = firstOffice(floor-1) * floorMultiplier

        return math.floor(target / 10) * 10
    end
end

CalculateTarget.firstOffice = firstOffice

function secondOffice(floor)
    local baseTarget = firstOffice(floor)
    local target = baseTarget*secondOfficeFactor

    return math.floor(target / 10) * 10
end

CalculateTarget.secondOffice = secondOffice

function manager(floor)
    local baseTarget = firstOffice(floor)
    local target = baseTarget*managerFactor
    
    return math.floor(target / 10) * 10
end

CalculateTarget.manager = manager

return CalculateTarget