local Constants = require("src.utils.Constants")
local Shaders = require("src.utils.Shaders")
local Animator = require("src.utils.Animator")
local UIElement = require("src.classes.ui.UIElement")

local Sticker = setmetatable({}, { __index = UIElement })

Sticker.__index = Sticker

function Sticker:new(stickerObject, x, y, size, isSelectable, isHoverable, mousePosition, absoluteX, absoluteY)
	local self = setmetatable(UIElement.new(), Sticker)

	self.animator = Animator:new(self)
	self.canvas = love.graphics.newCanvas(size, size)

	--Angle
	self.angle = 0
	self.targetedAngle = 0
	self.baseRotation = 0
	self.targetedRotation = 0
	self.dragXspeed = 0
	self.velrotation = 0
	self.dragRotation = 0
	self.rotation = 0
	--Position
	self.layer = 4
	self.x = x
	self.y = y
	self.anchorX = x
	self.anchorY = y
	self.size = size
	self.absoluteX = absoluteX or 0
	self.absoluteY = absoluteY or 0
	self.targetX = x
	self.targetY = y
	self.mousePosition = mousePosition
	self.isTerrainSticker = false
	self.velx = 0
	self.vely = 0

	--Interaction
	self.isHoverable = isHoverable
	self.isSelectable = isSelectable
	self.isDraggable = true
	self.dragXspeed = 0

	self.scaleX = 1
	self.scaleY = 1
	self.baseTargetedScale = 1
	self.targetedScale = 1
	self.velscale = 0
	self.hoverScale = 0

	self.time = 0

	self.representedObject = stickerObject
	self.sprite = love.graphics.newImage(self.representedObject.sprite)
	--Shader
	self.rainbowShader = Shaders.glitteryRainbow

	return self
end

function Sticker:update(dt)
	self.time = self.time + dt
	self.animator:update(dt)

	self:calculateScale()
	self:updateScale(dt)
	self:updatePosition(dt)
	self:calculateAngleDrag()
	self:updateCanvas(dt)

	self.targetedRotation = self.baseRotation + self.dragRotation
	self:updateAngle(dt)
end

function Sticker:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	love.graphics.draw(self.sprite, 0, 0, 0, self.size / self.sprite:getWidth(), self.size / self.sprite:getHeight())

	love.graphics.setCanvas(currentCanvas)
end

function Sticker:draw()
	local px, py = G.calculateParalaxeOffset(self.layer)

	self.rainbowShader:send("time", self.rotation + self.scaleX * 2 + 30)
	self.rainbowShader:send("frequency", 0.3)
	self.rainbowShader:send("intensity", 0.2)
	--self.rainbowShader:send("scale", 50)
	self.rainbowShader:send("gridSize", 50)
	if self.representedObject.holographic == true then
		love.graphics.setShader(self.rainbowShader)
	end

	if self.isTerrainSticker and G.game.run.currentState == Constants.RUN_STATES.ROUND then
		love.graphics.draw(
			self.canvas,
			self.x + px,
			self.y + py + 170,
			self.rotation,
			self.scaleX,
			self.scaleY,
			self.canvas:getWidth() / 2,
			self.canvas:getHeight() / 2
		)
	else
		love.graphics.draw(
			self.canvas,
			self.x + px,
			self.y + py,
			self.rotation,
			self.scaleX,
			self.scaleY,
			self.canvas:getWidth() / 2,
			self.canvas:getHeight() / 2
		)
	end

	love.graphics.setShader()
end

function Sticker:isHovered() --Check if mouse is above the face
	--Utilise la fonction passée en paramètre, qui permet d'avoir la position de la souris dans laquelle elle est rendue.
	local vx, vy = self.mousePosition().x, self.mousePosition().y

	local isFromShopTerrain = self.isTerrainSticker and G.game.run.currentState == Constants.RUN_STATES.SHOP

	return (
		self.isHoverable
		and isFromShopTerrain == false
		and vx > (self.x - (self.size / 2))
		and vx < (self.x + (self.size / 2))
		and vy > (self.y - (self.size / 2))
		and vy < (self.y + (self.size / 2))
	)
end

--Scale, position and angle calculations
function Sticker:calculateScale()
	--Calculate scale
	if self:isHovered() then
		self.hoverScale = 0.1 --Si hovered
		if love.mouse.isDown(1) then
			self.hoverScale = 0.15 --Si clicked
		end
	else
		self.hoverScale = 0
	end

	--Update targeted scale, rotation and position
	self.targetedScale = self.baseTargetedScale + self.hoverScale
end

function Sticker:updateScale(dt)
	if self.animator.current == nil and table.getn(self.animator.queue) == 0 then
		if math.abs(self.scaleX - self.targetedScale) < 0.001 then --Update scaleX
			self.scaleX = self.targetedScale
		else
			self.scaleX, self.velscale = springUpdate(self.scaleX, self.targetedScale, self.velscale, dt, 4, 0.6)
		end

		if math.abs(self.scaleY - self.targetedScale) < 0.001 then --update scaleY
			self.scaleY = self.targetedScale
		else
			self.scaleY, self.velscale = springUpdate(self.scaleY, self.targetedScale, self.velscale, dt, 4, 0.6)
		end
	end
end

function Sticker:calculateAngleDrag()
	--Function used to calculate the target angle of the dice base on the drag speed
	local maxRotation = 1

	if self.isBeingDragged then --Rotation pendant le drag
		self.dragRotation = 0.02 * self.dragXspeed
	else
		self.dragRotation = 0
	end

	if self.dragRotation < 0 - maxRotation then
		self.dragRotation = 0 - maxRotation
	end

	if self.dragRotation > maxRotation then
		self.dragRotation = maxRotation
	end
end

function Sticker:updateAngle(dt)
	if self.animator.current == nil and table.getn(self.animator.queue) == 0 then
		if math.abs(self.rotation - self.targetedRotation) < 0.001 then
			self.rotation = self.targetedRotation
		else
			self.rotation, self.velrotation =
				springUpdate(self.rotation, self.targetedRotation, self.velrotation, dt, 5, 0.4)
		end
	else
		self.baseRotation = self.rotation
	end
end
function Sticker:updatePosition(dt)
	--On check qu'il n'y ait pas d'animation en cours
	if self.animator.current == nil and table.getn(self.animator.queue) == 0 then
		if math.abs(self.x - self.targetX) < 3 then
			self.x = self.targetX
			self.y = self.targetY
		else
			self.x, self.velx = springUpdate(self.x, self.targetX, self.velx, dt, 4, 0.8)
			self.y, self.vely = springUpdate(self.y, self.targetY, self.vely, dt, 4, 0.8)
		end
	else
		self.targetX = self.x
		self.targetY = self.y
	end
end
--Inputs
function Sticker:clickEvent()
	local wasClicked = false -- Variable retournée : vrai si le dé a été cliqué, faux si le dé n'a pas été clické
	if self:isHovered() then
		self.isBeingClicked = true
		wasClicked = true
	end
	return wasClicked
end

--Animations--
function springUpdate(current, target, velocity, dt, frequency, damping)
	--On met un cap sur le dt
	dt = math.min(dt, 1 / 30)

	local f = frequency * 2 * math.pi
	local g = damping
	local delta = target - current
	local accel = f * f * delta - 2 * g * f * velocity
	velocity = velocity + accel * dt
	current = current + velocity * dt
	return current, velocity
end
return Sticker
