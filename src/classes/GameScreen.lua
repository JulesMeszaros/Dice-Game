local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local Fonts = require("src.utils.Fonts")
local AnimationUtils = require("src.utils.scripts.Animations")
local Animator = require("src.utils.Animator")
local Sprites = require("src.utils.Sprites")
local FaceObject = require("src.classes.FaceObject")
local DiceObject = require("src.classes.DiceObject")
local Button = require("src.classes.ui.Button")
local DiceFace = require("src.classes.ui.DiceFace")
local Ciggie = require("src.classes.ui.Ciggie")

local GameScreen = {}
GameScreen.__index = GameScreen

function GameScreen:new(floor, run, screenType, round)
    local self = setmetatable({}, GameScreen)

    self.screenType = screenType

    --Hovered Objects
    self.hoverableObjects = {}
    self.currentlyHoveredFace = nil
    self.previouslyHoveredFace = nil
    self.currentlySelectedDice = nil
    self.currentlyHoveredFigure = nil 
    self.currentlyHoveredCiggie = nil

    --Canvas
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    self.x, self.y = 0, 0 --Canvas position in screen
    
    --UI Elements
    self.uiElements = {
        buttons = {},
        DeskChoiceButtons = {},
        faceRewards = {},
        ciggiesUI = {}
    }
    --Run status
    self.floor = floor
    self.run = run
    self.round = round
    self.diceObjects = run.diceObjects
    self.draggedCiggie = false
    self.showCiggiePopup = false

    self.animator = Animator:new(self)

    --UI Canvas
    self.customizationMat = love.graphics.newCanvas(1860, 600)
    self.newFacesCanvas = love.graphics.newCanvas(950, 400)
    self.dice_tray = love.graphics.newCanvas(930, 630)
    self.descriptionCanvas = love.graphics.newCanvas(420, 240)
    self.figureButtonsCanvas = love.graphics.newCanvas(450,670)
    self.rerollsCanvas = love.graphics.newCanvas(220, 120)
    self.handsCanvas = love.graphics.newCanvas(220, 120)
    self.roundNumberCanvas = love.graphics.newCanvas(290, 80)
    self.moneyCanvas = love.graphics.newCanvas(290, 100)
    self.deckCanvas = love.graphics.newCanvas(140, 860)
    self.diceDetailsCanvas = love.graphics.newCanvas(420, 600)
    self.ciggiesTray = love.graphics.newCanvas(420, 160)
    self.ciggiesTrayFront = love.graphics.newCanvas(420, 160)
    self.playerInfos = love.graphics.newCanvas(650,260)
    self.enemyInfos = love.graphics.newCanvas(650,260)
    self.handScoreCanvas = love.graphics.newCanvas(self.dice_tray:getWidth(), 170)
    self.inventoryCanvas = love.graphics.newCanvas(680, 410)
    self.inventoryCanvasSmall = love.graphics.newCanvas(550, 360)
    self.inventoryCanvasMedium = love.graphics.newCanvas(680, 410)
    self.shopCanvas = love.graphics.newCanvas(780, 560)
    self.rewardsSmallCanvas = love.graphics.newCanvas(210, 360)
    self.rewardsMediumCanvas = love.graphics.newCanvas(240, 410)
    self.ciggiePopupCanvas = love.graphics.newCanvas(self.canvas:getWidth(), self.canvas:getHeight())

    --Positions
    self.diceMatTX, self.diceMatTY, self.diceMatx, self.diceMaty = 510 , 320, 510, self.canvas:getHeight()+1000
    self.enemyTX, self.enemyTY, self.enemyX, self.enemyY = 790, 30, self.canvas:getWidth()+20, 30
    self.playerTX, self.playerTY, self.playerX, self.playerY = 510, 30, -800, 30
    
    self.gridTX, self.gridTY, self.gridX, self.gridY = 30, 30, 30, -900
    self.diceDetailsTX, self.diceDetailsTY, self.diceDetailsX, self.diceDetailsY = self.canvas:getWidth()-30, 30, self.canvas:getWidth()+600, 30
    self.descriptionTX, self.descriptionTY, self.descriptionX, self.descriptionY = self.canvas:getWidth()-30, 650, self.canvas:getWidth()+600, 650

    self.rerollsTX, self.rerollsTY, self.rerollsX, self.rerollsY = 260, 721, -500, 721
    self.turnsTX, self.turnsTY, self.turnsX, self.turnsY = 30, 721, -730, 721
    self.floorTX, self.floorTY, self.floorX, self.floorY = 190, 970, 190, self.canvas:getHeight()+400
    self.moneyTX, self.moneyTY, self.moneyX, self.moneyY = 190, 860, 190, self.canvas:getHeight()+300
    self.ciggiesTrayTX, self.ciggiesTrayTY, self.ciggiesTrayX, self.ciggiesTrayY = self.canvas:getWidth()-30, self.canvas:getHeight(), self.canvas:getWidth()+450, self.canvas:getHeight()
    self.deckTX, self.deckTY , self.deckX, self.deckY = 1300, 110, 1300, self.canvas:getHeight()+20

    self.customizationMatTX, self.customizationMatTY, self.customizationMatX, self.customizationMatY = 30, 30, 30, -700
    self.newFacesTX, self.newFacesTY, self.newFacesX, self.newFacesY = 500, 650, 500, self.canvas:getHeight()+450

    self.shopBGTX, self.shopBGTY, self.shopBGX, self.shopBGY = 500, 30, 500, -600
    self.inventoryTX, self.inventoryTY, self.inventoryX, self.inventoryY = 550, 640, 550, self.canvas:getHeight()+450
    self.inventorySMTX, self.inventorySMTY, self.inventorySMX, self.inventorySMY = 730, 690, 730, self.canvas:getHeight()+600
    self.inventoryMDTX, self.inventoryMDTY, self.inventoryMDX, self.inventoryMDY = 770, 650, 770, self.canvas:getHeight()+700

    self.rewardsSMTX, self.rewardsSMTY, self.rewardsSMX, self.rewardsSMY = 500, 690, 500, self.canvas:getHeight()+600
    self.rewardsMDTX, self.rewardsMDTY, self.rewardsMDX, self.rewardsMDY = 500, 650, 500, self.canvas:getHeight()+700

    self.lighterBaseX, self.lighterBaseY, self.lighterTargetX, self.lighterTargetY = self.canvas:getWidth()/2, self.canvas:getHeight()+500, self.canvas:getWidth()/2, 4*self.canvas:getHeight()/5
    self.lighterX, self.lighterY = self.lighterBaseX, self.lighterBaseY
    self.baseCiggiePopupAlpha, self.targetCiggiePopupAlpha, self.ciggiePopupAlpha = 0, 0.7, 0
    

    --Btns positions
    self.planBtnTX, self.planBtnTY, self.planBtnX, self.planBtnY = 100, 910, -150, 910
    self.menuBtnTX, self.menuBtnTY, self.menuBtnX, self.menuBtnY = 100, 1010, -150, 1010
    self.rerollBtnTX, self.rerollBtnTY, self.rerollBtnX, self.rerollBtnY = 975, 1010, 975, 1500
    self.nextRoundTX, self.nextRoundTY, self.nextRoundX, self.nextRoundY = 255, 680, -255, 680
    self.rerollShopTX, self.rerollShopTY, self.rerollShopX, self.rerollShopY = 510+(370/2), 640, -255, 640
    self.nextRoundSMTX, self.nextRoundSMTY, self.nextRoundSMX, self.nextRoundSMY = 900+(370/2), 640, self.canvas:getWidth()+255, 640

    --Entry animation
    self.animator:addDelay(0.2)

    self.animator:addGroup({
        {property = "customizationMatY", from = self.customizationMatY, targetValue = self.customizationMatTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "newFacesY", from = self.newFacesY, targetValue = self.newFacesTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "gridY", from = self.gridY, targetValue = self.gridTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.diceDetailsTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.descriptionTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "diceMaty", from = self.diceMaty, targetValue = self.diceMatTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "deckY", from = self.deckY, targetValue = self.deckTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "moneyY", from = self.moneyY, targetValue = self.moneyTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = self.turnsTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = self.rerollsTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.ciggiesTrayTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.floorTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},    
        {property = "shopBGY", from = self.shopBGY, targetValue = self.shopBGTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},    
        {property = "inventoryY", from = self.inventoryY, targetValue = self.inventoryTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},    
        {property = "inventorySMY", from = self.inventorySMY, targetValue = self.inventorySMTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},    
        {property = "inventoryMDY", from = self.inventoryMDY, targetValue = self.inventoryMDTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},    
        {property = "rewardsSMY", from = self.rewardsSMY, targetValue = self.rewardsSMTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},    
        {property = "rewardsMDY", from = self.rewardsMDY, targetValue = self.rewardsMDTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},    
    })
    
    --Cas particulier de l'écran de round
    if(self.screenType == Constants.RUN_STATES.ROUND) then
        self.animator:addDelay(0.2)
        --Enemy and player
        self.animator:addGroup({
            {property = "playerX", from = self.playerX, targetValue = self.playerTX, duration = AnimationUtils.EntryDuration },
            {property = "enemyX", from = self.enemyX, targetValue = self.enemyTX, duration = AnimationUtils.EntryDuration},
        })
        --Shake
        AnimationUtils.shake(self, 0, 10, 0.1)
    end

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
        function()self.run:toggleInfoScreen()end,
        "src/assets/sprites/ui/Plan.png",
        self.planBtnX,
        self.planBtnY,
        140,
        100,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )
    
    --Buttons animation
    self.uiElements.buttons["menuButton"].animator:add('x', self.menuBtnX, self.menuBtnTX, AnimationUtils.EntryDuration*2, AnimationUtils.Easing.outCubic)
    self.uiElements.buttons["planButton"].animator:add('x', self.planBtnX, self.planBtnTX, AnimationUtils.EntryDuration*2, AnimationUtils.Easing.outCubic)
    
    --Cas particulier de l'écran de round
    if(self.screenType == Constants.RUN_STATES.ROUND) then

        self.uiElements.buttons["rerollButton"] = Button:new(
            function()self.round:rerollDices()end, 
            "src/assets/sprites/ui/Reroll.png", 
            self.rerollBtnX,
            self.rerollBtnY,
            840, 
            80,
            self.gameCanvas,
            function()return Inputs.getMouseInCanvas(0, 0)end
        )
        self.uiElements.buttons["rerollButton"].animator:add('y', self.rerollBtnY, self.rerollBtnTY, AnimationUtils.EntryDuration*2, AnimationUtils.Easing.outCubic)

    end

    --Cas particulier du shop
    if(self.screenType == Constants.RUN_STATES.SHOP) then

        self.uiElements.buttons["rerollShopButton"] = Button:new(
            function()self:rerollShop()end, 
            "src/assets/sprites/ui/Reroll Shop.png", 
            self.rerollShopX,
            self.rerollShopY,
            370, 
            60,
            self.gameCanvas,
            function()return Inputs.getMouseInCanvas(0, 0)end
        )
        self.uiElements.buttons["rerollShopButton"].animator:addDelay(0.2)
        self.uiElements.buttons["rerollShopButton"].animator:add('x', self.rerollShopX, self.rerollShopTX, AnimationUtils.EntryDuration*2, AnimationUtils.Easing.outCubic)

        self.uiElements.buttons["nextRoundSmallBtn"] = Button:new(
            function()self:outAnimation()end, 
            "src/assets/sprites/ui/Next Round Small.png", 
            self.rerollShopX,
            self.rerollShopY,
            370, 
            60,
            self.gameCanvas,
            function()return Inputs.getMouseInCanvas(0, 0)end
        )
        self.uiElements.buttons["nextRoundSmallBtn"].animator:addDelay(0.2)
        self.uiElements.buttons["nextRoundSmallBtn"].animator:add('x', self.nextRoundSMX, self.nextRoundSMTX, AnimationUtils.EntryDuration*2, AnimationUtils.Easing.outCubic)

    end

    return self
