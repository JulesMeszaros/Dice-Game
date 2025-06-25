local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local AnimationUtils = require("src.utils.scripts.Animations")
local Sprites = require("src.utils.Sprites")
local Ciggie = require("src.classes.ui.Ciggie")
local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")
local Badge = require("src.classes.ui.Badge")
local DiceFace = require("src.classes.ui.DiceFace")
local Screen = require("src.classes.GameScreen")

local DeskChoice = setmetatable({}, { __index = Screen })
DeskChoice.__index = DeskChoice

local choiceNumber = 4

function DeskChoice:new(floor, run)
    local self = setmetatable(Screen:new(floor, run, Constants.RUN_STATES.ROUND_CHOICE), DeskChoice)

    --Créer le deck
    self:createDeck()

    --Créer le dice net
    self:createDiceNet()

    self.round = run.currentRound

    if(self.run.floorDeskNumber < 4) then
        self.possibleRounds = self.floor.desks[self.run.floorDeskNumber]
    else
        self.possibleRounds = {self.floor.boss}
    end

    --Création des différents canvas de choix de round
    self:generateChoiceCanvas()

    return self
end

function DeskChoice:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    self.animator:update(dt)

    --hovered objects
    self:getCurrentlyHoveredFace()
    self:getCurrentlyHoveredCiggie()

    for key,button in next,self.uiElements.buttons do
        button:update(dt)
        button:draw()
    end

    --UI
    self:drawDeck(dt)
    self:drawDescription()
    self:drawFigureGrid()
    self:drawRoundDetails()
    self:drawDiceDetails(dt)
    self:updateChoiceCanvas(dt)
    self:drawCiggiesTray()

    

     --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
        ciggie:draw()
    end

    love.graphics.setCanvas(currentCanvas)
end

function DeskChoice:draw()
    love.graphics.draw(self.canvas, 0, 0)
end

--==UI==--

--Deck
function DeskChoice:createDeck()
    local deckFaces = {}
    for i,dice in next,self.diceObjects do
        --Create the UIFaces
        local faceUI = DiceFace:new(
                dice,
                dice:getFace(1),
                self.deckCanvas:getWidth()/2+1,
                70+((i-1)*180),
                120,
                true,
                true,
                function()return Inputs.getMouseInCanvas(1300, 110)end,
                nil
            )
        deckFaces[dice] = faceUI
    end
    self.deckFaces = deckFaces
end 

function DeskChoice:drawDeck(dt)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.deckCanvas)
    love.graphics.clear()
    
    --Draw the background
    love.graphics.draw(Sprites.DECK, 0, 0)

    --draw the deck faces
    for dice,face in next,self.deckFaces do
        if(face:getIsSelected())then
            face.selectionScale = 0.1
        else
            face.selectionScale = 0
        end
        face:update(dt)
        face:draw()
    end

    love.graphics.setCanvas(targetCanvas)
    love.graphics.draw(self.deckCanvas, self.deckX, self.deckY)
end

function DeskChoice:updateDiceNet(dt)
   local i = 1
    for k,df in next,self.infoFaces do
        df:setRepresentedFace(self.currentlySelectedDice.diceObject:getFace(i))
        df:updateSprite()
        df:update(dt)
        df:draw()
        i =i+1
    end
end

function DeskChoice:drawDiceDetails(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceDetailsCanvas)
    love.graphics.clear()

    --Draw sprite
    love.graphics.draw(Sprites.DICE_INFOS, 0, 0)
    
    --Draw the dice net
    if(self.currentlySelectedDice)then
        self:updateDiceNet(dt)
    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.diceDetailsCanvas, self.diceDetailsX, self.diceDetailsY, 0, 1, 1, self.diceDetailsCanvas:getWidth(), 0)
end

--==CHOICES==--
function DeskChoice:generateChoiceCanvas()
    self.badges = {}
    self.choiceCanvas = {}

    local coords = {
        {510, 30},
        {905, 30},
        {510, 550},
        {905, 550},
    }

    local originalY = {
        -1000, -1000, 3000, 3000
    }

    for i=1, table.getn(self.possibleRounds) do
        local c = love.graphics.newCanvas(220*1.5, 330*1.5)
        local b = Badge:new(self.possibleRounds[i], coords[i][1], coords[i][2], originalY[i], 370, 500, function()return Inputs.getMouseInCanvas(0, 0)end)
        table.insert(self.choiceCanvas, c)
        table.insert(self.badges, b)
    end

