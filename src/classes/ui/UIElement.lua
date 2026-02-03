local InputsUtils = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local Animator = require("src.utils.Animator")

local UIElement = {}
UIElement.__index = {}

function UIElement:new(gameCanvas)
	local self = setmetatable({}, UIElement)

	self.animator = Animator:new(self)

	--Parametres d'interractions

	self.sprite = nil
	self.isSelectable = false
	self.isHoverable = false
	self.isDraggable = false
	self.isSelected = false

	--Position
	self.x = 0
	self.y = 0

	--Graphic/Render parameters
	self.width = 1
	self.height = 1

	self.hasShadow = true
	--Echelle du boutton (utile quand par exemple la souris est au dessus)
	self.scale = 1
	self.targetedScale = 1

	--State functions
	self.isBeingClicked = false
	self.isBeingDragged = false
	self.isActivated = true

	return self
end

function UIElement:update(dt) end

function UIElement:isHovered(layer)
	layer = layer or 4
	local vx, vy = InputsUtils.getVirtualMousePosition(layer)
	return (
		self.isHoverable
		and vx > (self.x - (self.width / 2))
		and vx < (self.x + (self.width / 2))
		and vy > (self.y - (self.height / 2))
		and vy < (self.y + (self.height / 2))
	)
end

function UIElement:clickEvent() --S'active lorsqu'un click est commencé
	local wasClicked = false -- Variable retournée : vrai si le dé a été cliqué, faux si le dé n'a pas été clické

	if self:isHovered() then
		self.isBeingClicked = true
		wasClicked = true
	end

	return wasClicked
end

function UIElement:releaseEvent() --S'active lorsqu'un click est complété
	local wasReleased = false

	if self:isHovered() == true and self.isBeingClicked == true and not self.isBeingDragged then --s'active uniquement si la souris est encore sur l'objet et qu'elle etait en train d'appuyer dessus
		self:clickAction()
		wasReleased = true
	end

	self.isBeingClicked = false
	return wasReleased
end

function UIElement:clickAction()
	print("Click Action")
end

--Get/set Functions--

function UIElement:hasShadow(state)
	self.hasShadow = state
end

function UIElement:shadowOnHover(state)
	self.shadowOnHover = state
end

function UIElement:setSprite(sprite)
	self.sprite = sprite
end

function UIElement:getIsSelected()
	return self.isSelected
end

function UIElement:setSelectable(state)
	self.isSelectable = state
end

function UIElement:setHoverable(state)
	self.isHoverable = state
end

function UIElement:getSelectable()
	return self.isSelectable
end

function UIElement:selectOrDeselect()
	self:setSelected(not self:getIsSelected())
end

function UIElement:setHoverable()
	return self.isHoverable
end

function UIElement:setSelected(state)
	self.isSelected = state
end

function UIElement:setX(x)
	self.x = x
end

function UIElement:setY(y)
	self.y = y
end

function UIElement:getX()
	return self.x
end

function UIElement:getY()
	return self.y
end

function UIElement:setWidth(w)
	self.width = w
end

function UIElement:setHeight(h)
	self.height = h
end

function UIElement:setActivated(state)
	if state == true then
		self.isActivated = true
		--self.isHoverable = true
		self.isSelectable = true
	else
		self.isActivated = false
		--self.isHoverable = false
		self.isSelectable = false
	end
end

function UIElement:dampLerp(current, target, speed, dt)
	return current + (target - current) * (1 - math.exp(-speed * dt))
end

return UIElement
