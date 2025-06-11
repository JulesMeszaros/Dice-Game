local DiceObject = {}
DiceObject.__index = DiceObject

function DiceObject:new(faces)
    local self = setmetatable({}, DiceObject)

    self.faces = faces --Contient les objets faces du dé, qui représente chaque face
    
    --On lie les faces au dé
    for i,f in next,self.faces do
        f:setDiceObject(self)
    end
    
    self.currentActiveFace = 1 --The index of the current active face

    return self
end

function DiceObject:trigger(round)
    --Triggers the current active face function
    self.currentFaceObject:trigger(round)
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
    self.faces[numface]:setDiceObject(self)
end

function DiceObject:setCurrentFaceObject(faceobject)
    self.currentFaceObject = faceobject
end

function DiceObject:getCurrentFaceObject()
    return self.currentFaceObject
end

function DiceObject:getNbFaces()
    return table.getn(self.faces)
end

return DiceObject