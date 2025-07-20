local Ciggie = require("src/classes/ui/Ciggie")
local Fonts = require("src/utils/Fonts")
local Sprites = require("src/utils/Sprites")
local Constants = require("src/utils/Constants")
local Animator = require("src/utils/Animator")
local Button = require("src/classes/ui/Button")
local Inputs = require("src/utils/scripts/Inputs")

local Infos = {}
Infos.__index = Infos

function Infos:new(run)
    local self = setmetatable({}, Infos)

    self.run = run
    self.round = run.currentRound
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    self.animator = Animator:new(self)

    --UI Canvas
    self.gridLarge = love.graphics.newCanvas(720, 670)
    self.inventoryLarge = love.graphics.newCanvas(770, 340)
    self.descriptions = love.graphics.newCanvas(420, 600)
    self.playerBadge = love.graphics.newCanvas(500, 670)
    self.progression = love.graphics.newCanvas(160,980)

    self.roundNumberCanvas = love.graphics.newCanvas(290, 80)
    self.moneyCanvas = love.graphics.newCanvas(290, 100)
    self.rerollsCanvas = love.graphics.newCanvas(220, 120)
    self.handsCanvas = love.graphics.newCanvas(220, 120)
    self.descriptionCanvas = love.graphics.newCanvas(420, 240)
    self.ciggiesTray = love.graphics.newCanvas(420, 160)
    self.ciggiesTrayFront = love.graphics.newCanvas(420, 160)


    --UI Positions
    self.gridLX, self.gridLY = 30, 30
    self.inventoryLX, self.inventoryLY = 500, 720
    self.descriptionsX, self.descriptionsY = 1470, 30
    self.playerBadgeX, self.playerBadgeY = 770, 30
    self.progressionX, self.progressionY = 1290, 52
    self.planBtnX, self.planBtnY = 100, 910 
    self.menuBtnX, self.menuBtnY = 100, 1010
   
    self.rerollsX, self.rerollsY = 260, 721
    self.turnsX, self.turnsY = 30, 721
    self.moneyX, self.moneyY = 190, 860
    self.floorX, self.floorY = 190, 970
    self.descriptionX, self.descriptionY = self.canvas:getWidth()-30, 650

    self.ciggiesTrayX, self.ciggiesTrayY = self.canvas:getWidth()-30, self.canvas:getHeight()

    --Buttons
    self.uiElements = {buttons = {}, ciggiesUI={}, inventoryFaces={}, rewardFaces={}}

    self.uiElements.buttons["menuButton"] = Button:new(
        function()print("menu")end,
        "src/assets/sprites/ui/Menu.png",
        self.menuBtnX,
        self.menuBtnY,
        140,
        80,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    self.uiElements.buttons["planButton"] = Button:new(
        function()self:fadeOut()end,
        "src/assets/sprites/ui/Plan.png",
        self.planBtnX,
        self.planBtnY,
        140,
        100,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    --Start animations
    self.baseOpacity, self.targetOpacity = 0, 1
    self.opacity = self.baseOpacity
    
    self:generateCiggiesUI()

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

    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    --Buttons
    for i,button in next,self.uiElements.buttons do
        button:update(dt)
        button:draw()
    end

    self:drawGridLarge()
    self:drawInventoryLarge()
    self:drawDescriptions()
    self:drawPlayerBadge()
    self:drawProgression()
    self:drawRoundDetails()
    self:drawDescription()


    --Ciggies UI
    self:drawCiggiesTray()
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
        ciggie:draw()
    end
    self:drawCiggiesTrayFront()

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
end

function Infos:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
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

    love.graphics.draw(Sprites.GRID_LARGE, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.gridLarge, self.gridLX, self.gridLY)
end

function Infos:drawInventoryLarge()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.inventoryLarge)
    love.graphics.clear()

    love.graphics.draw(Sprites.INVENTORY_LARGE, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.inventoryLarge, self.inventoryLX, self.inventoryLY)
end

function Infos:drawDescriptions()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.descriptions)
    love.graphics.clear()

    love.graphics.draw(Sprites.OFFICE_DESCRIPTION, 0, 0)
    love.graphics.draw(Sprites.FLOOR_DESCRIPTION, 0, 407)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.descriptions, self.descriptionsX, self.descriptionsY)
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