end

function GameScreen:update(dt)

end

function GameScreen:updateCanvas(dt)

end

function GameScreen:draw()

end

--==UI Draw functions==--

--CiggiePopuup
function GameScreen:drawCiggiePopup()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.ciggiePopupCanvas)
    love.graphics.clear()

    --Background
    love.graphics.setColor(0.2, 0.2, 0.2, self.ciggiePopupAlpha)
    love.graphics.rectangle("fill", 0, 0, self.ciggiePopupCanvas:getWidth(), self.ciggiePopupCanvas:getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    --Sell Rect
    local a = self.ciggiePopupAlpha/self.targetCiggiePopupAlpha
    love.graphics.setColor(1, 1, 1, a)
    love.graphics.draw(Sprites.SELL_CIGGIE, 30, self.canvas:getHeight()-30, 0, 1, 1, 0, Sprites.SELL_CIGGIE:getHeight())
    local sellText = love.graphics.newText(Fonts.soraBig, "Sell : 1$")
    love.graphics.setColor(255/255, 178/255, 89/255, a)
    love.graphics.draw(sellText, 250, 950, 0, 1, 1, sellText:getWidth()/2, sellText:getHeight()/2)
    love.graphics.setColor(1, 1, 1, 1)

    --Lighter
    love.graphics.draw(Sprites.LIGHTER, self.lighterX, self.lighterY, 0, 1, 1, Sprites.LIGHTER:getWidth()/2, Sprites.LIGHTER:getHeight()/2)
    

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.ciggiePopupCanvas, 0, 0, 0, 1, 1)
end

