local DiceFace = require("src.classes.ui.DiceFace")
local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")

local DiceCustomization = {}
DiceCustomization.__index = DiceCustomization

function DiceCustomization:new(previousRound, newFacesObjects)
    local self = setmetatable({}, DiceCustomization)

    self.uiElements = {
        buttons = {}
    }

    --Objects
    self.diceObjects = previousRound.diceObjects
    self.previousRound = previousRound

    --Table where we store the ui dice faces, grouped by dice
    self.uiDices = {}
    --On peuple notre table
    for i,dice in next, self.diceObjects do
        table.insert(self.uiDices, self:createDiceUI(dice, i))
    end

    --Create the canvas
    self.screenCanvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)

    return self
end

function DiceCustomization:update(dt)
    --update the canvas
    self:updateCanvas(dt)

    --Update the dice faces
    --Draw the uiFaces on the canvas
    for i,uiDice in next,self.uiDices do
        for j,uiFace in next,uiDice do
            print(uiFace:update(dt))
        end
    end
end

function DiceCustomization:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.screenCanvas)
    love.graphics.clear(1, 0.2, 0)

    --Draw the uiFaces on the canvas
    for i,uiDice in next,self.uiDices do
        for j,uiFace in next,uiDice do
            print(uiFace:draw())
        end
    end

    love.graphics.setCanvas(currentCanvas)
end

function DiceCustomization:draw()
    love.graphics.draw(self.screenCanvas, 0, 0)
end

--==INPUTS FUNCTIONS==--
function DiceCustomization:keypressed(key)
    print("keypressed")
end

function DiceCustomization:mousepressed(x, y, button, istouch, presses)
   --Buttons
   for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end
end

function DiceCustomization:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end
end

function DiceCustomization:mousemoved(x, y, dx, dy, isDragging)

end

--==UTILS=--
function DiceCustomization:createDiceUI(diceObject, i)
    --This function creates every faces of a ui Dice and stores them in a table located in self.uiDices
    local diceUI = {}
    local xOffset = (20)+(i-1)*380 -- the base position of the dice
    local yOffset = 400
    
    local relativeXPositions = { -- this table represents the position of the dice after applying the offset
        180, 60, 180, 300, 180, 180
    }

    local relativeYPosition = {
        60, 180, 180, 180, 300, 420
    }

    for k,faceObject in next,diceObject:getAllFaces() do
        
        --Create a dice face ui with the dice
        local diceFace = DiceFace:new(diceObject,
                                    faceObject,
                                    xOffset + relativeXPositions[k],
                                    yOffset + relativeYPosition[k],
                                    120,
                                    false,
                                    true,
                                    function()return Inputs.getMouseInCanvas(0, 0)end,
                                    nil)
        table.insert(diceUI, diceFace)
    end

    return diceUI
end

return DiceCustomization