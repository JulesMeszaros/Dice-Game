local CiggieObject = {}
CiggieObject.__index = CiggieObject

function CiggieObject:new()
    local self = setmetatable({}, CiggieObject)

    self.name = "Cigarette"
    self.description = "Donne le cancer askiiiip"

    return self
end

function CiggieObject:effect()
    print("Clope fumée")
end

return CiggieObject