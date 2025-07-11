local CiggieObject = {}
CiggieObject.__index = CiggieObject

function CiggieObject:new()
    local self = setmetatable({}, CiggieObject)
    self.name = "Cigarette"
    self.description = "Donne le cancer askiiiip"
    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/basicCiggie.png")
    self.tier = "Clope"
    return self
end

function CiggieObject:trigger(round)
    round.run.totalUsedCiggie = round.run.totalUsedCiggie+1
    print(round.run.totalUsedCiggie)
    self:effect(round)
    self:destruct(round)
end

function CiggieObject:effect(round)
    print("Clope fumée")
end

function CiggieObject:destruct(round)
    for i,v in next,round.run.ciggiesObjects do
        if(v==self)then
            table.remove(round.run.ciggiesObjects, i)
            round.terrain.uiElements.ciggiesUI[v] = nil
        end
    end
end

return CiggieObject