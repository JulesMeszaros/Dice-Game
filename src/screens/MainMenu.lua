local Fonts = require("src.utils.fonts")
local Inputs = require("src.utils.scripts.inputs")
local Constants = require("src.utils.constants")

local Button = require("src.classes.ui.Button")

local MainMenu = {}

MainMenu.__index = MainMenu

function MainMenu:new(gameCanvas, game)
    local self = setmetatable({}, MainMenu)

    self.uiElements = {
        buttons = {}
    }

    self.gameCanvas = gameCanvas
    self.game = game

    self.animationDices = {}

    --Creating the canvas
    self.mainMenuCanvas = love.graphics.newCanvas(self.gameCanvas:getWidth(), self.gameCanvas:getHeight())

    self.uiElements.buttons["newRun"] = Button:new(
        function()self.game:startNewRun()end,
        "src/assets/sprites/ui/new_run.png",
        self.gameCanvas:getWidth()/2,
        self.gameCanvas:getHeight()/2,
        400,
        167,
        self.gameCanvas,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    return self
end

function MainMenu:update(dt)
    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end

    --Update the canvas
    self:updateCanvas(dt)

end

function MainMenu:updateCanvas(dt)
    love.graphics.setCanvas(self.mainMenuCanvas)
    love.graphics.clear()

    --==Animation Dices==--

    local textTitle = love.graphics.newText(Fonts.nexaBig, "DICE GAME")
    --Main title
    love.graphics.draw(textTitle, self.mainMenuCanvas:getWidth()/2, 100, 0, 1, 1, textTitle:getWidth()/2, textTitle:getHeight()/2)

    --Version
    local versionText = love.graphics.newText(Fonts.nexaSmall, "AEROSOL DELUXE GAMES — "..Constants.GAME_VERSION)
    love.graphics.draw(versionText, 20, self.mainMenuCanvas:getHeight()-20, 0, 1, 1, 0, versionText:getHeight())

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:draw()
    end

    love.graphics.setCanvas(self.gameCanvas)
end

function MainMenu:draw()
    love.graphics.draw(self.mainMenuCanvas, 0, 0)

end

--==MAIN MENU ANIMATION==--

--==KEYBOARD/MOUSE INPUTS==--

function MainMenu:keypressed(key)
    print("keypressed")
end

function MainMenu:mousepressed(x, y, button, istouch, presses)
   --Buttons
   for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end
end

function MainMenu:mousereleased(x, y, button, istouch, presses)
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end
end

function MainMenu:mousemoved(x, y, dx, dy, isDragging)
    
end

return MainMenu