end

function DeskChoice:updateChoiceCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()

    local coords = {
        {550, 30},
        {908, 30},
        {550, 555},
        {908, 555},
    }

    for i,badge in next,self.badges do
        badge:update(dt)
        badge:draw()
    end
    
end

--==INPUT FUNCTIONS==--

function DeskChoice:keypressed(key)
    print("keypressed")
end

function DeskChoice:mousepressed(x, y, button, istouch, presses)
   --Buttons
   for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end

    --Badges
   for key,badge in next,self.badges do
        badge:clickEvent()
    end

    --Deck faces
    for key,uiFace in next,self.deckFaces do
        uiFace:clickEvent()
    end

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:clickEvent()
    end

end

function DeskChoice:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,badge in next,self.badges do
        local wasReleased = badge:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            self:outAnimation(badge)
        end
    end

    for key,face in next,self.deckFaces do
        local wasReleased = face:releaseEvent()
        if(wasReleased)then --On sélectionne la face a switcher
            self:resetSelectedDices()
            face:setSelected(true)
            self.currentlySelectedDice = face
        end
    end

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:releaseEvent()
        ciggie.isBeingDragged = false
    end
end

function DeskChoice:mousemoved(x, y, dx, dy, isDragging)
    --Drag and drop Ciggies
    if(isDragging == true)then 
        for key,ciggie in next, self.uiElements.ciggiesUI do
            if(ciggie.isDraggable and ciggie.isBeingClicked) then
                ciggie.isBeingDragged = true
                ciggie.dragXspeed = dx
                if(ciggie.targetX+dx<self.canvas:getWidth()-ciggie.width/2 and ciggie.targetX+dx>0+ciggie.width/2) then --Vérification qu'on ne dépasse par les limites horizontales
                    ciggie.targetX = (ciggie.targetX + dx) 
                end

                if(ciggie.targetY+dy<self.canvas:getHeight()-ciggie.height/2 and ciggie.targetY+dy>0+ciggie.height/2) then --Vérification qu'on ne dépasse pas les limites verticales
                    ciggie.targetY = (ciggie.targetY + dy) 
                end
            end
        end
    end
end

--==Utils==--

function DeskChoice:outAnimation(badge)
    local outDuration = 0.2
    local newBadgeY = {
        -1000, -1000, 3000, 3000
    }

    self.animator:addGroup({
        {property = "gridY", from = self.gridY, targetValue = -820, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "deckY", from = self.deckY, targetValue = self.canvas:getHeight()+20, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.canvas:getWidth()+450, duration = outDuration, easing = AnimationUtils.Easing.inCubic},

        {property = "moneyY", from = self.moneyY, targetValue = self.canvas:getHeight()+300, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = -730, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = -500, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.canvas:getHeight()+400, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
    })


    for i=1, table.getn(self.badges) do
        self.badges[i].animator:add("y", self.badges[i].y, newBadgeY[i], 0.4, AnimationUtils.Easing.inCubic)
    end

    --Buttons animation
    self.uiElements.buttons["menuButton"].animator:add('x', self.menuBtnX, -150, outDuration)
    self.uiElements.buttons["planButton"].animator:add('x', self.planBtnX, -150, outDuration)

    
    self.animator:addDelay(0.5, function()self.run:startNewRound(badge.round, badge.round.roundtype)end)
end

function DeskChoice:resetSelectedDices()
    --Dice faces
    for key,face in next,self.deckFaces do
        face:setSelected(false)
    end
end

function DeskChoice:createFaceInfosCanvas(face)
    return FaceHoverInfo:new(face, "both")
end

function DeskChoice:getCurrentlyHoveredCiggie()
    self.currentlyHoveredCiggie = nil

    for i,ciggie in next,self.uiElements.ciggiesUI do
        if(ciggie:isHovered())then
            self.currentlyHoveredCiggie = ciggie
            break
        end
    end
end

function DeskChoice:getCurrentlyHoveredFace()
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

--Gets the currently hovered object (dice, ciggie, etc...)
function DeskChoice:getCurrentlyHoveredObject()
    local object = nil

    if(self.currentlyHoveredCiggie)then object = self.currentlyHoveredCiggie.representedObject
    elseif(self.currentlyHoveredFace)then object = self.currentlyHoveredFace.representedObject
    else object = nil end

    return object
end

return DeskChoice