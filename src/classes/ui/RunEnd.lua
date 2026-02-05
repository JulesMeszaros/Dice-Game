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
local UI = require("src.utils.scripts.UI")

local RunEnd = {}
RunEnd.__index = RunEnd

function RunEnd:new(run, round)
	local self = setmetatable({}, RunEnd)

	self.animator = Animator:new(self)
	self.run = run
	self.round = round

	--UI Elements
	self.backgroundOpacity = 0

	--Create the text objects
	self.seedText = love.graphics.newText(Fonts.sora30, G.seedText)
	self.bestHandText = love.graphics.newText(Fonts.sora30, tostring(G.game.run.bestHand))

	local maxPlayed = 1
	local maxPlayedCount = 0

	for figure, info in pairs(G.game.run.figuresInfos) do
		print(figure, info.playcount)
		if info.playcount > maxPlayedCount then
			maxPlayed = figure
			maxPlayedCount = info.playcount
		end
	end

	self.mostPlayedText = love.graphics.newText(Fonts.sora30, Constants.FIGURES_LABELS[maxPlayed])

	--Canvas
	self.canvas = love.graphics.newCanvas(Constants.VIRTUAL_GAME_WIDTH, Constants.VIRTUAL_GAME_WIDTH)
	self.contentCanvas = love.graphics.newCanvas(930, 760)

	G.animator:addGroup({
		{ property = "backgroundR", from = G.backgroundR, targetValue = 208 / 255, duration = 0.6 },
		{ property = "backgroundG", from = G.backgroundG, targetValue = 180 / 255, duration = 0.6 },
		{ property = "backgroundB", from = G.backgroundB, targetValue = 67 / 255, duration = 0.6 },
	})

	--You Won Text
	self.youWon = UI.Text.TextWavy:new("Victory!", self.contentCanvas:getWidth() / 2, 70, {
		centered = true,
		font = Fonts.soraYouWon,
		colorStart = { 40 / 255, 40 / 255, 46 / 255 },
		amplitude = 4,
		speed = 2,
	})

	--Button
	self.copySeed = Button:new(
		function()
			love.system.setClipboardText(G.seedText)
		end,
		"src/assets/sprites/ui/CopySeed.png",
		400,
		555,
		100,
		60,
		self.run.gameCanvas,
		function()
			return Inputs.getMouseInCanvas(self.contentX, self.contentY)
		end
	)

	self.newRunButton = Button:new(
		function()
			self:outAnimation("newRun")
		end,
		"src/assets/sprites/ui/New Run 2.png",
		480 + 200,
		650 + 40,
		400,
		80,
		self.run.gameCanvas,
		function()
			return Inputs.getMouseInCanvas(self.contentX, self.contentY)
		end
	)

	self.mainMenuButton = Button:new(
		function()
			self:outAnimation("mainMenu")
		end,
		"src/assets/sprites/ui/Main Menu.png",
		50 + 200,
		650 + 40,
		400,
		80,
		self.run.gameCanvas,
		function()
			return Inputs.getMouseInCanvas(self.contentX, self.contentY)
		end
	)

	--Positions
	self.contentTX, self.contentTY, self.contentX, self.contentY = 510, 320, 510, self.canvas:getHeight() + 770

	--Animations
	local inDuration = 0.3
	self.animator:addGroup({
		{
			property = "backgroundOpacity",
			from = 0,
			targetValue = 0.7,
			duration = inDuration,
			easing = AnimationUtils.Easing.outCubic,
		},
		{
			property = "contentY",
			from = self.contentY,
			targetValue = self.contentTY,
			duration = inDuration,
			easing = AnimationUtils.Easing.outCubic,
		},
	})

	return self
end

function RunEnd:update(dt)
	self.animator:update(dt)
end

function RunEnd:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	--Pop up content
	self:drawMainCanvas(dt)

	love.graphics.setCanvas(currentCanvas)
end

--update the different canvas
function RunEnd:drawMainCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.contentCanvas)
	love.graphics.clear()

	--Background
	love.graphics.draw(Sprites.END_RUN_BG, 0, 0)

	--Update top text
	self.youWon:update(dt)
	self.youWon:draw()

	--Buttons
	self.copySeed:update(dt)

	self.mainMenuButton:update(dt)
	self.newRunButton:update(dt)
	self.mainMenuButton:draw()
	self.newRunButton:draw()
	self.copySeed:draw()

	--Stats texts
	love.graphics.setColor(232 / 255, 79 / 255, 79 / 255)
	love.graphics.draw(self.bestHandText, 750, 279, 0, 1, 1, self.bestHandText:getWidth(), 0)
	love.graphics.draw(self.mostPlayedText, 750, 408, 0, 1, 1, self.mostPlayedText:getWidth(), 0)
	love.graphics.draw(self.seedText, 750, 540, 0, 1, 1, self.seedText:getWidth(), 0)
	love.graphics.setColor(1, 1, 1)

	love.graphics.setCanvas(currentCanvas)
	love.graphics.draw(self.contentCanvas, self.contentX, self.contentY)
end

function RunEnd:draw()
	love.graphics.draw(self.canvas, 0, 0, 0, 1, 1)
end

--==Input functions==--
function RunEnd:mousepressed(x, y, button, istouch, presses)
	self.mainMenuButton:clickEvent()
	self.copySeed:clickEvent()
	self.newRunButton:clickEvent()
end

function RunEnd:mousereleased(x, y, button, istouch, presses)
	--release event on UI elements (buttons)
	for key, button in next, { self.copySeed, self.mainMenuButton, self.newRunButton } do
		local wasReleased = button:releaseEvent()
		if wasReleased then --Si le click a été complété
			button:getCallback()()
		end
	end
end

function RunEnd:mousemoved(x, y, dx, dy, isDragging) end

--==Animation==--
function RunEnd:outAnimation(nextScreen)
	--Popup
	self.animator:addGroup({
		{ property = "backgroundOpacity", from = 0.7, targetValue = 0, duration = 0.3 },
		{
			property = "contentY",
			from = self.contentY,
			targetValue = self.canvas:getHeight() + 500,
			duration = 0.3,
			easing = AnimationUtils.Easing.inCubic,
		},
	})

	self.animator:addDelay(0.2, function()
		self.round.terrain:outAnimation("mainMenu")
	end)
end

return RunEnd
