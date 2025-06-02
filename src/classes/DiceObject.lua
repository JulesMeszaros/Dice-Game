local DiceObject = {}
DiceObject.__index = DiceObject

function DiceObject:new(faces)
    local self = setmetatable({}, DiceObject)

    self.faces = faces --Contient les objets faces du dé, qui représente chaque face
    self.currentActiveFace = 1 --The index of the current active face

    return self
end

--==GET/SET FUNCTIONS==--
function DiceObject:getFace(numFace)
    return self.faces[numFace]
end

function DiceObject:getAllFaces()
    return self.faces
end

function DiceObject:setFace(face, numface) --replaces one of the dice's faces by a new one
    self.faces[numface] = face
end

function DiceObject:setCurrentActiveFace(n)
    self.currentActiveFace = n
end

function DiceObject:getCurrentActiveFace()
    return self.currentActiveFace
end

function DiceObject:getNbFaces()
    return table.getn(self.faces)
end

return DiceObject