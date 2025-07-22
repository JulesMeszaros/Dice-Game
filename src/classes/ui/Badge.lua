local Shaders = require("src.utils.Shaders")
local Fonts = require("src.utils.Fonts")
local Animator = require("src.utils.Animator")
local AnimationUtils = require("src.utils.scripts.Animations")
local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")
local DiceFace = require("src.classes.ui.DiceFace")
local UIElement = require("src.classes.ui.UIElement")
local Inputs = require("src.utils.scripts.Inputs")
local badgeSprite = love.graphics.newImage("src/assets/sprites/ui/Badge.png")

local Badge = setmetatable({}, { __index = UIElement })
Badge.__index = Badge

function Badge:new(
    round, 
    x, 
    y,
    originalY,
    width, 
    height,
    mousePosition)

    local self = setmetatable(UIElement.new(), Badge)
    self.animator = Animator:new(self)

    self:setX(x)
    self:setY(originalY)

    self.sprite = badgeSprite


    self.height = height
    self.width = width
    self.targetedScale = 1

    --Hover options
    self.isHoverable = true
    self.mousePosition = mousePosition

    --Dragging options
    self.isDraggable = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0

    self.round = round

    --Create the canvas ONCE
    self.uiCanvas = self:createCanvas()

    self:createFaceRewards()

    self.animator:addDelay(0.1)
    self.animator:addGroup({
        {property = "y", from = self.y, targetValue = y, duration = 0.5, easing = AnimationUtils.Easing.outCubic}
    })

    return self
end

function Badge:update(dt)
    self.animator:update(dt)
    self:getCurrentlyHoveredFace()

    if(self:isHovered())then
        self.targetedScale = 0.95
        if(love.mouse.isDown(1) and self.isActivated) then
            self.targetedScale = 0.90
        end
    else
        self.targetedScale = 1
    end

    local speed = 30
    self.scale = self.scale + (self.targetedScale - self.scale)*speed*dt

    --update the Badge canvas
    self:updateCanvas(dt)
end

function Badge:createCanvas(gameCanvas)
    local canvas = love.graphics.newCanvas(self.width, self.height)

    --General settings
    canvas:setFilter("linear", "linear")
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(canvas)

    love.graphics.setCanvas(gameCanvas)

    return canvas
end

function Badge:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.uiCanvas)
    love.graphics.clear()
    love.graphics.setShader(Shaders.grayRainbowShader)
    Shaders.grayRainbowShader:send("time", 4*self.scale)
    Shaders.grayRainbowShader:send("frequency", 0.3)
    Shaders.grayRainbowShader:send("intensity", 0.3)
    love.graphics.draw(self.sprite, 0, 0) -- add the background

    --Lion
    self.round.enemyCharacter:update(dt)
    self.round.enemyCharacter:draw(185, 191, 200, 200)

    love.graphics.setShader()

    

    --Texts
    local nameText = love.graphics.newText(Fonts.soraDesc, "Jean Michel Lionnel.le")
    local jobDeskText = love.graphics.newText(Fonts.soraLightMini, 'Office '..tostring(self.round.deskNumber).." - "..tostring(self.round.enemyJob))
    local targetText = love.graphics.newText(Fonts.soraLightMini, 'Target Score : '..tostring(self.round.targetScore))
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(nameText, self.uiCanvas:getWidth()/2, 25, 0, 1, 1, nameText:getWidth()/2, 0)
    love.graphics.draw(jobDeskText, self.uiCanvas:getWidth()/2, 60, 0, 1, 1, jobDeskText:getWidth()/2, 0)
    love.graphics.draw(targetText, self.uiCanvas:getWidth()/2, 322, 0, 1, 1, targetText:getWidth()/2, targetText:getHeight()/2)

    love.graphics.setColor(1, 1, 1, 1)

    

    self:updateFaceCanvas(dt)

    love.graphics.setCanvas(currentCanvas)
end

function Badge:draw()
    
    love.graphics.draw(self.uiCanvas, self.x+self.uiCanvas:getWidth()/2, self.y+self.uiCanvas:getHeight()/2, 0, self.scale, self.scale, self.uiCanvas:getWidth()/2, self.uiCanvas:getHeight()/2)
end

function Badge:isHovered() --Check if mouse is above the face
    --Utilise la fonction passée en paramètre, qui permet d'avoir la position de la souris dans laquelle elle est rendue.
    local vx, vy = self.mousePosition().x, self.mousePosition().y

    return(
        self.isHoverable and
        vx > (self.x) and vx < (self.x+(self.width))
        and
        vy > (self.y) and vy < (self.y+(self.height))
        )
end

function Badge:createFaceRewards()
    local xPos = self:getCenteredPositions(table.getn(self.round.faceRewards), 120, 20, self.uiCanvas:getWidth()/2+60)
    self.faceRewards = {}
    for i,faceReward in next,self.round.faceRewards do
        local diceFace = DiceFace:new(nil,
                                    faceReward,
                                    xPos[i],
                                    408,
                                    100,
                                    false,
                                    true,
                                    function()return Inputs.getMouseInCanvas(self.x, self.y)end,
                                    nil)
        table.insert(self.faceRewards, diceFace)
    end
end

function Badge:updateFaceCanvas(dt)
    for i,uiFace in next,self.faceRewards do
        uiFace:update(dt)
        uiFace:draw()
    end
end

--==Utils==--
function Badge:getCurrentlyHoveredFace()
    self.previouslyHoveredFace = self.currentlyHoveredFace
    self.currentlyHoveredFace = nil
    
    for i,uiFace in next,self.faceRewards do
        if uiFace:isHovered() then self.currentlyHoveredFace = uiFace ; break end
    end

    --Si un dé est survolé et qu'il est différent du dé précédent alors on créé un nouveau canvas d'infos
    if(self.currentlyHoveredFace ~= self.previouslyHoveredFace) then
        if (self.currentlyHoveredFace) then
            self.hoverInfosCanvas = FaceHoverInfo:new(self.currentlyHoveredFace, "points", 0, 0)
        end
    end
end

function Badge:getCenteredPositions(count, objectWidth, spacing, centerX)
    local totalWidth = count * objectWidth + (count - 1) * spacing
    local startX = centerX - totalWidth / 2

    local positions = {}
    for i = 0, count - 1 do
        local x = startX + i * (objectWidth + spacing)
        table.insert(positions, x)
    end

    return positions
end

return Badge