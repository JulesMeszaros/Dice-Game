local DiceObject = {}
DiceObject.__index = DiceObject

function DiceObject:new(faces)
    self.faces = faces --Contient les objets faces du dé, qui représente chaque face
end

return DiceObject