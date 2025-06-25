local Fonts = require("src.utils.Fonts")
local Animator = require("src.utils.Animator")

local FaceHoverInfo = {}
FaceHoverInfo.__index = FaceHoverInfo

function FaceHoverInfo:new(face, wich, canvasX, canvasY)
    local self = setmetatable({}, FaceHoverInfo)
    self.animator = Animator:new(self)
    --Detailed canvas
    self.face= face
    self.opacity = 0
    self.x = face.x + canvasX
    self.y = face.y + 70 + canvasY
    local canvasWidth = 350
    
    self.titleText = love.graphics.newText(Fonts.nexaSmall, self.face.representedObject.name)
    self.descWidth, self.descWrappedtext = Fonts.nexaDesc:getWrap(self.face.representedObject.description, canvasWidth-18)

    --On calcule la hauteur du canvas
    local canvasHeight = 40+(table.getn(self.descWrappedtext))*25+10

    self.canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
    self.animator:add("opacity", 0, 1, 0.1)

    --Simple canvas (only points)
    self.sx = face.x + 1000
    self.sy = face.y + canvasHeight + 80

    self.pointsText = love.graphics.newText(Fonts.nexaDesc, "+"..tostring(face.representedObject.pointsValue).." pts")

    local smallCanvasWidth = self.pointsText:getWidth()+30
    local smallCanvasHeight = self.pointsText:getHeight()+30

    self.smallCanvas = love.graphics.newCanvas(smallCanvasWidth, smallCanvasHeight)

    --Sets wich canvas is shown or hidden
    self.shownCanvas = wich


    return self
end

function FaceHoverInfo:update(dt)
    self.animator:update(dt)    
    self:updateSmallCanvas(dt)
end

function FaceHoverInfo:draw(wherepoints)
    local offsetX = 0
    local offsetY = 0
    if(wherepoints == "above")then
        offsetY = -190
    end

    love.graphics.setColor(1, 1, 1, self.opacity)
    --Draw the canvas id they are supposed to be shown
    love.graphics.draw(self.smallCanvas, self.x, self.y+offsetY, 0, 1, 1, self.smallCanvas:getWidth()/2)
    
    love.graphics.setColor(1, 1, 1, 1)
end

function FaceHoverInfo:updateSmallCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.smallCanvas)
    love.graphics.clear()
    --Background
    love.graphics.rectangle("fill", 0, 0, self.smallCanvas:getWidth(), self.smallCanvas:getHeight(), 20, 20)
    love.graphics.setColor(0, 0, 0, 1)
    
    --Update the y position depending on wich canvas are shown
    self.sx = self.face.x
    if(self.shownCanvas == "points") then
        self.sy = self.face.y + 70
    else
        self.sy = self.face.y + self.canvas:getHeight() + 80
    end

    --Text 
    love.graphics.draw(self.pointsText, self.smallCanvas:getWidth()/2, self.smallCanvas:getHeight()/2, 0, 1, 1, self.pointsText:getWidth()/2, self.pointsText:getHeight()/2)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(currentCanvas)
end

return FaceHoverInfo