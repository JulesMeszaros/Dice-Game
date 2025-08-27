local Fonts = require("src.utils.Fonts")
local Inputs = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local Sprites = require("src.utils.Sprites")

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
    self.mainMenuCanvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)

    -- Create version text only once
    self.versionText = love.graphics.newText(Fonts.soraSmall, "AEROSOL DELUXE GAMES — "..Constants.GAME_VERSION)

    self.uiElements.buttons["newRun"] = Button:new(
        function()self.game:startNewRun()end,
        "src/assets/sprites/ui/New Run.png",
        618+678/2,
        730+180/2,
        678,
        180,
        nil,
        function()return Inputs.getMouseInCanvas(0, 0)end
    )

    G.backgroundChange(Constants.BACKGROUND_COLORS.DARK_GRAY, 0.5)

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
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.mainMenuCanvas)
    love.graphics.clear()

    --==Animation Dices==--

    --Main title
    love.graphics.draw(Sprites.MAIN_LOGO, self.mainMenuCanvas:getWidth()/2, 75, 0, 1, 1, Sprites.MAIN_LOGO:getWidth()/2, 0)

    --Version
    love.graphics.draw(self.versionText, 20, self.mainMenuCanvas:getHeight()-20, 0, 1, 1, 0, self.versionText:getHeight())

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:draw()
    end

    love.graphics.setCanvas(currentCanvas)
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

function MainMenu:cleanup()
    -- Release main menu canvas
    if self.mainMenuCanvas then
        self.mainMenuCanvas:release()
        self.mainMenuCanvas = nil
    end

    -- Release button canvases
    for _, button in pairs(self.uiElements.buttons) do
        if button.uiCanvas then
            button.uiCanvas:release()
            button.uiCanvas = nil
        end
    end

    -- Release version text
    if self.versionText then
        self.versionText:release()
        self.versionText = nil
    end
end

return MainMenu