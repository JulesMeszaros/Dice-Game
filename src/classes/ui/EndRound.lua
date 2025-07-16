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
    self.faceRewards = {}

    --Canvas
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_WIDTH)
    self.contentCanvas = love.graphics.newCanvas(930,760)
    self.moneyRewardCanvas = love.graphics.newCanvas(410, 480)
    self.rewardsCanvas = love.graphics.newCanvas(410, 480)

    --Button
    self.nextRoundButton = Button:new(
        function()self:outAnimation()end,
        "src/assets/sprites/ui/Next Office.png",
        45 + 840/2,
        650 + 40,
        840,
        80,
        self.run.gameCanvas,
        function()return Inputs.getMouseInCanvas(self.contentX, self.contentY)end
    )

    --Positions
    self.contentTX, self.contentTY, self.contentX, self.contentY = 510, 320, 510, self.canvas:getHeight()+770

    --Animations
    local inDuration = 0.3
    self.animator:addGroup({
        {property = "backgroundOpacity", from=0, targetValue=0.7, duration=inDuration, easing=AnimationUtils.Easing.outCubic},
        {property = "contentY", from=self.contentY, targetValue=self.contentTY, duration=inDuration, easing=AnimationUtils.Easing.outCubic}
    })
    self.animator:addDelay(0.1, function()self:generateFaceRewards()end)

    

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

    --Pop up content
    self:drawMainCanvas(dt)

    --UI faces
    for i,uiFace in next,self.faceRewards do
        uiFace:update(dt)
        uiFace:draw()
    end

    love.graphics.setCanvas(currentCanvas)
end

--update the different canvas
function EndRound:drawMainCanvas(dt)
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
    --Next Round button
    self.nextRoundButton:update(dt)
    self.nextRoundButton:draw()

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.contentCanvas, self.contentX, self.contentY)
end

function EndRound:updateEarnedMoney()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.moneyRewardCanvas)
    love.graphics.clear()

    --Text
    local coworkerLabel  = love.graphics.newText(Fonts.soraReward, {{255/255, 247/255, 160/255}, "Coworker Reward : ", {255/255, 223/255, 120/255}, tostring(self.round.baseReward)})
    local turnsLabel = love.graphics.newText(Fonts.soraReward, {{255/255, 247/255, 160/255}, "Turn Left : ", {255/255, 223/255, 120/255}, tostring(self.round.remainingHands)})

    local coworkerDollars = love.graphics.newText(Fonts.soraReward, {{255/255, 178/255, 89/255}, string.rep("$", self.round.baseReward)})
    local turnsDollars = love.graphics.newText(Fonts.soraReward, {{255/255, 178/255, 89/255}, string.rep("$", self.round.remainingHands)})

    local totalReward = love.graphics.newText(
        Fonts.soraRewardTotal, 
        {{255/255, 247/255, 160/255}, "+", 
        {255/255, 223/255, 120/255}, tostring(self.round.remainingHands + self.round.baseReward), 
        {255/255, 178/255, 89/255}, "$"})


    love.graphics.draw(Sprites.CASH_REWARD, 0, 0)

    love.graphics.draw(coworkerLabel, 20, 100)
    love.graphics.draw(coworkerDollars, 20, 140)
    love.graphics.draw(turnsLabel, 20, 180)
    love.graphics.draw(turnsDollars, 20, 220)
    love.graphics.draw(totalReward, self.moneyRewardCanvas:getWidth()/2, 367, 0, 1, 1, totalReward:getWidth()/2)

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

--==Input functions==--
function EndRound:mousepressed(x, y, button, istouch, presses)
    self.nextRoundButton:clickEvent()
    
    --DiceFaces
    for key,uiFace in next,self.faceRewards do
        uiFace:clickEvent()
    end
end

function EndRound:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    local wasReleased = self.nextRoundButton:releaseEvent()
    if(wasReleased) then --Si le click a été complété
        self.nextRoundButton:getCallback()()
    end

    for key,diceface in next,self.faceRewards do
        local wasReleased = diceface:releaseEvent()

        diceface.isBeingDragged = false
        diceface.targetX = diceface.anchorX
        diceface.targetY = diceface.anchorY
    end
    
end

function EndRound:mousemoved(x, y, dx, dy, isDragging)
    --DND dices
    if(isDragging == true)then 
        for key,diceui in next,self.faceRewards do
            print(diceui.isBeingClicked)
            if(diceui.isDraggable and diceui.isBeingClicked) then
                diceui.isBeingDragged = true
                self.dragAndDroppedDice = diceui
                diceui.dragXspeed = dx
                diceui.targetX = (diceui.targetX + dx) 
                diceui.targetY = (diceui.targetY + dy) 
                break;
            end
        end
    end
end

--UI creation
function EndRound:generateFaceRewards()
    local xPos = {145, 145}
    local yPos = {79, 236}
    local apparitionDuration = 0.3
    
    for i,face in next,self.round.faceRewards do
        local uiFace = DiceFace:new(
            nil,
            face,
            self.contentTX + 480 + 60 + xPos[i],
            self.contentTY + 140 + 60 + yPos[i],
            120,
            false,
            true,
            function()return Inputs.getMouseInCanvas(0, 0)end,
            nil
        )

        uiFace.anchorX = self.contentTX + 480 + 60 + xPos[i]
        uiFace.anchorY = self.contentTY + 140 + 60 + yPos[i]
        
        uiFace.animator:addGroup({
            --Rotation
            {property = "rotation", from = 3, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 3, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            --Scale
            {property = "baseTargetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            
        })

        table.insert(self.faceRewards, uiFace)
    end
end

--==Animation==--
function EndRound:outAnimation()
    --Dices
    for i,uiFace in next,self.faceRewards do
        uiFace.animator:addGroup({
            --Scale
            {property = "targetY", from = uiFace.targetY, targetValue = self.canvas:getHeight()+150, duration = 0.3, easing = AnimationUtils.Easing.inCubic},
            {property = "y", from = uiFace.y, targetValue = self.canvas:getHeight()+150, duration =0.3 , easing = AnimationUtils.Easing.inCubic},
            
        })
    end
    
    --Popup
    self.animator:addGroup({
        {property = "backgroundOpacity", from=0.7, targetValue=0, duration=0.3},
        {property = "contentY", from=self.contentY, targetValue=self.canvas:getHeight()+500, duration=0.3, easing=AnimationUtils.Easing.inCubic}
    })
    self.animator:addDelay(0.2, function()self.round.terrain:outAnimation()end)
end

return EndRound