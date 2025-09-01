local Shaders = require("src.utils.Shaders")
local Fonts = require("src.utils.Fonts")
local Animator = require("src.utils.Animator")
local AnimationUtils = require("src.utils.scripts.Animations")
local Inputs = require("src.utils.scripts.Inputs")
local Button = require("src.classes.ui.Button")
local Sprites = require("src.utils.Sprites")
local Constants = require("src.utils.Constants")

local CoffeeButton = setmetatable({}, { __index = Button })
CoffeeButton.__index = CoffeeButton

function CoffeeButton:new(x, y, mousePosition, figureIndex, run)
	local self = setmetatable(
		Button:new(nil, "src/assets/sprites/coffee/Black.png", x, y, 350, 60, nil, mousePosition),
		CoffeeButton
	)

	--Spécifics
	self.used = false
	self.figureIndex = figureIndex
	self.sprite = Sprites.COFFEE_SPRITES[self.figureIndex]
	self.run = run

	self.representedObject = {
		name = Constants.COFFEE_NAMES[self.figureIndex],
		objectType = "Coffee",
		description = "Upgrades the figure "
			.. Constants.FIGURES_LABELS[self.figureIndex]
			.. " of one level (lvl."
			.. tostring(self.run.figuresInfos[self.figureIndex].level)
			.. " -> lvl."
			.. tostring(self.run.figuresInfos[self.figureIndex].level + 1)
			.. ")",
	}

	self.representedObject.getDescription = function()
		return "Upgrades the figure "
			.. Constants.FIGURES_LABELS[self.figureIndex]
			.. " of one level (lvl."
			.. tostring(self.run.figuresInfos[self.figureIndex].level)
			.. " -> lvl."
			.. tostring(self.run.figuresInfos[self.figureIndex].level + 1)
			.. ")"
	end

	self.absoluteX = 0
	self.absoluteY = 0

	return self
end

function CoffeeButton:update(dt)
	self.animator:update(dt)

	if self:isHovered() and self.used == false and self.isActivated == true then
		self.targetedScale = 1.03
		if love.mouse.isDown(1) and self.isActivated then
			self.targetedScale = 0.97
		end
	else
		self.targetedScale = 1
	end

	local speed = 30
	self.scale = self:dampLerp(self.scale, self.targetedScale, speed, dt)

	--update the button canvas
	self:updateCanvas()
end

function CoffeeButton:updateCanvas()
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.uiCanvas)
	love.graphics.clear()

	--If desactivated : grey the button
	if self.used == true then
		love.graphics.setShader(Shaders.grayscaleShader)
	elseif self:isHovered() then
		love.graphics.setShader(Shaders.glowShader)
		Shaders.glowShader:send("glow_strength", 0.4)
		Shaders.glowShader:send("glow_color", Constants.FIGURES_COLORS[self.figureIndex]) -- un jaune doré
	else
		love.graphics.setShader()
	end

	love.graphics.draw(self.sprite, 0, 0, 0, 1, 1)

	love.graphics.setShader()

	love.graphics.setCanvas(currentCanvas)
end

--Interaction functions
function CoffeeButton:clickAction()
	if self.run.money >= Constants.BASE_COFFEE_PRICE and self.used == false then
		--Retirer l'argent
		self.run.money = self.run.money - Constants.BASE_COFFEE_PRICE
		self.run.totalspent = self.run.totalspent + Constants.BASE_COFFEE_PRICE

		--Level Up la figure
		self.run.totalUsedCoffees = self.run.totalUsedCoffees + 1
		self.run:levelUpFigure(self.figureIndex)

		--Desactiver le bouton
		self.used = true
		self.isActivated = false
	end
end

return CoffeeButton

