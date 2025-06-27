local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local AnimationUtils = require("src.utils.scripts.Animations")
local Sprites = require("src.utils.Sprites")
local Ciggie = require("src.classes.ui.Ciggie")
local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")
local Badge = require("src.classes.ui.Badge")
local DiceFace = require("src.classes.ui.DiceFace")
local Screen = require("src.classes.GameScreen")

local Shop = setmetatable({}, {__index = Screen})
Shop.__index = Shop

function Shop:new(run)
    local self = setmetatable(Screen:new(run.currentFloor, run, Constants.RUN_STATES.SHOP), Shop)

    self:createDiceNet()
    self:createDeck()
    self:generateCiggiesUI()

    return self
end

function Shop:update(dt)
    self.animator:update(dt)

    self:updateCanvas(dt)
end

function Shop:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    --Buttons
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
    self:drawCiggiesTray()

     --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
        ciggie:draw()
    end
    

    love.graphics.setCanvas(currentCanvas)
end

function Shop:draw()
    love.graphics.draw(self.canvas, 0, 0)
end

--==Update functions==--
function Shop:mousepressed(x, y, button, istouch, presses)

end

function Shop:mousereleased(x, y, button, istouch, presses)

end

function Shop:mousemoved(x, y, dx, dy)

end

function Shop:keypressed(key)
    print(key)
end

--==UTILS==--
function Shop:getCurrentlyHoveredObject()
    return nil
end

--==Additionnal init functions==--
function Shop:createDeck()
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

--==Additionnal draw functions==--
function Shop:drawDeck(dt)
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

function Shop:drawDiceDetails(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceDetailsCanvas)
    love.graphics.clear()

    --Draw sprite
    love.graphics.draw(Sprites.DICE_INFOS, 0, 0)
    
    --Draw the dice net
    --[[ if(self.currentlySelectedDice)then
        self:updateDiceNet(dt)
    end ]]

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.diceDetailsCanvas, self.diceDetailsX, self.diceDetailsY, 0, 1, 1, self.diceDetailsCanvas:getWidth(), 0)
end



return Shop