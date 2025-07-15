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

    self.run = run
    self.round = round
    self.canvas = love.graphics.canvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_WIDTH)

    return self
end

function EndRound:update()

end

function EndRound:updateCanvas()
    local currentCanvas = love.graphics.getCanvas
    love.graphics.setCanvas(self.canvas)

    love.graphics.setCanvas(currentCanvas)
end

function EndRound:draw()
    love.graphics.draw(self.canvas, 0, 0, 0, 1, 1)
end

return EndRound