function Infos:drawRoundDetails()
    local currentCanvas = love.graphics.getCanvas()
    --Create the texts
    local rerollText = love.graphics.newText(Fonts.soraBig, '-')
    local currentHands = love.graphics.newText(Fonts.soraBig, '-')
    local currentRoundText = love.graphics.newText(Fonts.soraSmall, 'Floor '..tostring(self.run.floorNumber)..'\nDesk : '..tostring("-"))
    local moneyText = love.graphics.newText(Fonts.soraBig, tostring(self.run.money).."€")

    if(self.round) then
        rerollText = love.graphics.newText(Fonts.soraBig, tostring(self.round.availableRerolls))
        currentHands = love.graphics.newText(Fonts.soraBig, tostring(self.round.remainingHands))
        currentRoundText = love.graphics.newText(Fonts.soraSmall, 'Floor '..tostring(self.round.floorNumber)..'\nDesk : '..tostring(self.round.deskNumber))
        moneyText = love.graphics.newText(Fonts.soraBig, tostring(self.round.run.money).."€")
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
    love.graphics.setColor(1, 178/255, 89/255, 1)
    love.graphics.draw(moneyText, self.moneyCanvas:getWidth()/2, self.moneyCanvas:getHeight()/2-7, 0, 1, 1, moneyText:getWidth()/2, moneyText:getHeight()/2-10)
    love.graphics.setColor(1, 1, 1, 1)


    --DRAW ALL THE CANVAS
    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.roundNumberCanvas, self.floorX, self.floorY)
    love.graphics.draw(self.handsCanvas, self.turnsX, self.turnsY)
    love.graphics.draw(self.rerollsCanvas, self.rerollsX, self.rerollsY)
    love.graphics.draw(self.moneyCanvas, self.moneyX, self.moneyY)
end

function Infos:drawDescription()
    --local hoveredObject = self:getCurrentlyHoveredObject()

    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.descriptionCanvas)
    love.graphics.clear()
    --Draw Sprite
    love.graphics.draw(Sprites.DESCRIPTION, 0, 0)


    --[[ if(hoveredObject) then

        --Name
        local objectName = hoveredObject.name
        local nameText = love.graphics.newText(Fonts.sora30, objectName)

        --Face tier
        local tierText = love.graphics.newText(
            Fonts.soraSmall,
            hoveredObject.tier
        )

        --Description
        local faceDescription = hoveredObject.description
        local descWidth, descWrappedtext = Fonts.soraDesc:getWrap(faceDescription, self.descriptionCanvas:getWidth()-18 )
        local descText = love.graphics.newText(Fonts.soraDesc, table.concat(descWrappedtext, "\n"))
        
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.draw(nameText, self.descriptionCanvas:getWidth()/2, 65, 0, 1, 1, nameText:getWidth()/2, 0)
        love.graphics.draw(tierText, self.descriptionCanvas:getWidth()/2, 105, 0, 1, 1, tierText:getWidth()/2, 0)
        love.graphics.draw(descText, self.descriptionCanvas:getWidth()/2, 140, 0, 1, 1, descText:getWidth()/2, 0)
        love.graphics.setColor(1, 1, 1, 1)

    end ]]

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.descriptionCanvas, self.descriptionX, self.descriptionY, 0, 1, 1, self.descriptionCanvas:getWidth(), 0)
end

function Infos:drawCiggiesTray()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.ciggiesTray)

    love.graphics.draw(Sprites.CIGGIES_TRAY_BACK, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.ciggiesTray, self.ciggiesTrayX, self.ciggiesTrayY, 0, 1, 1, self.ciggiesTray:getWidth(), self.ciggiesTray:getHeight())
end

function Infos:drawCiggiesTrayFront()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.ciggiesTrayFront)

    love.graphics.draw(Sprites.CIGGIES_TRAY_FRONT, 0, self.ciggiesTrayFront:getHeight(), 0, 1, 1, 0, Sprites.CIGGIES_TRAY_FRONT:getHeight())

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.ciggiesTrayFront, self.ciggiesTrayX, self.ciggiesTrayY, 0, 1, 1, self.ciggiesTray:getWidth(), self.ciggiesTray:getHeight())
end

--Start/END

function Infos:generateCiggiesUI()
    self.uiElements.ciggiesUI = {}

    --calculate the xPosistions
    local xPos = self:getSpacedPositions(table.getn(self.run.ciggiesObjects), self.ciggiesTrayX-self.ciggiesTray:getWidth(), self.ciggiesTrayX)

    for i,ciggie in next,self.run.ciggiesObjects do
        
        local c = Ciggie:new(ciggie, xPos[i], self.canvas:getHeight()+30, true, true, function()return Inputs.getMouseInCanvas(0, 0)end, self.round)
        c.baseRotation, c.rotation, c.targetedRotation = 1.57, 1.57, 1.57
        self.uiElements.ciggiesUI[ciggie] = c
    end
end

function Infos:fadeOut()
    self.animator:add('opacity', self.opacity, self.baseOpacity, 0.1, nil, function()self.run:toggleInfoScreen()end)
end

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