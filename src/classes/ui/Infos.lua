local Ciggie = require("src/classes/ui/Ciggie")
local Fonts = require("src/utils/Fonts")
local Sprites = require("src/utils/Sprites")
local Constants = require("src/utils/Constants")
local Animator = require("src/utils/Animator")
local Button = require("src/classes/ui/Button")
local Inputs = require("src/utils/scripts/Inputs")
local DiceFace = require("src/classes/ui/DiceFace")
local UI = require("src.utils.scripts.UI")
local InfoBubble = require("src.classes.ui.InfoBubble")

local Infos = {}
Infos.__index = Infos

function Infos:new(run)
    local self = setmetatable({}, Infos)
    self.infoBubble = InfoBubble:new(self)

    self.run = run
    self.round = run.currentRound
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    self.animator = Animator:new(self)

    --UI Canvas
    self.gridLarge = love.graphics.newCanvas(710, 1020)
    self.inventoryLarge = love.graphics.newCanvas(290, 600)
    self.badgeHorizontal = love.graphics.newCanvas(670, 400)
    self.playerBadge = love.graphics.newCanvas(360, 600)
    self.progression = love.graphics.newCanvas(200,830)

    self.roundNumberCanvas = love.graphics.newCanvas(220, 120)
    self.moneyCanvas = love.graphics.newCanvas(220, 120)
    self.rerollsCanvas = love.graphics.newCanvas(220, 120)
    self.handsCanvas = love.graphics.newCanvas(220, 120)
    self.descriptionCanvas = love.graphics.newCanvas(420, 240)
    self.ciggiesTray = love.graphics.newCanvas(220, 460)
    self.ciggiesTrayFront = love.graphics.newCanvas(220, 390)

    --Wavy Texts
    self.moneyWavyText = UI.Text.TextWavy:new("5$", 50, 50, {
        amplitude=2.5,
        speed=2,
        font = Fonts.soraBig,
        revealSpeed=1000,
        centered=true,
        colorStart={255/255, 178/255, 89/255},
        colorEnd={255/255, 178/255, 89/255}

    })

    --UI Positions
    self.gridLX, self.gridLY = 30, 30
    self.inventoryLX, self.inventoryLY = 760, 30
    self.badgeHorizontalX, self.badgeHorizontalY = 760, 650
    self.playerBadgeX, self.playerBadgeY = 1070, 30
    self.progressionX, self.progressionY = 1450, 30
    self.planBtnX, self.planBtnY = 1460+90, 880+40 
    self.menuBtnX, self.menuBtnY = 1460+90, 970+40
   
    self.rerollsX, self.rerollsY = 1670, 310
    self.turnsX, self.turnsY = 1670, 170
    self.moneyX, self.moneyY = 1670, 450
    self.floorX, self.floorY = 1670, 30
    self.descriptionX, self.descriptionY = self.canvas:getWidth()-30, 650

    self.ciggiesTrayX, self.ciggiesTrayY = 1670, 590

    --Buttons
    self.uiElements = {buttons = {}, ciggiesUI={}, inventoryFaces={}, rewardFaces={}}

    self.uiElements.buttons["menuButton"] = Button:new(
        function()print("menu")end,
        "src/assets/sprites/ui/Menu.png",
        self.menuBtnX,
        self.menuBtnY,
        180,
        80,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.buttons["planButton"] = Button:new(
        function()self:fadeOut()end,
        "src/assets/sprites/ui/Infos.png",
        self.planBtnX,
        self.planBtnY,
        180,
        80,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    --

    --Start animations
    self.baseOpacity, self.targetOpacity = 0, 1
    self.opacity = self.baseOpacity
    
    self:createInventory()
    self:generateCiggiesUI()

    if(self.run.currentState == Constants.RUN_STATES.ROUND) then
        self:createRewards()
    end

    self.animator:add('opacity', self.baseOpacity, self.targetOpacity, 0.1)

    return self
end

function Infos:update(dt)
    
end

function Infos:updateCanvas(dt)
    self.animator:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    love.graphics.setColor(40/255, 40/255, 43/255, 1)
    love.graphics.rectangle("fill", 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    --Buttons
    for i,button in next,self.uiElements.buttons do
        button:update(dt)
        button:draw()
    end

    self:drawGridLarge()
    self:drawInventoryLarge()
    self:drawBadgeHorizontal()
    self:drawPlayerBadge()
    self:drawProgression()
    self:drawRoundDetails(dt)

    --faces UI
    for i,faceUI in next,self.uiElements.inventoryFaces do
        faceUI:update(dt)
        faceUI:draw()
    end

    --rewards UI
    for i,faceUI in next,self.uiElements.rewardFaces do

        faceUI:update(dt)
        faceUI:draw()
    end

    self:drawCiggiesTray()

    --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
        ciggie:draw()
    end

    self:drawCiggiesTrayFront()
    self:getCurrentlyHoveredFace()
    
    if(self.currentlyHoveredFace)then
        --Info bubble (wip)
        self.infoBubble.x, self.infoBubble.y = self.currentlyHoveredFace.x + self.currentlyHoveredFace.absoluteX , self.currentlyHoveredFace.y + self.currentlyHoveredFace.absoluteY
        --self.infoBubble.x, self.infoBubble.y = self.currentlyHoveredFace.x , self.currentlyHoveredFace.y
        self.infoBubble:update(dt)
        self.infoBubble:draw()
        
    end

    love.graphics.setCanvas(currentCanvas)
end

function Infos:draw()
    love.graphics.setColor(1, 1, 1, self.opacity)
    love.graphics.draw(self.canvas, 0, 0, 0, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)
end

--==INPUTS FUNCTIONS==--
function Infos:mousemoved(x, y, dx, dy, isDragging)
    --Drag and drop Ciggies
    if(isDragging == true)then 
        for key,ciggie in next, self.uiElements.ciggiesUI do
            if(ciggie.isDraggable and ciggie.isBeingClicked) then
                ciggie.isBeingDragged = true
                self.dragAndDroppedCiggie = ciggie
                ciggie.dragXspeed = dx
                ciggie.targetX = x
                ciggie.targetY = y
                break;
            end
        end
    end

    --Inventory
    if(isDragging == true)then 
        for key,face in next, self.uiElements.inventoryFaces do
            if(face.isDraggable and face.isBeingClicked) then
                face.isBeingDragged = true
                self.dragAndDroppedObject = face
                face.dragXspeed = dx
                face.targetX = (face.targetX + dx)
                face.targetY = (face.targetY + dy)
                break;
            end
        end
    end

    --Inventory
    if(isDragging == true)then 
        for key,face in next, self.uiElements.rewardFaces do
            if(face.isDraggable and face.isBeingClicked) then
                face.isBeingDragged = true
                self.dragAndDroppedObject = face
                face.dragXspeed = dx
                face.targetX = (face.targetX + dx)
                face.targetY = (face.targetY + dy)
                break;
            end
        end
    end
end

function Infos:mousepressed(x, y, button, istouch, presses)
    --Round Buttons
    for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:clickEvent()
    end

    --Inventory
    for key,uiFace in next,self.uiElements.inventoryFaces do
        uiFace:clickEvent()
    end

    --Rewards
    for key,uiFace in next,self.uiElements.rewardFaces do
        uiFace:clickEvent()
    end
end

function Infos:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    --Inventory
    for key,face in next,self.uiElements.inventoryFaces do
        local wasReleased = face:releaseEvent()
        face.isBeingDragged = false

        face.targetX = face.anchorX
        face.targetY = face.anchorY
    end

    --Inventory
    for key,face in next,self.uiElements.rewardFaces do
        local wasReleased = face:releaseEvent()
        face.isBeingDragged = false

        face.targetX = face.anchorX
        face.targetY = face.anchorY
    end

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:releaseEvent()
        ciggie.isBeingDragged = false
    end
end

--UI functions
function Infos:drawGridLarge()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.gridLarge)
    love.graphics.clear()

    --Background
    love.graphics.draw(Sprites.GRID_LARGE, 0, 0)

    --Lines content
    love.graphics.setColor(108/255, 86/255,113/255, 1)
    for figure, i in next,Constants.FIGURES do
        --Playcount
        local playcountText = love.graphics.newText(Fonts.soraGridL, "Played : "..tostring(self.run.figuresInfos[i].playcount))
        love.graphics.draw(playcountText,355, 70*(i-1)+125, 0, 1, 1, playcountText:getWidth()/2, playcountText:getHeight()/2)
        --Level
        local levelText = love.graphics.newText(Fonts.soraGridL, "Level : "..tostring(self.run.figuresInfos[i].level))
        love.graphics.draw(levelText,225, 70*(i-1)+125, 0, 1, 1, levelText:getWidth()/2, levelText:getHeight()/2)

        --Base points
        local basePoints = love.graphics.newText(Fonts.soraGridL, " - ")
        love.graphics.draw(basePoints,490, 70*(i-1)+125, 0, 1, 1, basePoints:getWidth()/2, basePoints:getHeight()/2)

    end
    love.graphics.setColor(1,1,1,1)


    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.gridLarge, self.gridLX, self.gridLY)
end

function Infos:drawInventoryLarge()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.inventoryLarge)
    love.graphics.clear()

    love.graphics.draw(Sprites.INVENTORY_MEDIUM, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.inventoryLarge, self.inventoryLX, self.inventoryLY)
