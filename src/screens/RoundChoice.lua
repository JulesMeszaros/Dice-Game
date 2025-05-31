local Constants = require("src.utils.constants")
local Inputs = require("src.utils.scripts.inputs")
local Fonts = require("src.utils.fonts")

local RoundChoice = {
    uiElements = {
        buttons = {}
    }
}
RoundChoice.__index = RoundChoice

local choiceNumber = 4

function RoundChoice:new()
    local self = setmetatable({}, RoundChoice)
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)

    self.choiceCanvas = {}
    --On calcule la largeur de chaque canvas sachant que : On vaut 50px de marge sur les cotés, et 20px entre chaque canvas
    self.choiceCanvasWidth = ((self.canvas:getWidth()-100)/(choiceNumber))-((20*(choiceNumber-1))/choiceNumber)
    for i = 1, choiceNumber do
        local c = love.graphics.newCanvas(self.choiceCanvasWidth, self.canvas:getHeight()-300)
        table.insert(self.choiceCanvas, c)
    end

    return self
end

function RoundChoice:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    for i=1, table.getn(self.choiceCanvas) do
        print(i)
        self:updateChoiceCanvas(self.choiceCanvas[i], dt)
        love.graphics.draw(self.choiceCanvas[i], 50+(i-1)*(20+self.choiceCanvasWidth), 200)
    end

    local topText = love.graphics.newText(Fonts.pixelatedMedium, "Choisissez votre round...")
    love.graphics.draw(topText, self.canvas:getWidth()/2, 50, 0, 1, 1, topText:getWidth()/2, 0)


    love.graphics.setCanvas(currentCanvas)

end

function RoundChoice:draw()
    love.graphics.draw(self.canvas, 0, 0)
end

--==CHOICES==--
function RoundChoice:updateChoiceCanvas(c, dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(c)
    love.graphics.clear()

    love.graphics.rectangle("fill", 0, 0, c:getWidth(), c:getHeight())

    love.graphics.setCanvas(currentCanvas)
end

--==INPUT FUNCTIONS==--

function RoundChoice:keypressed(key)
    print("keypressed")
end

function RoundChoice:mousepressed(x, y, button, istouch, presses)
   --Buttons
   for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end
end

function RoundChoice:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end
end

function RoundChoice:mousemoved(x, y, dx, dy, isDragging)

end

return RoundChoice