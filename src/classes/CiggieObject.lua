local CiggieObject = {}
CiggieObject.__index = CiggieObject

function CiggieObject:new()
    local self = setmetatable({}, CiggieObject)
    self.name = "Cigarette"
    self.description = "Donne le cancer askiiiip"
    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/basicCiggie.png")
    return self
end

function CiggieObject:trigger(round)
    self:effect(round)
end

function CiggieObject:effect(round)
    print("Clope fumée")
end

return CiggieObject