end

function Infos:drawBadgeHorizontal()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.badgeHorizontal)
    love.graphics.clear()
    --Office description
    if(self.run.currentState == Constants.RUN_STATES.ROUND) then
        love.graphics.draw(Sprites.OFFICE_DESCRIPTION, 0, 0)

        --Enemy face
        self.run.currentRound.enemyCharacter:draw(150, 245, 250, 250)

        --Texts
        local jobDeskText = love.graphics.newText(Fonts.soraLightMini, 'Office '..tostring(self.run.currentRound.deskNumber).." - "..tostring(self.run.currentRound.enemyJob))
        local targetText = love.graphics.newText(Fonts.soraReward, 'Target : '..tostring(self.run.currentRound.targetScore).."pts")

        love.graphics.draw(jobDeskText, self.badgeHorizontal:getWidth()/2 ,85, 0, 1, 1, jobDeskText:getWidth()/2, jobDeskText:getHeight()/2)
        love.graphics.setColor(91/255, 113/255, 254/255)
        love.graphics.draw(targetText, 480 ,35, 0, 1, 1, targetText:getWidth()/2, targetText:getHeight()/2)
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.badgeHorizontal, self.badgeHorizontalX, self.badgeHorizontalY)
end

function Infos:drawPlayerBadge()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.playerBadge)
    love.graphics.clear()

    love.graphics.draw(Sprites.PLAYER_BADGE, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.playerBadge, self.playerBadgeX, self.playerBadgeY)
