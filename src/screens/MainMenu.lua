local Fonts = require("src.utils.fonts")
local Inputs = require("src.utils.scripts.inputs")

local Button = require("src.classes.ui.Button")
local DiceFace = require("src.classes.ui.DiceFace")
local Dice = require("src.classes.FaceTypes.Dice")

local MainMenu = {
    
}

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
        "src/assets/sprites/ui/buttons/new_run.png",
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

    --Update Animation
    self:addRandomDice()

    for k,d in next,self.animationDices do
        d:updateCanvas(dt)
        d:update(dt)
        d.targetY = d.targetY+(500+(d.targetY/2)+(d.size*2))*dt --Dépend de la hauteur et de la taille
        if(d.targetY>self.mainMenuCanvas:getHeight()+200) then
            table.remove(self.animationDices, k)
        end
    end
end

function MainMenu:updateCanvas(dt)
    love.graphics.setCanvas(self.mainMenuCanvas)
    love.graphics.clear()

    --==Animation Dices==--
    for k,d in next,self.animationDices do
        d:draw()
    end

    local textTitle = love.graphics.newText(Fonts.pixelatedBig, "DICE GAME")
    --Main title
    love.graphics.draw(textTitle, self.mainMenuCanvas:getWidth()/2, 100, 0, 1, 1, textTitle:getWidth()/2, textTitle:getHeight()/2)

    --Version
    local versionText = love.graphics.newText(Fonts.pixelated, "AEROSOL DELUXE GAMES — v0.0.4dev")
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
function MainMenu:addRandomDice()
    local rand = math.random(0, 1)
    if(rand == 1)then
        local d = Dice:new()
        local df = DiceFace:new(
            d,
            math.random(1,6),
            math.random(0, self.mainMenuCanvas:getWidth()),
            -100,
            math.random(64,200),
            false,
            true,
            function()return(Inputs.getMouseInCanvas(0,0))end,
            self.mainMenuCanvas
        )
        df.isSelected = true
        local r = math.random(0, 10)
        df.baseRotation = r
        df.rotation = r
        table.insert(self.animationDices, df)
    end
end

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