--Description
function GameScreen:drawDescription()
    local hoveredObject = self:getCurrentlyHoveredObject()

    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.descriptionCanvas)
    love.graphics.clear()
    --Draw Sprite
    love.graphics.draw(Sprites.DESCRIPTION, 0, 0)


    if(hoveredObject) then

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

    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.descriptionCanvas, self.descriptionX, self.descriptionY, 0, 1, 1, self.descriptionCanvas:getWidth(), 0)
end

--Round details canvas
function GameScreen:drawRoundDetails()
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

function GameScreen:drawCiggiesTray()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.ciggiesTray)

    love.graphics.draw(Sprites.CIGGIES_TRAY_BACK, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.ciggiesTray, self.ciggiesTrayX, self.ciggiesTrayY, 0, 1, 1, self.ciggiesTray:getWidth(), self.ciggiesTray:getHeight())
end

function GameScreen:drawCiggiesTrayFront()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.ciggiesTrayFront)

    love.graphics.draw(Sprites.CIGGIES_TRAY_FRONT, 0, self.ciggiesTrayFront:getHeight(), 0, 1, 1, 0, Sprites.CIGGIES_TRAY_FRONT:getHeight())

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.ciggiesTrayFront, self.ciggiesTrayX, self.ciggiesTrayY, 0, 1, 1, self.ciggiesTray:getWidth(), self.ciggiesTray:getHeight())
end

