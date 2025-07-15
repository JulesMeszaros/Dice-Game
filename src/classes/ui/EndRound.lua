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

local EndRound = {}
EndRound.__index = EndRound

function EndRound:new(run, round)
    local self = setmetatable({}, EndRound)

    self.animator = Animator:new(self)
    self.run = run
    self.round = round

    --UI Elements
    self.backgroundOpacity = 0

    --Canvas
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_WIDTH)
    self.contentCanvas = love.graphics.newCanvas(930,760)
    self.moneyRewardCanvas = love.graphics.newCanvas(410, 480)
    self.rewardsCanvas = love.graphics.newCanvas(410, 480)

    --Positions
    self.contentTX, self.contentTY, self.contentX, self.contentY = 510, 320, 510, self.canvas:getHeight()+770

    --Animations
    local inDuration = 0.15
    self.animator:addGroup({
        {property = "backgroundOpacity", from=0, targetValue=0.7, duration=inDuration},
        {property = "contentY", from=self.contentY, targetValue=self.contentTY, duration=inDuration}
    })

    return self
end

function EndRound:update(dt)
    self.animator:update(dt)
end

function EndRound:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    love.graphics.setColor(0.1, 0.1, 0.1, self.backgroundOpacity)
    love.graphics.rectangle("fill", 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    self:drawMainCanvas()

    love.graphics.setCanvas(currentCanvas)
end

--update the different canvas
function EndRound:drawMainCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.contentCanvas)
    love.graphics.clear()

    --Background
    love.graphics.draw(Sprites.END_ROUND_BG, 0, 0)
    love.graphics.draw(Sprites.YOU_WON, 180, 30)

    --Money earned
    self:updateEarnedMoney()
    love.graphics.draw(self.moneyRewardCanvas, 40, 140)
    --Dice rewards
    self:updateRewardsCanvas()
    love.graphics.draw(self.rewardsCanvas, 480, 140)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.contentCanvas, self.contentX, self.contentY)
end

function EndRound:updateEarnedMoney()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.moneyRewardCanvas)
    love.graphics.clear()

    love.graphics.draw(Sprites.CASH_REWARD, 0, 0)

    love.graphics.setCanvas(currentCanvas)
end

function EndRound:updateRewardsCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.rewardsCanvas)
    love.graphics.clear()

    love.graphics.draw(Sprites.END_ROUND_REWARDS, 0, 0)

    love.graphics.setCanvas(currentCanvas)
end

function EndRound:draw()
    love.graphics.draw(self.canvas, 0, 0, 0, 1, 1)
end

return EndRound