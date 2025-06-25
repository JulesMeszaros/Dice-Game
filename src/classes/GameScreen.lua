local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local Fonts = require("src.utils.Fonts")
local AnimationUtils = require("src.utils.scripts.Animations")
local Animator = require("src.utils.Animator")
local Sprites = require("src.utils.Sprites")
local Ciggie = require("src.classes.ui.Ciggie")
local FaceObject = require("src.classes.FaceObject")
local DiceObject = require("src.classes.DiceObject")
local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")
local Badge = require("src.classes.ui.Badge")
local Button = require("src.classes.ui.Button")
local DiceFace = require("src.classes.ui.DiceFace")

local GameScreen = {}
GameScreen.__index = GameScreen

function GameScreen:new(floor, run, screenType, round)
    local self = setmetatable({}, GameScreen)

    self.screenType = screenType

    --Hovered Objects
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

    self.animator = Animator:new(self)

    --UI Canvas
    self.dice_tray = love.graphics.newCanvas(930, 630)
    self.descriptionCanvas = love.graphics.newCanvas(420, 240)
    self.figureButtonsCanvas = love.graphics.newCanvas(450,670)
    self.rerollsCanvas = love.graphics.newCanvas(220, 120)
    self.handsCanvas = love.graphics.newCanvas(220, 120)
    self.roundNumberCanvas = love.graphics.newCanvas(290, 80)
    self.moneyCanvas = love.graphics.newCanvas(290, 100)
    self.deckCanvas = love.graphics.newCanvas(140, 860)
    self.diceDetailsCanvas = love.graphics.newCanvas(420, 600)
    self.ciggiesTray = love.graphics.newCanvas(420, 140)
    self.playerInfos = love.graphics.newCanvas(650,260)
    self.enemyInfos = love.graphics.newCanvas(650,260)
    self.handScoreCanvas = love.graphics.newCanvas(self.dice_tray:getWidth(), 170)

    --Positions
    self.diceMatTX, self.diceMatTY, self.diceMatx, self.diceMaty = 510 , 320, 510, self.canvas:getHeight()+1000
    self.enemyTX, self.enemyTY, self.enemyX, self.enemyY = 790, 30, self.canvas:getWidth()+20, 30
    self.playerTX, self.playerTY, self.playerX, self.playerY = 510, 30, -800, 30
    
    self.gridTX, self.gridTY, self.gridX, self.gridY = 30, 30, 30, -650
    self.diceDetailsTX, self.diceDetailsTY, self.diceDetailsX, self.diceDetailsY = self.canvas:getWidth()-30, 30, self.canvas:getWidth()+600, 30
    self.descriptionTX, self.descriptionTY, self.descriptionX, self.descriptionY = self.canvas:getWidth()-30, 650, self.canvas:getWidth()+600, 650

    self.rerollsTX, self.rerollsTY, self.rerollsX, self.rerollsY = 260, 721, -500, 721
    self.turnsTX, self.turnsTY, self.turnsX, self.turnsY = 30, 721, -730, 721
    self.floorTX, self.floorTY, self.floorX, self.floorY = 190, 970, 190, self.canvas:getHeight()+400
    self.moneyTX, self.moneyTY, self.moneyX, self.moneyY = 190, 860, 190, self.canvas:getHeight()+300
    self.ciggiesTrayTX, self.ciggiesTrayTY, self.ciggiesTrayX, self.ciggiesTrayY = self.canvas:getWidth()-30, self.canvas:getHeight()-30, self.canvas:getWidth()+450, self.canvas:getHeight()-30
    self.deckTX, self.deckTY , self.deckX, self.deckY = 1300, 110, 1300, self.canvas:getHeight()+20

    --Btns positions
    self.planBtnTX, self.planBtnTY, self.planBtnX, self.planBtnY = 100, 910, -150, 910
    self.menuBtnTX, self.menuBtnTY, self.menuBtnX, self.menuBtnY = 100, 1010, -150, 1010
    self.rerollBtnTX, self.rerollBtnTY, self.rerollBtnX, self.rerollBtnY = 975, 1010, 975, 1500

    --Entry animation
    self.animator:addDelay(0.1)

    self.animator:addGroup({
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
    })
    
    --Cas particulier de l'écran de round
    if(self.screenType == Constants.ROUND_STATES.ROUND) then
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
        function()print("plan")end,
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
    if(self.screenType == Constants.ROUND_STATES.ROUND) then

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

    return self
end

function GameScreen:update(dt)

end

function GameScreen:updateCanvas(dt)

end

function GameScreen:draw()

end

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

--==Input Functions==--

--==Hovered Elements==--


return GameScreen