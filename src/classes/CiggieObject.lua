local CiggieObject = {}
CiggieObject.__index = CiggieObject

function CiggieObject:new()
    local self = setmetatable({}, CiggieObject)

    self.name = "Cigarette"
    self.description = "Donne le cancer askiiiip"

    return self
end

function CiggieObject:effect(round)
    print("Clope fumée")
    round.availableRerolls = 100
end

return CiggieObject