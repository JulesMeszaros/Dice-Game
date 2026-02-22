local Constants = require("src.utils.Constants")
local Shaders = require("src.utils.Shaders")
local Fonts = require("src.utils.Fonts")
local Animator = require("src.utils.Animator")
local AnimationUtils = require("src.utils.scripts.Animations")
local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")
local DiceFace = require("src.classes.ui.DiceFace")
local UIElement = require("src.classes.ui.UIElement")
local Inputs = require("src.utils.scripts.Inputs")
local Sprites = require("src.utils.Sprites")

local Badge = setmetatable({}, { __index = UIElement })
Badge.__index = Badge

function Badge:new(round, x, y, originalY, width, height, mousePosition, large)
	self.bossBadge = large

	local self = setmetatable(UIElement.new(), Badge)
	self.animator = Animator:new(self)

	self:setX(x)
	self:setY(originalY)

	self.oscillatingTime = math.random(0, 200)
	self.oscillatingY = 0

	if self.bossBadge == true then
		self.sprite = Sprites.BADGE_LARGE
	else
		self.sprite = Sprites.BADGE
	end

	self.height = height
	self.width = width
	self.targetedScale = 1

	--Hover options
	self.isHoverable = true
	self.mousePosition = mousePosition

	--Dragging options
	self.isDraggable = false
	self.dragOffsetX = 0
	self.dragOffsetY = 0

	self.round = round

	--Create the canvas ONCE
	self.uiCanvas = self:createCanvas()
	--self.uiCanvas:setFilter("nearest", "nearest")

	self:createFaceRewards(y)

	self.animator:addDelay(0.1)
	self.animator:addGroup({
		{ property = "y", from = self.y, targetValue = y, duration = 0.5, easing = AnimationUtils.Easing.outCubic },
	})
	if self.bossBadge ~= true then
		self.enemyName = love.graphics.newText(Fonts.sora30, self.round.enemyName)
	else
		self.enemyName = love.graphics.newText(Fonts.soraMedium, self.round.enemyName)
	end
	return self
end

function Badge:update(dt, opts)
	self.animator:update(dt)
	self:getCurrentlyHoveredFace()

	self.oscillatingTime = self.oscillatingTime + dt
	self.oscillatingY = AnimationUtils.osccilate(self.oscillatingTime, 8, 10)

	if self:isHovered() then
		self.targetedScale = 0.95
		if love.mouse.isDown(1) and self.isActivated then
			self.targetedScale = 0.90
		end
	else
		self.targetedScale = 1
	end

	local speed = 30
	self.scale = self:dampLerp(self.scale, self.targetedScale, speed, dt)

	--update the Badge canvas
	self:updateCanvas(dt, opts)
end

function Badge:createCanvas(gameCanvas)
	local canvas = love.graphics.newCanvas(self.width, self.height)

	--General settings
	--canvas:setFilter("nearest", "nearest")
	love.graphics.setBlendMode("alpha")
	love.graphics.setCanvas(canvas)

	love.graphics.setCanvas(gameCanvas)

	return canvas
end

function Badge:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()

	love.graphics.setCanvas(self.uiCanvas)
	love.graphics.clear()
	love.graphics.setShader(Shaders.grayRainbowShader)

	Shaders.grayRainbowShader:send("time", 4 * self.scale)
	Shaders.grayRainbowShader:send("frequency", 0.3)
	Shaders.grayRainbowShader:send("intensity", 0.3)

	love.graphics.draw(self.sprite, 0, 0) -- add the background

	love.graphics.setShader()
	--Lion
	self.round.enemyCharacter:update(dt)
	if self.bossBadge == true then
		self.round.enemyCharacter:draw(50 + 130, 150 + 135, 250, 250)
		--Nom de l'ennemi
		love.graphics.setColor(91 / 255, 113 / 255, 254 / 255)
		love.graphics.draw(
			self.enemyName,
			self.uiCanvas:getWidth() / 2,
			50,
			0,
			1,
			1,
			self.enemyName:getWidth() / 2,
			self.enemyName:getHeight() / 2
		)
		love.graphics.setColor(1, 1, 1)
	else
		self.round.enemyCharacter:draw(120, 195, 200, 200)
		--Nom de l'ennemi
		love.graphics.setColor(91 / 255, 113 / 255, 254 / 255)
		love.graphics.draw(
			self.enemyName,
			185,
			35,
			0,
			1,
			1,
			self.enemyName:getWidth() / 2,
			self.enemyName:getHeight() / 2
		)
		love.graphics.setColor(1, 1, 1)
	end

	--Texts
	local jobDeskText = love.graphics.newText(
		Fonts.soraLightMini,
		"Office " .. tostring(self.round.deskNumber) .. " - " .. tostring(self.round.enemyJob)
	)
	local targetText = love.graphics.newText(Fonts.soraLightMini, "Target : " .. tostring(self.round.targetScore))

	if self.bossBadge == true then
		jobDeskText = love.graphics.newText(
			Fonts.soraReward,
			"Office " .. tostring(self.round.deskNumber) .. " - " .. tostring(self.round.enemyJob)
		)
		targetText = love.graphics.newText(Fonts.soraMedium, "Target : " .. tostring(self.round.targetScore))

		love.graphics.draw(
			jobDeskText,
			self.uiCanvas:getWidth() / 2,
			110,
			0,
			1,
			1,
			jobDeskText:getWidth() / 2,
			jobDeskText:getHeight() / 2
		)
		love.graphics.draw(
			targetText,
			self.uiCanvas:getWidth() / 2,
			470,
			0,
			1,
			1,
			targetText:getWidth() / 2,
			targetText:getHeight() / 2
		)
	else
		love.graphics.draw(jobDeskText, self.uiCanvas:getWidth() / 2, 59, 0, 1, 1, jobDeskText:getWidth() / 2, 0)
		love.graphics.draw(targetText, 120, 330, 0, 1, 1, targetText:getWidth() / 2, targetText:getHeight() / 2)
	end

	self:updateFaceCanvas(dt)

	love.graphics.setCanvas(currentCanvas)