function GameScreen:drawFigureGrid()
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.figureButtonsCanvas)
    love.graphics.clear()
    --Draw the table
    love.graphics.draw(Sprites.GRID, 0, 0)

    if(self.screenType == Constants.RUN_STATES.ROUND)then
        --Draw the scores
        love.graphics.setColor(249/255, 130/255, 132/255)

        for i=1, 13 do
            local calcScore = love.graphics.newText(Fonts.soraSmall, self.calcBasePoints[i]()[1])
            love.graphics.draw(calcScore, 225, 50*(i-1)+38, 0, 1, 1, calcScore:getWidth()/2, calcScore:getHeight()/2)
        end
    end

    --Write the remaining possible hands
    love.graphics.setColor(0, 0, 0, 1)

    for i=1, 13 do
        local handsRemaining = love.graphics.newText(Fonts.soraSmall, self.run.availableFigures[i])
        love.graphics.draw(handsRemaining, 368, 50*(i-1)+38, 0, 1, 1, handsRemaining:getWidth()/2, handsRemaining:getHeight()/2)
        --if no hands remaining, grey out the line
        if(self.run.availableFigures[i]<=0) then
            love.graphics.setColor(0.4, 0.4, 0.4, 0.4)
            love.graphics.rectangle("fill", 10, (i-1)*50+10, self.figureButtonsCanvas:getWidth()-20, 50)
            love.graphics.setColor(0, 0, 0, 1)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

    local mv = Inputs.getMouseInCanvas(30, 30) --get the mouse position
    local i = math.floor((mv.y-10)/50)+1

    --If we are hovering a line
    if(i>0 and i<=13)then
        if(mv.x>0 and mv.x<self.figureButtonsCanvas:getWidth())then
            --Draw a shadow on the line
            if(self.run.availableFigures[i]>=1)then
                love.graphics.setColor(Constants.FIGURES_COLORS[i][1], Constants.FIGURES_COLORS[i][2], Constants.FIGURES_COLORS[i][3], 0.3)
                love.graphics.rectangle("fill", 10, (i-1)*50+10, self.figureButtonsCanvas:getWidth()-20, 50)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    love.graphics.setCanvas(targetCanvas)
    
    love.graphics.draw(self.figureButtonsCanvas, self.gridX, self.gridY)
    
