local utf8 = require("utf8")
local UIElement = require("src.classes.ui.UIElement")

local TextField = {}
TextField.__index = TextField
setmetatable(TextField, { __index = UIElement })

function TextField:new(x, y, width, fontSize, args)
	local self = UIElement:new()
	setmetatable(self, TextField)

	-- Position + size
	self.x = x
	self.y = y
	self.width = width
	self.fontSize = fontSize
	self.height = fontSize + 12 -- petite marge interne
	self.canvas = love.graphics.newCanvas(self.width, self.height)
	-- UIElement parameters override
	self.isHoverable = true
	self.isSelectable = true
	self.sprite = nil -- TextField ne rend pas de sprite

	-- Text management
	self.text = ""
	self.focused = false
	self.font = love.graphics.newFont("src/assets/fonts/Sora-ExtraBold.otf", fontSize)

	--Additionnals arguments
	args = args or {}
	self.noLetters = args["noLetters"] or false
	self.forceCaps = args["forceCaps"] or false
	self.maxChars = args["maxChars"] or false
	self.noSpace = args["noSpace"] or false
	self.noNums = args["noNums"] or false
	self.noSpecial = args["noSpecials"] or false
	-- Cursor
	self.cursorTimer = 0
	self.cursorBlinkRate = 0.5
	self.cursorVisible = true

	return self
end

function TextField:update(dt)
	--Actions à mener si le fiels est focus
	if self.focused then
		--Clignottement du curseur
		self.cursorTimer = self.cursorTimer + dt
		if self.cursorTimer >= self.cursorBlinkRate then
			self.cursorTimer = 0
			self.cursorVisible = not self.cursorVisible
		end
	end
end

function TextField:draw()
	love.graphics.setFont(self.font)

	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	-- Cadre
	if self.focused then
		love.graphics.setColor(1, 1, 1)
	else
		love.graphics.setColor(0.8, 0.8, 0.8)
	end

	love.graphics.rectangle("line", 0, 0, self.canvas:getWidth(), self.canvas:getHeight())

	-- Texte
	love.graphics.setColor(1, 1, 1)
	local textX = 0
	local textY = self.canvas:getHeight() / 2
	love.graphics.print(self.text, textX, (self.canvas:getHeight() - self.fontSize) / 2)

	-- Curseur
	if self.focused and self.cursorVisible then
		local tw = self.font:getWidth(self.text)
		love.graphics.rectangle("fill", textX + tw + 2, (self.canvas:getHeight() - self.fontSize) / 2, 2, self.fontSize)
	end

	love.graphics.setCanvas(currentCanvas)
	love.graphics.draw(self.canvas, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
end

function TextField:mousepressed()
	local hovered = self:isHovered()

	if hovered then
		self.focused = true
	else
		self.focused = false
	end
end

function TextField:textinput(t)
	if self.focused then
		self.text = self.text .. t
	end
end

function TextField:keypressed(key)
	if not self.focused then
		return
	end

	if key == "backspace" then
		local byteoffset = utf8.offset(self.text, -1)
		if byteoffset then
			self.text = string.sub(self.text, 1, byteoffset - 1)
		end
	end

	-- Tu peux ajouter ici Enter, Tab, etc.
end

return TextField
