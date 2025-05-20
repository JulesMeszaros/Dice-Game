local Dice = require("src.classes.Dice")
local DiceFace = require("src.classes.ui.DiceFace")
local UIElement = require("src.classes.ui.UIElement")
local Button = require("src.classes.ui.Button")

local Run = {
    dices = {}, --Dices used id the run
    drawedDices = {}, --Current Drawed Dices
    uiElements = { -- Stores the UI Elements of the Run
        drawedDicesFaces = {},
        buttons = {}
    },
    selectedDices = {}, -- Stores the currently selected dices
    selectedFaces = {} -- Stores the currently selected faces
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
    table.insert(self.uiElements.buttons, Button:new(function()self:resetSelectedDices()end, "src/assets/sprites/ui/buttons/reset.png", love.graphics.getWidth()-175, love.graphics.getHeight()-83))

    
    return self
end

function Run:update(dt)
    --Update Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
    end

    --Update dices UI
    for key,dice in next,self.uiElements.drawedDicesFaces do
        dice:update(dt)
    end
end

function Run:draw()
    self:drawUIElements()
    self:drawButtons()
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
    if(self.uiElements.drawedDicesFaces) then --check si il y a des dés à afficher
        for key,uiFace in next,self.uiElements.drawedDicesFaces do
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

function Run:keypressed(key)
    if(key=='x')then
        self:resetSelectedDices()
    end

    if(key=="space") then --Draw The Dices
        draw = self:drawDices()
        self:setDrawedDices(draw)
        self:resetSelectedDices()

        --Adds the Faces to the UI Element
        self.uiElements.drawedDicesFaces = {}

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

            table.insert(self.uiElements.drawedDicesFaces, diceFaceUI) --Ajoute la face à la liste des éléments UI de Faces de Dés

        end

    end
end

function Run:mousepressed(x, y, button, istouch, presses)
    --Active les actions relatives aux UIElements
    --DiceFaces
    if(self.uiElements.drawedDicesFaces) then --check si il y a des dés à afficher
        for key,uiFace in next,self.uiElements.drawedDicesFaces do
            --[[ faceWasClicked = uiFace:clickEvent() --check if dice was clicked and triggers its UI-related events
            if(faceWasClicked)then --si le dé en question a été clické
                self:updateSelectedDices(uiFace)
            end ]]
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
    for key,diceface in next,self.uiElements.drawedDicesFaces do
        wasReleased = diceface:releaseEvent()
        if(wasReleased)then
            self:updateSelectedDices(diceface)
        end
    end
end

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

    print("Selected dices : " ..tostring(table.getn(self.selectedFaces)))
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
    for key,uiFace in next,self.uiElements.drawedDicesFaces do --unselect the UI Faces
        uiFace:setSelected(false)
    end
end

return Run