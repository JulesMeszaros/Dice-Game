local GameScreen = {}
GameScreen.__index = GameScreen

function GameScreen:new()
    local self = setmetatable({}, GameScreen)

    return self
end

function GameScreen:update(dt)

end

function GameScreen:updateCanvas(dt)

end

function GameScreen:draw()

end

--==Input Functions==--

--==Hovered Elements==--
function GameScreen:getCurrentlyHoveredFace()
    self.previouslyHoveredFace = self.currentlyHoveredFace --We save the state of the frame before
    self.currentlyHoveredFace = nil

    for i,face in next,self.infoFaces do
        if face:isHovered() then self.currentlyHoveredFace = face ; break end
    end

    for i,badge in next,self.badges do
        if(badge.currentlyHoveredFace) then self.currentlyHoveredFace = badge.currentlyHoveredFace ; break end
    end

    --Si un dé est survolé et qu'il est différent du dé précédent alors on créé un nouveau canvas d'infos
    if(self.currentlyHoveredFace ~= self.previouslyHoveredFace) then
        if (self.currentlyHoveredFace) then
            self.hoverInfosCanvas = self:createFaceInfosCanvas(self.currentlyHoveredFace)
        end
    end

end

return GameScreen