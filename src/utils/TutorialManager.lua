local AnimationUtils = require("src.utils.scripts.Animations")
local Animator = require("src.utils.Animator")
local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local Button = require("src.classes.ui.Button")
local Sprites = require("src.utils.Sprites")
local UI = require("src.utils.scripts.UI")
local Fonts = require("src.utils.Fonts")
local TutorialManager = {}
TutorialManager.__index = TutorialManager

function TutorialManager:new(run)
	local self = setmetatable({}, TutorialManager)

	self.nextButton = Button:new(
		function()
			self:confirm()
		end,
		"src/assets/sprites/ui/NextTuto.png",
		Constants.VIRTUAL_GAME_WIDTH - 30 - 111,
		Constants.VIRTUAL_GAME_HEIGHT - 30 - 75,
		223,
		150,
		nil,
		function()
			return Inputs.getMouseInCanvas(0, 0)
		end
	)
	self.animator = Animator:new(self)

	self.run = run

	self.opacity = 0
	self.x = -10000
	self.y = -10000

	-- queue de messages à afficher
	self.queue = {}

	-- message courant
	self.current = nil

	-- est-ce qu'on bloque le gameplay ?
	self.isBlocking = false

	-- pour éviter d'afficher deux fois le même message
	self.shown = {}

	--Canvas pour les éléments du tutorial.
	self.tutoPanelCanvas = love.graphics.newCanvas(790, 260)

	-----------------
	---Toasts Notifications--
	-----------------
	self.toastQueue = {}
	self.currentToast = nil

	self.tx = -10000
	self.ty = -10000

	self.toastCanvas = love.graphics.newCanvas(500, 125)

	return self
end

-- ============================================================
-- Push un message complet (table)
-- Exemple:
-- {
--   type = "popup",
--   title = "Tutorial",
--   text = "Hello",
--   blocking = true,
--   onConfirm = function(run) ... end
-- }
-- ============================================================
function TutorialManager:push(messageData)
	table.insert(self.queue, messageData)

	if not self.current then
		self:_popNext()
		--Animation de l'opacity du background
		self.animator:add("opacity", 0, 0.6, 0.4, AnimationUtils.Easing.inOutCubic)
		--Animation de l'entrée du carton de dialogue
		local duration = 0.2
		if messageData.pos == "ul" then
			self.animator:add("x", -Sprites.TUTO_PANEL:getWidth() - 50, 30, duration, AnimationUtils.Easing.outQuad)
			self.y = 30
		elseif messageData.pos == "ur" then
			self.animator:add(
				"x",
				Constants.VIRTUAL_GAME_WIDTH + 50,
				Constants.VIRTUAL_GAME_WIDTH - Sprites.TUTO_PANEL:getWidth() - 30,
				duration,
				AnimationUtils.Easing.outQuad
			)
			self.y = 30
		else
			self.animator:add("x", -Sprites.TUTO_PANEL:getWidth() - 50, 30, duration, AnimationUtils.Easing.outQuad)
			self.y = Constants.VIRTUAL_GAME_HEIGHT - Sprites.TUTO_PANEL:getHeight() - 30
		end
	end

	self:updateTutoCanvas()
end

function TutorialManager:pushToast(toastData)
	table.insert(self.toastQueue, toastData)

	if not self.currentToast then
		self:_popNextToast()

		-- animation entrée toast
		self.tx = Constants.VIRTUAL_GAME_WIDTH + 50
		self.ty = 30

		self.animator:add(
			"tx",
			Constants.VIRTUAL_GAME_WIDTH + 50,
			Constants.VIRTUAL_GAME_WIDTH - 500 - 30,
			0.25,
			AnimationUtils.Easing.outQuad
		)

		self:updateToastCanvas()
	end
end

-- ============================================================
-- Push une seule fois via un ID unique
-- ============================================================
function TutorialManager:pushOnce(id, messageData)
	if self.shown[id] then
		return
	end
	self.shown[id] = true

	self:push(messageData)
end

-- ============================================================
-- Confirmer le message actuel (clic OK par exemple)
-- ============================================================
function TutorialManager:confirm()
	if not self.current then
		return
	end

	-- callback quand on confirme
	if self.current.onConfirm then
		self.current.onConfirm(self.run, self.current)
	end

	self:_popNext()
end

