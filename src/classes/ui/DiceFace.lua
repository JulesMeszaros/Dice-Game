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
    self.baseSize = size
    self.size = self.baseSize

    return self
end

function DiceFace:draw()
    shadow = self:renderShadow()
    render = self:render()

    love.graphics.draw(shadow, self.x+10, self.y+10, 0, 1, 1, render:getWidth()/2, render:getHeight()/2)
    love.graphics.draw(render, self.x, self.y, 0, 1, 1, render:getWidth()/2, render:getHeight()/2)

end

function DiceFace:render()
    canvasSize = self.size --sets the base face of the canvas

    ratio = canvasSize/self.dim --ratio between the image size and the canvas size

    faceCanvas = love.graphics.newCanvas(canvasSize, canvasSize) -- create the canvas
    
    --General settings
    faceCanvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(faceCanvas)

    --Draw the face image
    love.graphics.draw(self.spriteSheet, self.quad, 0, 0, 0, ratio, ratio) -- add the image

    if(self:isHovered())then
        -- Apply dark filter
        love.graphics.setColor(0, 0, 0, 0.25)  -- black with 50% opacity
        love.graphics.rectangle("fill", 0, 0, faceCanvas:getWidth(), faceCanvas:getHeight())
        love.graphics.setColor(1,1,1,1)  -- black with 50% opacity
    end

    love.graphics.setCanvas()
    return faceCanvas
end

function DiceFace:renderShadow()
    canvasSize = self.size --sets the base face of the canvas
    ratio = canvasSize/self.dim --ratio between the image size and the canvas size
    shadowCanvas = love.graphics.newCanvas(canvasSize, canvasSize) -- create the canvas

    --General settings
    shadowCanvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(shadowCanvas)

    love.graphics.setColor(0, 0, 0, 0.25)  -- black with 50% opacity
    love.graphics.rectangle("fill", 0, 0, shadowCanvas:getWidth(), shadowCanvas:getHeight())
    love.graphics.setColor(1,1,1,1)  -- black with 50% opacity

    love.graphics.setCanvas()
    return shadowCanvas

end

function DiceFace:isHovered() --Check if mouse is above the face
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
        self:selectOrDeselect()
        wasClicked = true
    end

    return wasClicked
end

function DiceFace:updateSize()
    if(self:getIsSelected())then
        self.size = self.baseSize + (self.baseSize/100)*20
    else
        self.size = self.baseSize
    end 
end

--Get/set Functions--
function DiceFace:getX()
    return self.x
end

function DiceFace:getY()
    return self.y
end

function DiceFace:setSelected(state)
    self.isSelected = state
    self:updateSize()
end

function DiceFace:selectOrDeselect()
    self:setSelected(not self:getIsSelected())
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