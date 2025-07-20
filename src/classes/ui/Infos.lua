local Sprites = require("src/utils/Sprites")
local Constants = require("src/utils/Constants")
local Animator = require("src/utils/Animator")

local Infos = {}
Infos.__index = Infos

function Infos:new(run)
    local self = setmetatable({}, Infos)

    self.run = run
    self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_HEIGHT)
    self.animator = Animator:new(self)

    --UI Canvas
    self.gridLarge = love.graphics.newCanvas(720, 670)
    self.inventoryLarge = love.graphics.newCanvas(770, 340)
    self.descriptions = love.graphics.newCanvas(420, 600)
    self.playerBadge = love.graphics.newCanvas(500, 670)
    self.progression = love.graphics.newCanvas(160,980)

    --UI Positions
    self.gridLX, self.gridLY = 30, 30
    self.inventoryLX, self.inventoryLY = 500, 720
    self.descriptionsX, self.descriptionsY = 1470, 30
    self.playerBadgeX, self.playerBadgeY = 770, 30
    self.progressionX, self.progressionY = 1290, 52

    --Start animations

    return self
end

function Infos:update()

end

function Infos:updateCanvas()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", 0, 0, self.canvas:getWidth(), self.canvas:getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    self:drawGridLarge()
    self:drawInventoryLarge()
    self:drawDescriptions()
    self:drawPlayerBadge()
    self:drawProgression()
    
    love.graphics.setCanvas(currentCanvas)
end

function Infos:draw()
    love.graphics.draw(self.canvas, 0, 0, 0, 1, 1)
end

--UI functions
function Infos:drawGridLarge()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.gridLarge)
    love.graphics.clear()

    love.graphics.draw(Sprites.GRID_LARGE, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.gridLarge, self.gridLX, self.gridLY)
end

function Infos:drawInventoryLarge()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.inventoryLarge)
    love.graphics.clear()

    love.graphics.draw(Sprites.INVENTORY_LARGE, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.inventoryLarge, self.inventoryLX, self.inventoryLY)
end

function Infos:drawDescriptions()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.descriptions)
    love.graphics.clear()

    love.graphics.draw(Sprites.OFFICE_DESCRIPTION, 0, 0)
    love.graphics.draw(Sprites.FLOOR_DESCRIPTION, 0, 407)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.descriptions, self.descriptionsX, self.descriptionsY)
end

function Infos:drawPlayerBadge()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.playerBadge)
    love.graphics.clear()

    love.graphics.draw(Sprites.PLAYER_BADGE, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.playerBadge, self.playerBadgeX, self.playerBadgeY)
end

function Infos:drawProgression()
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.progression)
    love.graphics.clear()

    love.graphics.draw(Sprites.PROGRESSION, 0, 0)

    love.graphics.setCanvas(currentCanvas)
    love.graphics.draw(self.progression, self.progressionX, self.progressionY)
end

return Infos