end

function GameScreen:drawShopBackground()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.shopCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.SHOP_BG, 0, 0)

    --Draw the coffee buttons
    if(self.availableCoffeesUI) then
        for i, btn in next,self.availableCoffeesUI do
            btn:draw()
        end
    end

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.shopCanvas, self.shopBGX, self.shopBGY)
end

function GameScreen:drawInventoryBackGround()
    love.graphics.draw(Sprites.INVENTORY, self.inventoryX, self.inventoryY)
end

function GameScreen:drawInventoryBackGroundSmall()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.inventoryCanvasSmall)
    love.graphics.clear()
    love.graphics.draw(Sprites.INVENTORY_SMALL, 0, 0)
    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.inventoryCanvasSmall, self.inventorySMX, self.inventorySMY)
end

function GameScreen:drawRewardsSmall()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.rewardsSmallCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.REWARDS_SMALL, 0, 0)
    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.rewardsSmallCanvas, self.rewardsSMX, self.rewardsSMY)
end

function GameScreen:drawInventoryBackGroundMedium()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.inventoryCanvasMedium)
    love.graphics.clear()
    love.graphics.draw(Sprites.INVENTORY_MEDIUM, 0, 0)
    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.inventoryCanvasMedium, self.inventoryMDX, self.inventoryMDY)
end

function GameScreen:drawRewardsMedium()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.rewardsMediumCanvas)
    love.graphics.clear()
    love.graphics.draw(Sprites.REWARDS_MEDIUM, 0, 0)
    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.rewardsMediumCanvas, self.rewardsMDX, self.rewardsMDY)
end

--==Initialization functions==--

function GameScreen:createDiceNet()
    --Create a temp dice with a temp face repeated 6 times
    local tempFace = FaceObject:new(6)
    self.tempDice = DiceObject:new({tempFace, tempFace, tempFace, tempFace, tempFace, tempFace})

    --Create the coordinates of each dice face
    local diceFacesCoords = {
        {self.diceDetailsCanvas:getWidth()/2-120, self.diceDetailsCanvas:getHeight()/2-30}, --1
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2-120-30}, --2
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2-30}, --3
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2+240-30}, --4
        {self.diceDetailsCanvas:getWidth()/2, self.diceDetailsCanvas:getHeight()/2+120-30}, --5
        {self.diceDetailsCanvas:getWidth()/2+120, self.diceDetailsCanvas:getHeight()/2-30}, --6
    }
    
    -- Create the uiFaces objects
    local infoFaces = {}

    for k,d in next,self.tempDice:getAllFaces() do
        local diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            self.tempDice, --Dice Object 
            d, --La face représentée
            diceFacesCoords[k][1], --X Position (centerd)
            diceFacesCoords[k][2], --Yposition (centerd)
            120, --Width/Height
            false, --is Selectable
            true, --isHoverable,
            function()return Inputs.getMouseInCanvas(self.diceDetailsX - self.diceDetailsCanvas:getWidth(), self.diceDetailsY)end,
            self.round
        )

        table.insert(infoFaces, diceFaceUI)
    end

    self.infoFaces = infoFaces
