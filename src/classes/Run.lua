local Dice = require("src.classes.Dice")
local DiceFace = require("src.classes.ui.DiceFace")
local UIElement = require("src.classes.ui.UIElement")
local Button = require("src.classes.ui.Button")

local Run = {
    dices = {}, --Dices used id the run
    drawedDices = {}, --Current Drawed Dices
    uiElements = { -- Stores the UI Elements of the Run
        diceFaces = {},
        buttons = {}
    },
    selectedDices = {}, -- Stores the currently selected dices
    selectedFaces = {}, -- Stores the currently selected faces

    --Drag variables
    isDragging = false,
    dragOriginX = nil,
    dragOriginY = nil,
    dragDX = 0,
    dragDY = 0,
    draggingTreshold = 10
}

Run.__index = Run

function Run:new()
    local self = setmetatable({}, Run)

    self.dices = { -- On définit les 5 dés présents dans la partie
        Dice:new(),
        Dice:new(),
        Dice:new(),
        Dice:new(),
        Dice:new()
    }

    --Add a button
    table.insert(self.uiElements.buttons, Button:new(function()self:resetSelectedDices()end, "src/assets/sprites/ui/buttons/reset.png", love.graphics.getWidth()-175, love.graphics.getHeight()-83, 200, 84))
    table.insert(self.uiElements.buttons, Button:new(function()self:makeRoll()end, "src/assets/sprites/ui/buttons/reroll.png", love.graphics.getWidth()-175, love.graphics.getHeight()-(83+83+20), 200, 84))

    return self
end

function Run:update(dt)
    --Update Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end

    --Update dices UI
    for key,dice in next,self.uiElements.diceFaces do
        dice:update(dt)
    end
end

function Run:draw()
    self:drawUIElements()
    self:drawButtons()

    --[[ if(love.mouse.isDown(1) and self.dragOriginX and self.dragOriginY) then --debug pour le drag (à supprimer plus tard)
        if(self.isDragging) then love.graphics.setColor(1, 0, 0) else love.graphics.setColor(1, 1, 1) end
        love.graphics.line(self.dragOriginX, self.dragOriginY, love.mouse.getX(), love.mouse.getY())
        love.graphics.setColor(1, 1, 1)
    end ]]
end

function Run:drawDices()
    --Tire les 5 dés et retourne leur numéro de face

    local faceNumbers = {}

    for key,dice in next,self.dices do
        table.insert(faceNumbers, math.random(1, dice:getNbFaces()))
    end

    return faceNumbers
end

function Run:setDrawedDices(draw)
    self.drawedDices = draw
end

function Run:drawDrawedDices()
    --Dessine les dés tirés
    if(self.uiElements.diceFaces) then --check si il y a des dés à afficher
        for key,uiFace in next,self.uiElements.diceFaces do
            uiFace:draw()
        end
    end
end

function Run:drawButtons()
    for key,button in next,self.uiElements.buttons do
        button:draw()
    end
end

function Run:drawUIElements()
    --Fonction pour afficher les différents élément d'interface graphique
    self:drawDrawedDices()--Les dés tirés
    self:drawButtons()--Les boutons
end

--Inputs functions

function Run:keypressed(key)
    if(key=='x')then
        self:resetSelectedDices()
    end

    if(key=="space") then --Draw The Dices
        self:makeRoll()

    end
end

function Run:mousepressed(x, y, button, istouch, presses)
    --Met les coordonnées de drag à 0
    self.dragOriginX = x ; self.dragOriginY = y

    --Active les actions relatives aux UIElements
    --DiceFaces
    if(self.uiElements.diceFaces) then --check si il y a des dés à afficher
        for key,uiFace in next,self.uiElements.diceFaces do
            uiFace:clickEvent()
        end
    end

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end
end

function Run:mousereleased(x, y, button, istouch, presses)
    
    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    --release event for dice faces
    for key,diceface in next,self.uiElements.diceFaces do
        wasReleased = diceface:releaseEvent()
        if(wasReleased)then
            self:updateSelectedDices(diceface)
        end
        diceface.isBeingDragged = false
    end

    --Deactivate dragging
    self.isDragging = false
end

function Run:mousemoved(x, y, dx, dy)
    --x et y sont la position, dx et dy sont la vitesse.

    if(love.mouse.isDown(1) and self.dragOriginX and self.dragOriginY) then

        if( --sets dragging state
        math.abs(love.mouse.getX() - self.dragOriginX) > self.draggingTreshold
        or math.abs(love.mouse.getY() - self.dragOriginY) > self.draggingTreshold) then
            self.isDragging = true
        end
    end

    if(self.isDragging == true)then
        for key,diceui in next, self.uiElements.diceFaces do
            if(diceui.isDraggable and diceui.isBeingClicked) then
                diceui.isBeingDragged = true
                diceui:setX(diceui:getX() + dx)
                diceui:setY(diceui:getY() + dy)
            end
        end
    end

end


--Dices Functions

function Run:updateSelectedDices(uiFace)
    --si le dé donné en paramètre est sélectionné et pas encore dans la liste, on l'ajoute à la fin de la liste.
    --si il est sélectionné mais pas dans la liste, on le laisse
    --si il est désélectionné et dans la liste, on le retire.

    if(uiFace:getIsSelected())then -- Dé sélectionné
        if(not self:containsDice(self.selectedDices, uiFace:getDice()))then
            table.insert(self.selectedDices, uiFace:getDice()) -- Ajoute le dé à la fin-
            table.insert(self.selectedFaces, uiFace:getFace()) -- Ajoute le numéro de face
        end
    else
        if(self:containsDice(self.selectedDices, uiFace:getDice())) then -- Dé non sélectionné
            for i, dice in ipairs(self.selectedDices) do
                if dice == uiFace:getDice() then
                    table.remove(self.selectedDices, i) --Trouve le dé dans la liste et le supprime
                    table.remove(self.selectedFaces, i)
                    break
                end
            end
        end
    end

    --print("Selected dices : " ..tostring(table.getn(self.selectedFaces)))
end

function Run:containsDice(diceList, targetDice)
    --Fonction pour vérifier qu'un élément est dans une liste
  for _, dice in ipairs(diceList) do
    if dice == targetDice then
      return true
    end
  end
  return false
end

function Run:resetSelectedDices()
    self.selectedDices = {} --remove the dices
    self.selectedFaces = {} --remove the face numbers
    for key,uiFace in next,self.uiElements.diceFaces do --unselect the UI Faces
        uiFace:setSelected(false)
    end
end

function Run:makeRoll()
    draw = self:drawDices()
    self:setDrawedDices(draw)
    self:resetSelectedDices()

    --Adds the Faces to the UI Element
    self.uiElements.diceFaces = {}

    for key,dice in next,self.dices do

        diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            dice, --Dice Object 
            self.drawedDices[key], --Face represented
            key*120, --X Position (centerd)
            love.graphics.getHeight()/2, --Yposition (centerd)
            80, --Width/Height
            true, --is Selectable
            true --isHoverable
        )

        table.insert(self.uiElements.diceFaces, diceFaceUI) --Ajoute la face à la liste des éléments UI de Faces de Dés

    end
end

return Run