function TutorialManager:confirmToast(key)
	--Permet de confirmer un toast, seulement si la clé donnée est la bonne.
	--S'il n'y a pas de clé donnée, alors on confirme seulement si le toast n'a pas de clé
	key = key or ""

	if not self.currentToast then
		return
	end

	if not self.currentToast.key or self.currentToast.key == key then
		-- callback quand on confirme
		if self.currentToast.onConfirm then
			self.currentToast.onConfirm(self.run, self.currentToast)
		end

		-- animation de sortie
		if #self.toastQueue <= 0 then
			self.animator:add(
				"tx",
				self.tx,
				Constants.VIRTUAL_GAME_WIDTH + 50,
				0.2,
				AnimationUtils.Easing.inQuad,
				function()
					self:_popNextToast()
				end
			)
		else
			self:_popNextToast()
		end
	end
end

-- ============================================================
-- Passer au message suivant sans confirmer (skip)
-- ============================================================
function TutorialManager:skip()
	self:_popNext()
end

-- ============================================================
-- Retourne true si un message est affiché
-- ============================================================
function TutorialManager:hasMessage()
	return self.current ~= nil
end

-- ============================================================
-- Retourne le message courant (pour UI)
-- ============================================================
function TutorialManager:getCurrent()
	return self.current
end

-- ============================================================
-- Update : si le message a une fonction update personnalisée
-- ============================================================
function TutorialManager:update(dt)
	if not self.current and not self.currentToast then
		return
	end

	if self.current and self.current.update then
		self.current.update(self.run, dt, self.current)
	end

	self.animator:update(dt)
	self.nextButton:update(dt)
end

-- ============================================================
-- Draw : si le message a une fonction draw personnalisée
-- ============================================================
function TutorialManager:draw()
	if not self.current then
		return
	end

	if self.current.draw then
		self.current.draw(self.run, self.current)
	end
end

--Update des éléments visuels
function TutorialManager:updateTutoCanvas()
	if not self.current then
		return
	end
	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.tutoPanelCanvas)
	love.graphics.clear()

	love.graphics.draw(Sprites.TUTO_PANEL, 0, 0)
	--Dessin du texte
	UI.Text.drawFormattedText(self.current.text, 20, 20, Fonts.sora30, Sprites.TUTO_PANEL:getWidth() - 50, false)

	love.graphics.setCanvas(currentCanvas)
end

function TutorialManager:updateToastCanvas()
	if not self.currentToast then
		return
	end

	local currentCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.toastCanvas)
	love.graphics.clear()

	love.graphics.draw(Sprites.TUTO_TOAST, 0, 0)

	-- texte
	UI.Text.drawFormattedText(self.currentToast.text or "", 20, 20, Fonts.sora30, 460, false)

	love.graphics.setCanvas(currentCanvas)
end

-- ============================================================
-- Interne : passer au prochain message
-- ============================================================
function TutorialManager:_popNext()
	-- on appelle onEnd si besoin
	if self.current and self.current.onEnd then
		self.current.onEnd(self.run, self.current)
	end

	if #self.queue > 0 then
		self.current = table.remove(self.queue, 1)

		-- valeur par défaut : blocking = true
		if self.current.blocking == nil then
			self.current.blocking = true
		end

		self.isBlocking = self.current.blocking

		-- callback au moment où le message apparaît
		if self.current.onStart then
			self.current.onStart(self.run, self.current)
		end
	else
		self.current = nil
		self.isBlocking = false
		self.opacity = 0
		self.x = -10000
		self.y = -10000
	end
end

function TutorialManager:_popNextToast()
	-- on appelle onEnd si besoin
	if self.currentToast and self.currentToast.onEnd then
		self.currentToast.onEnd(self.run, self.currentToast)
	end

	if #self.toastQueue > 0 then
		self.currentToast = table.remove(self.toastQueue, 1)

		-- callback au moment où le message apparaît
		if self.currentToast.onStart then
			self.currentToast.onStart(self.run, self.currentToast)
		end
	else
		self.currentToast = nil
		self.tx = -10000
		self.ty = -10000
	end
end

--Interactions
function TutorialManager:mousepressed(x, y, button, istouch, presses)
	self.nextButton:clickEvent()
end

function TutorialManager:mousereleased(x, y, button, istouch, presses)
	local wasReleased = self.nextButton:releaseEvent()
	if wasReleased then --Si le click a été complété
		self.nextButton:getCallback()()
	end
end

return TutorialManager
