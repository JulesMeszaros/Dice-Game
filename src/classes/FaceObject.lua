--[[
    This class represents the basic white dice face.
    It is used as the default class for every dice faces, who inherits
    from this one.
]]

local FaceObject = {}
FaceObject.__index = FaceObject

function FaceObject:new()
    local self = setmetatable({}, FaceObject)

    self.type = "Dice Face"

    --Metadatas about the FaceObject
    self.name = "FACE OBJECT"
    self.id = 0
    self.tier = "??"
    self.description = "???"

    --Metadatas about the graphics of the FaceObject
    self.spriteSheet = love.graphics.newImage("src/assets/sprites/dices/Base Dice.png")
    self.spriteSheet:setFilter("linear", "linear")
    self.faceDimmension = 120 --sets the dimmensions for a face of the FaceObject in px (in the png)
    self.faceSpritesCoordinates = { --dict for the coordinate of the different faces in the spritesheet
        {120, 120}, -- 1
        {0, 120}, -- 2
        {120, 240}, -- 3
        {120, 0}, -- 4
        {240, 120}, -- 5
        {120, 360} -- 6
    }
    
    --Booleans status
    self.disabled = false
    --About the type of effects the dice has
    self.backup = false
    self.ghost = false
    self.replay = false
    self.blank = false
    self.fullHand = false
    self.fullDice = false
    self.first = false
    self.unique = false

    --Numbered status
    self.faceValue = 1 --This is the face represented by the face (the number shown)
    self.pointsValue = 0 --This is the points scored by the dice
    self.totalTriggered = 0
    self.roundTriggered = 0
    return self
end

--==Trigger functions==--

function FaceObject:resetStats()
    self.roundTriggered = 0
    self.disabled = false
end

function FaceObject:update(dt, run)

end

function FaceObject:trigger(round)
    --Incrémente les variables numériques
    self.totalTriggered = self.totalTriggered + 1
    self.roundTriggered = self.roundTriggered + 1
    
    --Déclenche l'effet first si possible
    if(self.first == true) then
        local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)
        if(self == dicesOrder[1]:getCurrentFaceObject())then
            self:firstEffect(round)
        end
    end

    --Déclenche l'effet replay si possible
    if(self.roundTriggered>1 and self.replay==true) then
        self:replayEffect(round)
    end
    
    --Declanche l'effet fullHand si possible
    if(self.fullHand) then
        local fullHand = true
        local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)
        for i,dice in next,dicesOrder do
            if(dice:getCurrentFaceObject().name ~= self.name) then
                fullHand = false
            end
        end

        if(fullHand == true) then
            self:fullHandEffect(round)
        end
    end

    --Declanche l'effet unique si possible
    if(self.unique) then
        local unique = true
        local facesOrder, dicesOrder = round:getDicesOrder(round.usedDices)
        for i,dice in next,dicesOrder do
            if(dice:getCurrentFaceObject()~=self and dice:getCurrentFaceObject().name==self.name)then
                unique=false;                 
                break
            end
        end

        if(unique==true)then
            self:uniqueEffect(round)
        end
    end

    --Déclenche l'effet de trigger
    self:triggerEffect(round)
end

function FaceObject:triggerBackup(round, uiFace)
    -- Pour l'effet backup
    self:backupEffect(round)
    uiFace.animator:addDelay(0.0, function()uiFace.targetedScale = 1 ; uiFace.round:triggerNextBackupDice()end)

end

--Triggers effects

function FaceObject:triggerEffect(round)
    --Complementary effect triggered by the face
    return
end

function FaceObject:backupEffect(round)
    print("backup!", self.name, self.faceValue)
end

function FaceObject:fullHandEffect(round)
    print('full!')
end

function FaceObject:replayEffect(round)
    print('replay')
end

function FaceObject:uniqueEffect(round)
    --Effect that triggers only if the dice is the only dice this type in scored hand
    print("unique")
end

function FaceObject:firstEffect(round)
    --Effet qui se trigger si le dé est le scoré le plus à gauche
end

--Sprite
function FaceObject:getSpriteSheet()
    return self.spriteSheet
end

function FaceObject:getQuad(i)
    quad = love.graphics.newQuad(
            self.faceSpritesCoordinates[i][1], self.faceSpritesCoordinates[i][2],     -- x, y dans l'image source
            200, 200,     -- largeur, hauteur de la portion
            self.spriteSheet:getDimensions()  -- taille totale de l'image
        )
    return quad
end

function FaceObject:getFaceDim()
    return self.faceDimmension
end

function FaceObject:setDiceObject(diceObject)
    self.diceObject = diceObject
end

function FaceObject:setFacePoints(n)
    self.pointsValue = n
end

function FaceObject:getDescription(run)
    return self.description
end

function FaceObject:getPointsValue(run)
    return self.pointsValue
end

return FaceObject