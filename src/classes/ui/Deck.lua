local Fonts = require("src.utils.Fonts")
local AnimationUtils = require("src.utils.scripts.Animations")
local DiceFace = require("src.classes.ui.DiceFace")
local Sprites = require("src.utils.Sprites")
local Inputs = require("src.utils.scripts.Inputs")
local Sticker = require("src.classes.ui.Sticker")

local Deck = {}
Deck.__index = Deck

function Deck:new()
	local self = setmetatable({}, Deck)

	self.canvas = love.graphics.newCanvas(1130, 830)
	self.stickersCanvas = love.graphics.newCanvas(350, 430)
	self.diceFaces = {}
	self.stickers = {}

	self:createStickers()

	--Creation d'un inventaire des faces pour les tableaux
	self.numberedFaces = { 0, 0, 0, 0, 0, 0 }
	self.blankFaces = 0
	self.ghostFaces = 0

	for _, dice in next, G.game.diceObjects do
		for __, face in next, dice:getAllFaces() do
			if face.blank == true then
				self.blankFaces = self.blankFaces + 1
			else
				self.numberedFaces[face.faceValue] = self.numberedFaces[face.faceValue] + 1
			end
			if face.ghost == true then
				self.ghostFaces = self.ghostFaces + 1
			end
		end
	end

	self.numberedFacesText = {}
	self.ghostText = love.graphics.newText(Fonts.soraLightMini, tostring(self.ghostFaces))
	self.blankText = love.graphics.newText(Fonts.soraLightMini, tostring(self.blankFaces))

	for _, number in next, self.numberedFaces do
		table.insert(self.numberedFacesText, love.graphics.newText(Fonts.soraLightMini, tostring(number)))
	end

	--Create the dice faces
	for _, d in next, G.game.run.diceObjects do
		local dice = {}
		for __, df in next, d:getAllFaces() do
			local f = DiceFace:new(d, df, 30 + (_ - 1) * 150 + 410, (__ - 1) * 120 + 140, 120, false, true, function()
				return Inputs.getMouseInCanvas(510, 30)
			end, nil, 510, 30)
			local apparitionDuration = 0.4

			f.baseTargetedScale = 0
			f.scaleX = 0
			f.scaleY = 0
			f.targetedScale = 0

			f.animator:addDelay(0.03 * (_ + __ - 1))
			f.animator:addGroup({
				--Rotation
				--Scale
				{
					property = "baseTargetedScale",
					from = 0,
					targetValue = 1,
					duration = apparitionDuration,
					easing = AnimationUtils.Easing.easeOutBack,
				},
				{
					property = "scaleX",
					from = 0,
					targetValue = 1,
					duration = apparitionDuration,
					easing = AnimationUtils.Easing.easeOutBack,
				},
				{
					property = "scaleY",
					from = 0,
					targetValue = 1,
					duration = apparitionDuration,
					easing = AnimationUtils.Easing.easeOutBack,
				},
				{
					property = "targetedScale",
					from = 0,
					targetValue = 1,
					duration = apparitionDuration,
					easing = AnimationUtils.Easing.easeOutBack,
				},
			})

			table.insert(dice, f)
		end
		self.diceFaces[d] = dice
	end

	return self
end

function Deck:update(dt)
	self:updateCanvas(dt)
end

function Deck:updateCanvas(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)

	love.graphics.clear()

	love.graphics.draw(Sprites.COMPOSITION_PANEL, 0, 30)
	--Dessin des texts
	love.graphics.setColor(108 / 255, 86 / 255, 113 / 255)
	for i, txt in next, self.numberedFacesText do
		love.graphics.draw(txt, 128, 116 + (i - 1) * 34, 0, 1, 1, txt:getWidth() / 2, txt:getHeight() / 2)
	end

	love.graphics.draw(self.blankText, 255, 182, 0, 1, 1, self.blankText:getWidth() / 2, self.blankText:getHeight() / 2)
	love.graphics.draw(self.ghostText, 255, 218, 0, 1, 1, self.ghostText:getWidth() / 2, self.ghostText:getHeight() / 2)

	love.graphics.setColor(1, 1, 1)

	self:drawStickers(dt)
	love.graphics.draw(Sprites.DECK_PANEL, self.canvas:getWidth(), 0, 0, 1, 1, Sprites.DECK_PANEL:getWidth(), 0)

	--Draw the faces
	for i, dice in next, self.diceFaces do
		for _, diceface in next, dice do
			diceface:update(dt)
			diceface:draw()
		end
	end

	love.graphics.setCanvas(currentCanvas)
end

function Deck:draw()
	local px, py = G.calculateParalaxeOffset(2)
	love.graphics.draw(self.canvas, 510 + px, 30 + py)
end

function Deck:drawStickers(dt)
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.stickersCanvas)
	love.graphics.clear()

	--Dessin du fond (sprite)
	love.graphics.draw(Sprites.STICKERS_PANEL, 0, 0)

	--Dessin et update des stickers
	for _, sticker in next, self.stickers do
		sticker:update(dt)
		sticker:draw()
	end

	love.graphics.setCanvas(currentCanvas)
	love.graphics.draw(self.stickersCanvas, 0, 370)
end

function Deck:createStickers()
	self.stickers = {}
	for i, sticker in next, G.game.run.stickers do
		--x
		local x = 60 + ((i - 1) % 3) * 110
		--y
		local y = 100 + math.floor((i - 1) / 3) * 100
		--angle
		local rAngle = math.random(-100, 100) / 200
		--jitter
		local xj = math.random(-5, 5)
		local yj = math.random(-5, 5)

		local s = Sticker:new(sticker, x + xj, y + yj, 100, false, true, function()
			return Inputs.getMouseInCanvas(510, 400, 1)
		end, 510, 400)
		s.baseRotation = rAngle

		self.stickers[sticker] = s
	end
end

function Deck:getCurrentlyHoveredFace()
	--Fonction pour récupérer la face OU le sticker qui est hover
	for i, dice in next, self.diceFaces do
		for j, face in next, dice do
			if face:isHovered() then
				return face
			end
		end
	end
	for i, sticker in next, self.stickers do
		if sticker:isHovered() then
			return sticker
		end
	end
	return nil
end

return Deck