end

function Infos:drawProgression()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.progression)
    love.graphics.clear()

    love.graphics.draw(Sprites.PROGRESSION, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.progression, self.progressionX, self.progressionY)
end

function Infos:drawRoundDetails(dt)
    local currentCanvas = love.graphics.getCanvas()
    --Create the texts
    local rerollText = love.graphics.newText(Fonts.soraBig, '-')
    local currentHands = love.graphics.newText(Fonts.soraBig, '-')
    local currentRoundText = love.graphics.newText(Fonts.soraSmall, 'Floor '..tostring(self.run.floorNumber)..'\nDesk : '..tostring("-"))
    local moneyText = tostring(self.run.money).."$"

    if(self.round) then
        rerollText = love.graphics.newText(Fonts.soraBig, tostring(self.round.availableRerolls))
        currentHands = love.graphics.newText(Fonts.soraBig, tostring(self.round.remainingHands))
        currentRoundText = love.graphics.newText(Fonts.soraSmall, 'Floor '..tostring(self.round.floorNumber)..'\nDesk : '..tostring(self.round.deskNumber))
    end

    --ROUND
    love.graphics.setCanvas(self.roundNumberCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.FLOOR_INFOS, 0, 0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(currentRoundText, self.roundNumberCanvas:getWidth()/2, self.roundNumberCanvas:getHeight()/2, 0, 1, 1, currentRoundText:getWidth()/2, currentRoundText:getHeight()/2)
    love.graphics.setColor(1, 1, 1, 1)
    --HANDS
    love.graphics.setCanvas(self.handsCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.TURNS, 0, 0)
    love.graphics.setColor(245/255, 247/255, 228/255, 1)
    love.graphics.draw(currentHands, self.handsCanvas:getWidth()/2, self.handsCanvas:getHeight()/2+27, 0, 1, 1, currentHands:getWidth()/2, currentHands:getHeight()/2+3)
    love.graphics.setColor(1, 1, 1, 1)

    --REROLLS
    love.graphics.setCanvas(self.rerollsCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.REROLLS, 0, 0)
    love.graphics.setColor(245/255, 247/255, 228/255, 1)
    love.graphics.draw(rerollText, self.rerollsCanvas:getWidth()/2, self.rerollsCanvas:getHeight()/2+27, 0, 1, 1, rerollText:getWidth()/2, rerollText:getHeight()/2+3)
    love.graphics.setColor(1, 1, 1, 1)

    --MONEY
    love.graphics.setCanvas(self.moneyCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.MONEY,0,0)
    
    self.moneyWavyText.x = self.moneyCanvas:getWidth()/2
    self.moneyWavyText.y = self.moneyCanvas:getHeight()/2
    self.moneyWavyText.text = moneyText

    self.moneyWavyText:update(dt)
    self.moneyWavyText:draw()


    --DRAW ALL THE CANVAS
    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.roundNumberCanvas, self.floorX, self.floorY)
    love.graphics.draw(self.handsCanvas, self.turnsX, self.turnsY)
    love.graphics.draw(self.rerollsCanvas, self.rerollsX, self.rerollsY)
    love.graphics.draw(self.moneyCanvas, self.moneyX, self.moneyY)
