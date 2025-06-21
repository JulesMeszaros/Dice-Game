local CiggieObject = {}
CiggieObject.__index = CiggieObject

function CiggieObject:new()
    local self = setmetatable({}, CiggieObject)

    self.name = "Cigarette"
    self.description = "Donne le cancer askiiiip"
    self.rerolls = math.random(0, 20)
    return self
end

function CiggieObject:effect(round)
    print("Clope fumée")
    round.availableRerolls = self.rerolls
end

return CiggieObject