end

function Badge:draw()
	local px, py = G.calculateParalaxeOffset(2)
	local cx = self.x + px
	local cy = self.y + self.oscillatingY + py
	local mx, my = Inputs.getVirtualMousePosition()

	local bw = self.uiCanvas:getWidth() * self.scale
	local bh = self.uiCanvas:getHeight() * self.scale
	local isHovered = self:isHovered() and 1.0 or 0.0

	Shaders.tiltShader:send("mouse_pos", { mx, my })
	Shaders.tiltShader:send("hovering", isHovered)
	Shaders.tiltShader:send("badge_pos", { cx + bw / 2, cy + bh / 2 })
	Shaders.tiltShader:send("badge_size", { bw, bh })

	love.graphics.setShader(Shaders.tiltShader)
	love.graphics.draw(
		self.uiCanvas,
		cx + self.uiCanvas:getWidth() / 2,
		cy + self.uiCanvas:getHeight() / 2,
		0,
		self.scale,
		self.scale,
		self.uiCanvas:getWidth() / 2,
		self.uiCanvas:getHeight() / 2
	)
	love.graphics.setShader()
end

function Badge:isHovered() --Check if mouse is above the face
	--Utilise la fonction passée en paramètre, qui permet d'avoir la position de la souris dans laquelle elle est rendue.
	local vx, vy = self.mousePosition().x, self.mousePosition().y

	return (
		self.isHoverable
		and vx > self.x
		and vx < (self.x + self.width)
		and vy > self.y
		and vy < (self.y + self.height)
	)
end

function Badge:createFaceRewards(y)
	local xPos = { 290, 290 }
	local yPos = { 160, 290 }

	if self.bossBadge == true then
		xPos = { 410, 410 }
		yPos = { 220, 360 }
	end

	self.faceRewards = {}
	for i, faceReward in next, self.round.faceRewards do
		local diceFace = DiceFace:new(nil, faceReward, xPos[i], yPos[i], 120, false, true, function()
			return Inputs.getMouseInCanvas(self.x, self.y)
		end, nil, self.x, y)
		diceFace.reduceOnHover = nil --On désactive la modif de taille au hover
		diceFace.soundOnHover = false
		table.insert(self.faceRewards, diceFace)
	end
end

function Badge:updateFaceCanvas(dt)
	for i, uiFace in next, self.faceRewards do
		uiFace:update(dt)
		uiFace:draw()
	end
end

--==Utils==--
function Badge:getCurrentlyHoveredFace()
	self.previouslyHoveredFace = self.currentlyHoveredFace
	self.currentlyHoveredFace = nil

	for i, uiFace in next, self.faceRewards do
		if uiFace:isHovered() then
			self.currentlyHoveredFace = uiFace
			break
		end
	end

	--Si un dé est survolé et qu'il est différent du dé précédent alors on créé un nouveau canvas d'infos
	if self.currentlyHoveredFace ~= self.previouslyHoveredFace then
		if self.currentlyHoveredFace then
			self.hoverInfosCanvas = FaceHoverInfo:new(self.currentlyHoveredFace, "points", 0, 0)
		end
	end
end

return Badge
