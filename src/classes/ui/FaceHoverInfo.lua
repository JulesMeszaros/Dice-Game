local Fonts = require("src.utils.fonts")
local Animator = require("src.utils.Animator")

local FaceHoverInfo = {}
FaceHoverInfo.__index = FaceHoverInfo

function FaceHoverInfo:new(face)
    local self = setmetatable({}, FaceHoverInfo)
    self.animator = Animator:new(self)
    self.face= face
    self.opacity = 0
    self.x = face.x
    self.y = face.y + 70
    local canvasWidth = 350
    
    self.titleText = love.graphics.newText(Fonts.nexaSmall, self.face.representedFace.name)
    self.descWidth, self.descWrappedtext = Fonts.nexaDesc:getWrap(self.face.representedFace.description, canvasWidth-18)

    --On calcule la hauteur du canvas
    local canvasHeight = 40+(table.getn(self.descWrappedtext))*25+10

    self.canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)

    self.animator:add("opacity", 0, 1, 0.1)

    return self
end

function FaceHoverInfo:update(dt)
    self.animator:update(dt)
    self:updateCanvas(dt)
end

function FaceHoverInfo:draw()
    love.graphics.setColor(1, 1, 1, self.opacity)
    love.graphics.draw(self.canvas, self.x, self.y, 0, 1, 1, self.canvas:getWidth()/2)
    love.graphics.setColor(1, 1, 1, 1)
end

function FaceHoverInfo:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    --Background
    love.graphics.rectangle("fill", 0, 0, self.canvas:getWidth(), self.canvas:getHeight(), 20, 20)

    love.graphics.setColor(0, 0, 0, 1)
    --Dice title
    love.graphics.draw(self.titleText, self.canvas:getWidth()/2, 5, 0, 1, 1, self.titleText:getWidth()/2)
    --Dice description
    for i,line in next,self.descWrappedtext do
        local lineText = love.graphics.newText(Fonts.nexaDesc, line)
        love.graphics.draw(lineText, self.canvas:getWidth()/2, 40+(i-1)*25, 0, 1, 1, lineText:getWidth()/2)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(currentCanvas)
end

return FaceHoverInfo