local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")
local Fonts = require("src.utils.fonts")

local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")

local Button = require("src.classes.ui.Button")
local Round = require("src.classes.Round")
local DiceFace = require("src.classes.ui.DiceFace")

local DeskChoice = {}

DeskChoice.__index = DeskChoice

local choiceNumber = 3

function DeskChoice:new(floor, run)
    local self = setmetatable({}, DeskChoice)
  
    self.uiElements = {
        buttons = {},
        DeskChoiceButtons = {},
        faceRewards = {}
    }
   
    self.currentlyHoveredFace = nil
    self.previouslyHoveredFace = nil

    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    self.floor = floor
    self.run = run
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

    --Face survolée
    self:getCurrentlyHoveredFace()

    for i=1, table.getn(self.choiceCanvas) do
        self:updateChoiceCanvas(self.choiceCanvas[i], dt, i)
        love.graphics.draw(self.choiceCanvas[i], 50+(i-1)*(20+self.choiceCanvasWidth), 200)
    end

    local topText = love.graphics.newText(Fonts.nexaMedium, "Choisissez votre bureau...")
    local deskText = love.graphics.newText(Fonts.nexaMedium, "Bureau "..tostring(self.run.floorDeskNumber).."/3")
    local floorText = love.graphics.newText(Fonts.nexaMedium, "Etage "..tostring(self.floor.floorNumber))

    love.graphics.draw(topText, self.canvas:getWidth()/2, 50, 0, 1, 1, topText:getWidth()/2, 0)
    love.graphics.draw(deskText, self.canvas:getWidth()/2, 100, 0, 1, 1, deskText:getWidth()/2, 0)
    love.graphics.draw(floorText, self.canvas:getWidth()/2, 150, 0, 1, 1, floorText:getWidth()/2, 0)


    love.graphics.setCanvas(currentCanvas)
end

function DeskChoice:draw()
    love.graphics.draw(self.canvas, 0, 0)
end

--==CHOICES==--
function DeskChoice:generateChoiceCanvas()
    self.choiceCanvas = {}
    --On calcule la largeur de chaque canvas sachant que : On vaut 50px de marge sur les cotés, et 20px entre chaque canvas
    self.choiceCanvasWidth = ((self.canvas:getWidth()-100)/(choiceNumber))-((20*(choiceNumber-1))/choiceNumber)
    self.choiceCanvasHeight = self.canvas:getHeight()-300
    for i = 1, table.getn(self.possibleRounds) do
        local c = love.graphics.newCanvas(self.choiceCanvasWidth, self.choiceCanvasHeight)
        table.insert(self.choiceCanvas, c)

        --Create the next round button
        local chooseButton = Button:new(
            function()self.run:startNewRound(self.possibleRounds[i])end,
            "src/assets/sprites/ui/buttons/next_round.png",
            self.choiceCanvasWidth/2,
            self.choiceCanvasHeight-50,
            300/2,
            125/2,
            self.canvas,
            function()return Inputs.getMouseInCanvas(50+(i-1)*(20+self.choiceCanvasWidth), 200)end
        )
        table.insert(self.uiElements.DeskChoiceButtons, chooseButton)

        --Create the rewards to be displayed
        local roundFaceRewards = {}

        --Calcul de la position des faces de dés dans le canvas
        local xPositions = self:getCenteredPositions(table.getn(self.possibleRounds[i].faceRewards), 120, 20, (c:getWidth()/2)+60)

        for j = 1, table.getn(self.possibleRounds[i].faceRewards) do
            local faceUI = DiceFace:new(
                nil,
                self.possibleRounds[i].faceRewards[j],
                xPositions[j],
                450,
                120,
                false,
                true,
                function()return Inputs.getMouseInCanvas(50+(i-1)*(20+self.choiceCanvasWidth), 200)end,
                self.possibleRounds[i]
            )
            table.insert(roundFaceRewards, faceUI)
        end
        table.insert(self.uiElements.faceRewards, roundFaceRewards)
    end
end

function DeskChoice:updateChoiceCanvas(c, dt, i)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(c)
    love.graphics.clear(49/256, 74/256, 50/256)
    --Draw the outline
    love.graphics.rectangle("line", 0, 0, c:getWidth(), c:getHeight())
    --Create the texts
    local rewardText = love.graphics.newText(Fonts.nexaMedium, "Reward : "..tostring(self.possibleRounds[i].baseReward).."€")
    local targetText = love.graphics.newText(Fonts.nexaMedium, "Target : "..tostring(self.possibleRounds[i].targetScore).." pts")
    local deskNumberText = love.graphics.newText(Fonts.nexaMedium, "Desk : "..tostring(self.possibleRounds[i].deskNumber))
    local jobText = love.graphics.newText(Fonts.nexaMedium, self.possibleRounds[i].enemyJob)
    --Draw the texts
    love.graphics.draw(rewardText, c:getWidth()/2, 350, 0, 1, 1, rewardText:getWidth()/2, rewardText:getHeight()/2)
    love.graphics.draw(deskNumberText, c:getWidth()/2, 50, 0, 1, 1, deskNumberText:getWidth()/2, deskNumberText:getHeight()/2)
    love.graphics.draw(jobText, c:getWidth()/2, 120, 0, 1, 1, jobText:getWidth()/2, jobText:getHeight()/2)
    love.graphics.draw(targetText, c:getWidth()/2, 180, 0, 1, 1, targetText:getWidth()/2, targetText:getHeight()/2)

    --Update and draw the buttons
    self.uiElements.DeskChoiceButtons[i]:update(dt)
    self.uiElements.DeskChoiceButtons[i]:draw()

    --Update and draw the UIFace
    for i,roundReward in next,self.uiElements.faceRewards[i] do
        roundReward:update(dt)
        roundReward:draw()

        --Draw the face info
        if(self.currentlyHoveredFace == roundReward)then
            self.hoverInfosCanvas:update(dt)
            self.hoverInfosCanvas:draw()
        end
    end

    

    love.graphics.setCanvas(currentCanvas)
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

    --Buttons
   for key,button in next,self.uiElements.DeskChoiceButtons do
        button:clickEvent()
    end
end

function DeskChoice:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    --release event on UI elements (choice buttons)
    for key,button in next,self.uiElements.DeskChoiceButtons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end
end

function DeskChoice:mousemoved(x, y, dx, dy, isDragging)

end

--==Utils==--

function DeskChoice:createFaceInfosCanvas(face)
    return FaceHoverInfo:new(face)
end

function DeskChoice:getCurrentlyHoveredFace()
    self.previouslyHoveredFace = self.currentlyHoveredFace --We save the state of the frame before
    self.currentlyHoveredFace = nil

    for i,round in next,self.uiElements.faceRewards do
        for j,face in next,round do
            if face:isHovered() then self.currentlyHoveredFace = face ; break end
        end
    end

    --Si un dé est survolé et qu'il est différent du dé précédent alors on créé un nouveau canvas d'infos
    if(self.currentlyHoveredFace ~= self.previouslyHoveredFace) then
        if (self.currentlyHoveredFace) then
            self.hoverInfosCanvas = self:createFaceInfosCanvas(self.currentlyHoveredFace)
        end
    end

end

function DeskChoice:getCenteredPositions(count, objectWidth, spacing, centerX)
    local totalWidth = count * objectWidth + (count - 1) * spacing
    local startX = centerX - totalWidth / 2

    local positions = {}
    for i = 0, count - 1 do
        local x = startX + i * (objectWidth + spacing)
        table.insert(positions, x)
    end

    return positions
end

return DeskChoice