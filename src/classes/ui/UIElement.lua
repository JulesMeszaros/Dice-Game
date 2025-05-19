local UIElement = {}
UIElement.__index = { sprite = nil }

function UIElement:new()
    local self = setmetatable({}, UIElement)

    --Parametres d'interractions
    self.isSelectable = false
    self.isHoverable = false

    --Position
    self.x = 0
    self.y = 0

    --Graphic parameters
    self.width = 0
    self.height = 0

    return self
end

function UIElement:draw()
    shadow = self:renderShadow()
    render = self:renderSprite()
    love.graphics.draw(shadow, self.x+10, self.y+10, 0, 1, 1, render:getWidth()/2, render:getHeight()/2)
    love.graphics.draw(render, self.x, self.y, 0, 1, 1, render:getWidth()/2, render:getHeight()/2)

end

function UIElement:renderSprite()
    canvasHeight = self.height
    canvasWidth = self.width

    canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)

    --General settings
    canvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(canvas)

    widthRatio = self.width/self.sprite:getWidth()
    heightRatio = self.height/self.sprite:getHeight()

    --Draw the UI into the canvas
    love.graphics.draw(self.sprite, 0, 0, 0, widthRatio, heightRatio) -- add the image

    love.graphics.setCanvas()

    return canvas
end

function UIElement:renderShadow()
    canvasHeight = self.height
    canvasWidth = self.width
    shadowCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight) -- create the canvas

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

--Interractions function--

function UIElement:isHovered()
    return(
        love.mouse:getX() > (self.x-(self.width/2)) and love.mouse:getX() < (self.x+(self.width/2))
        and
        love.mouse:getY() > (self.y-(self.height/2)) and love.mouse:getY() < (self.y+(self.height/2))
        )
end

function UIElement:clickEvent()
    wasClicked = false -- Variable retournée : vrai si le dé a été cliqué, faux si le dé n'a pas été clické
    
    if(self:isHovered()) then
        wasClicked = true
    end

    return wasClicked
end


--Get/set Functions--

function UIElement:setSprite(sprite)
    self.sprite = sprite
end

function UIElement:getIsSelected()
    return self.isSelected
end

function UIElement:setSelectable(state)
    self.isSelectable = state
end

function UIElement:setHoverable(state)
    self.isHoverable = state
end

function UIElement:getSelectable()
    return self.isSelectable
end

function UIElement:selectOrDeselect()
    self:setSelected(not self:getIsSelected())
end

function UIElement:setHoverable()
    return self.isHoverable
end

function UIElement:setSelected(state)
    self.isSelected = state
end

function UIElement:setX(x)
    self.x = x
end

function UIElement:setY(y)
    self.y = y
end

function UIElement:getX()
    return self.x
end

function UIElement:getY()
    return self.y
end

function UIElement:setWidth(w)
    self.width = w
end

function UIElement:setHeight(h)
    self.height = h
end

return UIElement