end

function GameScreen:generateCiggiesUI()
    local apparitionDuration = 0.2
    self.uiElements.ciggiesUI = {}

    --calculate the xPosistions
    local xPos = self:getSpacedPositions(table.getn(self.run.ciggiesObjects), self.ciggiesTrayTX-self.ciggiesTray:getWidth(), self.ciggiesTrayTX)

    for i,ciggie in next,self.run.ciggiesObjects do
        
        local c = Ciggie:new(ciggie, xPos[i], self.canvas:getHeight()+30, true, true, function()return Inputs.getMouseInCanvas(0, 0)end, self.round)
        c.baseRotation, c.rotation = 1.57, 1.57
        self.uiElements.ciggiesUI[ciggie] = c

        c.animator:addGroup({
            --Rotation
            --Scale
            {property = "baseTargetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            
        })
    end
end
--==Input Functions==--

--==Hovered Elements==--

--==Utils==--
function GameScreen:getCenteredPositions(count, objectWidth, spacing, centerX)
    local totalWidth = count * objectWidth + (count - 1) * spacing
    local startX = centerX - totalWidth / 2

    local positions = {}
    for i = 0, count - 1 do
        local x = startX + i * (objectWidth + spacing)
        table.insert(positions, x)
    end

    return positions
end

function GameScreen:getSpacedPositions(count, x1, x2)
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

function GameScreen:checkForDraggedCiggie()
    local draggedCiggie = false
    self.previousCiggieDraggedState = self.draggedCiggie
    
    for i,ciggie in next,self.uiElements.ciggiesUI do
        if(ciggie.x < 1470 or ciggie.y < 800)then
            draggedCiggie = true
            self.showCiggiePopup = true
            break
        end
    end
    
    self.draggedCiggie = draggedCiggie
end

function GameScreen:startCiggiePopUp()
    local d = 0.2
    self.animator:addGroup({
        {property = "ciggiePopupAlpha", from=self.baseCiggiePopupAlpha, targetValue=self.targetCiggiePopupAlpha, duration=d},
        {property = "lighterY", from=self.lighterY, targetValue=self.lighterTargetY, duration=d, easing=AnimationUtils.Easing.outCubic},
    })
end

function GameScreen:endCiggiePopup()
    local d = 0.2
    self.animator:addGroup({
        {property = "ciggiePopupAlpha", from=self.ciggiePopupAlpha, targetValue=self.baseCiggiePopupAlpha, duration=d, onComplete=function()self.showCiggiePopup=false end},
        {property = "lighterY", from=self.lighterY, targetValue=self.lighterBaseY, duration=d},
    })
end

function GameScreen:checkCiggiePosition(ciggie)
    if((ciggie.x > 500 and ciggie.x<1400) or (ciggie.y>0 and ciggie.y<850))then
        return 1
    elseif((ciggie.x > 0 and ciggie.x < 500) and (ciggie.y>850 and ciggie.y<self.canvas:getHeight())) then
        return 2
    end
end

function GameScreen:ciggieReleaseAction(ciggie)
    local position = self:checkCiggiePosition(ciggie)

    --Trigger effect
    if(position == 1) then
        ciggie.representedObject:trigger(self, self.screenType)
    elseif(position == 2) then
        self:sellCiggie(ciggie)
    end
end

function GameScreen:sellCiggie(ciggie)
    --Add money to bank account
    self.run.money = self.run.money+1
    
    --On retire l'objet de l'inventaire
    for j,c in next,self.run.ciggiesObjects do
        if(c==ciggie.representedObject) then table.remove(self.run.ciggiesObjects, j)end
    end
    
    self:generateCiggiesUI()
end

return GameScreen