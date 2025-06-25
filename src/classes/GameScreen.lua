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

function GameScreen:new(floor, run)
    local self = setmetatable({}, GameScreen)

    --Hovered Objects
    self.currentlyHoveredFace = nil
    self.previouslyHoveredFace = nil
    self.currentlySelectedDice = nil

    --Canvas
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
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
    self.diceObjects = run.diceObjects

    self.animator = Animator:new(self)

    --UI Canvas
    self.descriptionCanvas = love.graphics.newCanvas(420, 240)
    self.figureButtonsCanvas = love.graphics.newCanvas(450,670)
    self.rerollsCanvas = love.graphics.newCanvas(220, 120)
    self.handsCanvas = love.graphics.newCanvas(220, 120)
    self.roundNumberCanvas = love.graphics.newCanvas(290, 80)
    self.moneyCanvas = love.graphics.newCanvas(290, 100)
    self.deckCanvas = love.graphics.newCanvas(140, 860)
    self.diceDetailsCanvas = love.graphics.newCanvas(420, 600)
    self.ciggiesTray = love.graphics.newCanvas(420, 140)

    --Positions
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

    --Entry animation
    self.animator:addDelay(0.1)

    self.animator:addGroup({
        {property = "gridY", from = self.gridY, targetValue = self.gridTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.diceDetailsTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.descriptionTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "deckY", from = self.deckY, targetValue = self.deckTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.outCubic},
        {property = "moneyY", from = self.moneyY, targetValue = self.moneyTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = self.turnsTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = self.rerollsTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.ciggiesTrayTX, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.floorTY, duration = AnimationUtils.EntryDuration, easing = AnimationUtils.Easing.inOutCubic},    
    })

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


return GameScreen