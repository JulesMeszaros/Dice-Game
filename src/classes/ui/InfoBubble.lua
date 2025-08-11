local Sprites = require("src.utils.Sprites")

local InfoBubble = {}
InfoBubble.__index = InfoBubble

function InfoBubble:new()
    local self = setmetatable({}, InfoBubble)

    self.time = 0

    --Position/Scale
    self.x = 0
    self.y = 0


    self.width = 300
    self.height = 200

    self.baseSprite = Sprites.BUBBLE

    self.quads = {
        love.graphics.newQuad(0, 0, 30, 30, self.baseSprite:getDimensions()), --Coin superieur gauche
        love.graphics.newQuad(60, 0, 30, 30, self.baseSprite:getDimensions()), --Coin superieur droit
        love.graphics.newQuad(0, 60, 30, 30, self.baseSprite:getDimensions()), --Coin inferieur gauche
        love.graphics.newQuad(60, 60, 30, 30, self.baseSprite:getDimensions()), --Coin inferieur droit
        love.graphics.newQuad(30, 0, 30, 30, self.baseSprite:getDimensions()), --Bordure haute
        love.graphics.newQuad(60, 30, 30, 30, self.baseSprite:getDimensions()), --Bordure droite
        love.graphics.newQuad(0, 30, 30, 30, self.baseSprite:getDimensions()), --Bordure gauche
        love.graphics.newQuad(30, 60, 30, 30, self.baseSprite:getDimensions()), --Bordure basse
        love.graphics.newQuad(30, 30, 30, 30, self.baseSprite:getDimensions()), --Centre
    }

    self:generateCanvas(self.width, self.height)

    self.hoveredObject = nil

    return self
end

function InfoBubble:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    --On dessine les angles
    love.graphics.draw(self.baseSprite, self.quads[1], 0, 0)
    love.graphics.draw(self.baseSprite, self.quads[2], self.canvas:getWidth()-30, 0)
    love.graphics.draw(self.baseSprite, self.quads[3], 0, self.canvas:getHeight()-30)
    love.graphics.draw(self.baseSprite, self.quads[4], self.canvas:getWidth()-30, self.canvas:getHeight()-30)

    --On dessine les cotés
    love.graphics.draw(self.baseSprite, self.quads[6], self.width-30, 30, 0, 1, self.hr)
    love.graphics.draw(self.baseSprite, self.quads[7], 0, 30, 0, 1, self.hr)

    love.graphics.draw(self.baseSprite, self.quads[5], 30, 0, 0,  self.wr,1)
    love.graphics.draw(self.baseSprite, self.quads[8], 30, self.height-30, 0, self.wr, 1)

    love.graphics.draw(self.baseSprite, self.quads[9], 30, 30, 0, self.wr, self.hr)



    love.graphics.setCanvas(currentCanvas)
end

function InfoBubble:draw()
    love.graphics.draw(self.canvas, self.x, self.y)
end

function InfoBubble:reset()

end

function InfoBubble:generateCanvas(w, h)
    self.canvas = love.graphics.newCanvas(w, h)

    --Calcul de la taille/ratio des sprites à afficher
    self.hr = (self.height - 2*(30))/30 --ratio de la taille pour les sprites de coté
    self.wr = (self.width - 2*(30))/30 --ratio de la taille pour les sprites superieurs et inferieurs

end

return InfoBubble