end

function Infos:drawCiggiesTray()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.ciggiesTray)

    love.graphics.draw(Sprites.MAGIC_WANDS, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.ciggiesTray, self.ciggiesTrayX, self.ciggiesTrayY, 0, 1, 1)
end

function Infos:drawCiggiesTrayFront()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.ciggiesTrayFront)

    love.graphics.draw(Sprites.MAGIC_WANDS_FRONT, 0, self.ciggiesTrayFront:getHeight(), 0, 1, 1, 0, Sprites.MAGIC_WANDS_FRONT:getHeight())

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.ciggiesTrayFront, self.ciggiesTrayX, self.ciggiesTrayY + self.ciggiesTray:getHeight() -self.ciggiesTrayFront:getHeight(), 0, 1, 1, 0, 0)
end

--Hovered objects
function Infos:getCurrentlyHoveredFace()
    self.currentlyHoveredFace = nil
    --Reward faces
    for i,face in next,self.uiElements.rewardFaces do
        if(face:isHovered()) then self.currentlyHoveredFace = face ; return end
    end
    --Inventory Faces
    for i,face in next,self.uiElements.inventoryFaces do
        if(face:isHovered()) then self.currentlyHoveredFace = face ; return end
    end
end

--==Hover functions==--
function Infos:getCurrentlyHoveredCiggie()
    self.currentlyHoveredCiggie = nil
    --Inventaire
    for i,ciggie in next,self.uiElements.ciggiesUI do
        if(ciggie:isHovered())then
            self.currentlyHoveredCiggie = ciggie
            break
        end
    end
end

function Infos:getCurrentlyHoveredObject()
    self:getCurrentlyHoveredCiggie()
    self:getCurrentlyHoveredFace()

    if(self.currentlyHoveredFace) then
        return self.currentlyHoveredFace.representedObject
    elseif(self.currentlyHoveredCiggie)then
        return self.currentlyHoveredCiggie.representedObject
    else
        return nil
    end
end



--Start/END

function Infos:generateCiggiesUI()
    self.uiElements.ciggiesUI = {}

    --calculate the xPosistions
    local xPos = self:getSpacedPositions(table.getn(self.run.ciggiesObjects), 1680, 1880)

    for i,ciggie in next,self.run.ciggiesObjects do
        
        local c = Ciggie:new(ciggie, xPos[i], 780, true, true, function()return Inputs.getMouseInCanvas(0, 0)end, self.round)
        c.baseRotation, c.rotation, c.targetedRotation = 1.57, 1.57, 1.57
        self.uiElements.ciggiesUI[ciggie] = c
    end
end

function Infos:createInventory()
    local xPos = {20, 150, 20, 150, 20, 150, 20, 150}
    local yPos = {70, 70, 200, 200, 330, 330, 460, 460}

    for i,face in next,self.run.facesInventory do
        --Create the UIFaces


        local faceUI = DiceFace:new(
                nil,
                face,
                xPos[i] + 60+ self.inventoryLX,
                yPos[i] + self.inventoryLY + 60,
                120,
                false,
                true,
                function()return Inputs.getMouseInCanvas(0, 0)end,
                nil
            )

        faceUI.anchorX = xPos[i] + 60+ self.inventoryLX
        faceUI.anchorY = yPos[i] + 60+ self.inventoryLY

        table.insert(self.uiElements.inventoryFaces, faceUI)
    end
end

function Infos:createRewards()
local xPos = {350, 500}
    local yPos = {140, 140}

    for i,face in next,self.run.currentRound.faceRewards do
        --Create the UIFaces

        local faceUI = DiceFace:new(
                nil,
                face,
                xPos[i] + 60+ self.badgeHorizontalX,
                yPos[i] + 60+ self.badgeHorizontalY,
                120,
                false,
                true,
                function()return Inputs.getMouseInCanvas(0, 0)end,
                nil
            )

        faceUI.anchorX = xPos[i] + 60+ self.badgeHorizontalX
        faceUI.anchorY = yPos[i] + 60+ self.badgeHorizontalY

        table.insert(self.uiElements.rewardFaces, faceUI)
    end
end

function Infos:fadeOut()
    self.animator:add('opacity', self.opacity, self.baseOpacity, 0.1, nil, function()self.run:toggleInfoScreen()end)
end

--UTILS

function Infos:getSpacedPositions(count, x1, x2)
    local positions = {}

    local totalWidth = x2 - x1

    if count == 1 then
        table.insert(positions, (x1 + x2) / 2)
    else
        local spacing = totalWidth / count

        for i = 0, count - 1 do
            local x = x1 + spacing / 2 + i * spacing
            table.insert(positions, x)
        end
    end

    return positions
end

return Infos