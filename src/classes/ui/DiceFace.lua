--Classe servant à afficher une face de dé, avec ses propriétés et ses effets et ses interractions

local DiceFace = {}
DiceFace.__index = DiceFace

function DiceFace:new(dice, face, x, y, size, isSelectable, isHoverable)
    local self = setmetatable({}, DiceFace)

    --Parametres d'interractions
    self.isSelectable = true
    self.isHoverable = true

    self.isSelected = false --Etat de sélection de la face

    self.dice = dice -- sets the dice and the face it represents
    self.face = face
    self.spriteSheet = dice:getSpriteSheet()
    self.quad = dice:getQuad(face)
    self.dim = dice:getFaceDim()
    self.x = x
    self.y = y
    self.size = size

    return self
end

function DiceFace:draw()
    ratio = self.size/self.dim

    if(self.isSelected) then
        love.graphics.setColor(0, 1, 0, 1)
    end

    if(self:isHovered()) then
        love.graphics.setColor(1, 1, 1, 0.75)
    end

    love.graphics.draw(self.spriteSheet, self.quad, self.x, self.y, 0, ratio, ratio, self.dim/2, self.dim/2)
    love.graphics.setColor(1, 1, 1, 1)
end

function DiceFace:isHovered()
    if(not self.isHoverable) then
        return false
    end
    
    if(
        (love.mouse.getX() > self:getX()-(self.size/2)) 
        and 
        (love.mouse.getX() < (self:getX() + (self.size/2)))
        and
        (love.mouse.getY() > self:getY()-(self.size/2)) 
        and 
        (love.mouse.getY() < (self:getY() + (self.size/2)))
    )
    then
        return true
    else
        return false
    end
    
end

function DiceFace:clickEvent()
    wasClicked = false -- Variable retournée : vrai si le dé a été cliqué, faux si le dé n'a pas été clické
    
    if(self:isHovered()) then
        --print("Face clicked : " .. self.face)
        self:selectOrDeselect()
        --print("This face is selected : "..tostring(self.isSelected))
        --print("Associated dice : " ..tostring(self.dice))
        wasClicked = true
    end

    return wasClicked
end

--Get/set Functions--
function DiceFace:getX()
    return self.x
end

function DiceFace:getY()
    return self.y
end

function DiceFace:setSelected(state)
    self.isSelected(state)
end

function DiceFace:selectOrDeselect()
    self.isSelected = (not self.isSelected) and (self.isSelectable)
end

function DiceFace:setSelectable(state)
    self.isSelectable = state
end

function DiceFace:setHoverable(state)
    self.isHoverable = state
end

function DiceFace:getSelectable()
    return self.isSelectable
end

function DiceFace:setHoverable()
    return self.isHoverable
end

function DiceFace:getDice()
    return self.dice
end

function DiceFace:getFace()
    return self.face
end

function DiceFace:getIsSelected()
    return self.isSelected
end

return DiceFace