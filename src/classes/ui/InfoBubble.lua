local Fonts = require("src.utils.Fonts")
local Sprites = require("src.utils.Sprites")
local AnimationUtils = require("src.utils.scripts.Animations")
local UI = require("src.utils.scripts.UI")
local Shaders = require("src.utils.shaders")

local InfoBubble = {}
InfoBubble.__index = InfoBubble

local lineWidth = 320

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

    self.gridDim = 50

    self.quads = {
        love.graphics.newQuad(0, 0, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Coin superieur gauche
        love.graphics.newQuad(self.gridDim*2, 0, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Coin superieur droit
        love.graphics.newQuad(0, self.gridDim*2, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Coin inferieur gauche
        love.graphics.newQuad(self.gridDim*2, self.gridDim*2, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Coin inferieur droit
        love.graphics.newQuad(self.gridDim, 0, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Bordure haute
        love.graphics.newQuad(self.gridDim*2, self.gridDim, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Bordure droite
        love.graphics.newQuad(0, self.gridDim, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Bordure gauche
        love.graphics.newQuad(self.gridDim, self.gridDim*2, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Bordure basse
        love.graphics.newQuad(self.gridDim, self.gridDim, self.gridDim, self.gridDim, self.baseSprite:getDimensions()), --Centre
    }

    self:generateCanvas(self.width, self.height)

    self.hoveredObject = nil

    return self
end

function InfoBubble:update(dt)
    self.time = self.time + dt
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    self.previousObject = self.object
    self.object = self.screen.currentlyHoveredFace

    if(self.previousObject ~= self.object)then
        self:generateBubble()
    end

    --On dessine les angles
    love.graphics.draw(self.baseSprite, self.quads[1], 0, 0)
    love.graphics.draw(self.baseSprite, self.quads[2], self.canvas:getWidth()-self.gridDim, 0)
    love.graphics.draw(self.baseSprite, self.quads[3], 0, self.canvas:getHeight()-self.gridDim)
    love.graphics.draw(self.baseSprite, self.quads[4], self.canvas:getWidth()-self.gridDim, self.canvas:getHeight()-self.gridDim)

    --On dessine les cotés
    love.graphics.draw(self.baseSprite, self.quads[6], self.width-self.gridDim, self.gridDim, 0, 1, self.hr)
    love.graphics.draw(self.baseSprite, self.quads[7], 0, self.gridDim, 0, 1, self.hr)

    love.graphics.draw(self.baseSprite, self.quads[5], self.gridDim, 0, 0,  self.wr,1)
    love.graphics.draw(self.baseSprite, self.quads[8], self.gridDim, self.height-self.gridDim, 0, self.wr, 1)

    love.graphics.draw(self.baseSprite, self.quads[9], self.gridDim, self.gridDim, 0, self.wr, self.hr)
    
    --On dessine la description
    if(self.object.representedObject.type == "Dice Face") then
        self:drawDiceDescription()
    end

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
    --shadow
    love.graphics.setShader(Shaders.black)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.draw(self.canvas, x-3, y+12 + AnimationUtils.osccilate(self.time, 3, 6), 0, 1, 1, ox, oy)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader()
    love.graphics.draw(self.canvas, x, y + AnimationUtils.osccilate(self.time, 3, 6), 0, 1, 1, ox, oy)

end

function InfoBubble:generateCanvas(w, h)
    self.canvas = love.graphics.newCanvas(w, h)

    --Calcul de la taille/ratio des sprites à afficher
    self.hr = (self.height - 2*(self.gridDim))/self.gridDim --ratio de la taille pour les sprites de coté
    self.wr = (self.width - 2*(self.gridDim))/self.gridDim --ratio de la taille pour les sprites superieurs et inferieurs

end

function InfoBubble:generateBubble()
    self.time = 0
    --Name
    local name = love.graphics.newText(Fonts.soraName, self.object.representedObject.name)

    --Description
    local descriptionText = self.object.representedObject:getDescription(self.screen.run)
    local textW, wrappedText = Fonts.soraDesc:getWrap(descriptionText, math.max(name:getWidth()+40, 350))
    local textLines = {}
    for i,line in next,wrappedText do
        local lineText = love.graphics.newText(Fonts.soraDesc, line)
        table.insert(textLines, lineText)
    end

    --Creation des dimmensions
    local width = math.max(name:getWidth()+40, 350)
    local height = 100 + table.getn(wrappedText)*30 + 20

    self.name = name
    self.width, self.height = width, height
    self:generateCanvas(width, height)
end

function InfoBubble:drawDiceDescription()
    
    --Rarity icon
    if(self.object.representedObject.tier == "Common") then
        love.graphics.draw(Sprites.COMMON, self.canvas:getWidth()/2, 55, 0, 1, 1, Sprites.COMMON:getWidth()/2, 0)
    elseif(self.object.representedObject.tier == "Uncommon") then
        love.graphics.draw(Sprites.UNCOMMON, self.canvas:getWidth()/2, 55, 0, 1, 1, Sprites.UNCOMMON:getWidth()/2, 0)
    elseif(self.object.representedObject.tier == "Rare") then
        love.graphics.draw(Sprites.RARE, self.canvas:getWidth()/2, 55, 0, 1, 1, Sprites.RARE:getWidth()/2, 0)
    end

    --Text
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(self.name, self.canvas:getWidth()/2, 5, 0, 1, 1, self.name:getWidth()/2, 0)


    local formatedText = UI.Text.drawFormattedText(self.object.representedObject:getDescription(self.screen.run), self.canvas:getWidth()/2, 100, Fonts.soraDesc, lineWidth, true)

    love.graphics.setColor(1, 1, 1)
end

return InfoBubble