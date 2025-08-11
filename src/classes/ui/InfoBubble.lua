local Fonts = require("src.utils.Fonts")
local Sprites = require("src.utils.Sprites")

local InfoBubble = {}
InfoBubble.__index = InfoBubble

function InfoBubble:new(screen)
    local self = setmetatable({}, InfoBubble)

    self.time = 0
    self.screen = screen

    --Position/Scale
    self.x = 0
    self.y = 0
    self.position = 0 -- 0 : under, 1 : above, 2: left, 3 : right


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

    self.previousObject = self.object
    self.object = self.screen.currentlyHoveredFace

    if(self.previousObject ~= self.object)then
        self:generateBubble()
    end

    print(self.canvas:getWidth(), self.canvas:getHeight())

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

    --Text
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(self.name, self.canvas:getWidth()/2, 15, 0, 1, 1, self.name:getWidth()/2, 0)
    for i,line in next,self.wrappedText do
        love.graphics.draw(line, self.canvas:getWidth()/2, 60+(i-1)*30, 0, 1, 1, line:getWidth()/2, 0)
    end

    love.graphics.setColor(1, 1, 1)

    love.graphics.setCanvas(currentCanvas)
end

function InfoBubble:draw()
    local x, y, ox, oy = self.x, self.y, 0, 0
    if(self.position == 0) then
        x = x
        y = y+70
        ox = self.canvas:getWidth()/2
        oy = 0
    end

    love.graphics.draw(self.canvas, x, y, 0, 1, 1, ox, oy)
end

function InfoBubble:reset()

end

function InfoBubble:generateCanvas(w, h)
    self.canvas = love.graphics.newCanvas(w, h)

    --Calcul de la taille/ratio des sprites à afficher
    self.hr = (self.height - 2*(30))/30 --ratio de la taille pour les sprites de coté
    self.wr = (self.width - 2*(30))/30 --ratio de la taille pour les sprites superieurs et inferieurs

end

function InfoBubble:generateBubble()
    --Name
    local name = love.graphics.newText(Fonts.soraDesc, self.object.representedObject.name)

    --Description
    local textW, wrappedText = Fonts.soraDesc:getWrap(self.object.representedObject.description, 320)
    local textLines = {}
    for i,line in next,wrappedText do
        local lineText = love.graphics.newText(Fonts.soraDesc, line)
        table.insert(textLines, lineText)
    end

    --Creation des dimmensions
    local width = math.max(name:getWidth(), 350)
    local height = 60 + table.getn(wrappedText)*30 + 15

    self.name = name
    self.wrappedText = textLines
    self.width, self.height = width, height
    self:generateCanvas(width, height)
end

return InfoBubble