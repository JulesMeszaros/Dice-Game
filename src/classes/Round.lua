local DiceFace = require("src.classes.ui.DiceFace")
local Inputs = require("src.utils.scripts.Inputs")

local Round = {
    diceFaces = {},
    drawedDices = {},
    selectedDices = {},
    selectedFaces = {}
}
Round.__index = Round

function Round.new(n, dices, terrain, gameCanvas)
    local self = setmetatable({}, Round)

    self.gameCanvas = gameCanvas

    --Current Round Parameters
    self.nround = n
    self.availableRerolls = 3
    self.dices = dices
    self.terrain = terrain

    --On créée une première fois les faces à afficher
    for key,dice in next,self.dices do

        diceFaceUI = DiceFace:new( --Créée l'élément UI de la face de dé
            dice, --Dice Object 
            1, --Face represented
            key*120 - 40, --X Position (centerd)
            self.terrain.dice_tray:getHeight()-60, --Yposition (centerd)
            80, --Width/Height
            true, --is Selectable
            true, --isHoverable,
            function()return Inputs.getMouseInCanvas((self.gameCanvas:getWidth()-20)-self.terrain.dice_tray:getWidth(), 20)end,
            self.terrain.dice_tray
        )

        self.diceFaces[dice] = diceFaceUI
    end

    return self
end

function Round:update()

end

function Round:draw()

end

--==REROLL FUNCTIONS==--
function Round:rerollDices(selectedDices) --Triggers the makeRoll function after clicking the reroll button
    if(self.availableRerolls > 0) then
        self:makeRoll(selectedDices)
        self.availableRerolls = self.availableRerolls-1
    end
end

function Round:drawDices(dices)
    --Tire uniquement les dés donnés en paramètre et retourne une table avec comme clé les dés et en valeur le numéro de face tiré.

    local faceNumbers = self.drawedDices --On récupère les dés précédemment tirés.

    for key,dice in next,dices do
        if self:containsDice(dices, dice) then
            n = math.random(1, dice:getNbFaces())
            faceNumbers[dice] = n
        end
    end

    return faceNumbers
end

function Round:makeRoll(dices)
    draw = self:drawDices(dices) --draw the dices
    print(draw)
    self:setDrawedDices(draw) --stores the draw
    self:resetSelectedDices() --reset the previously selected dices (ui)

    for key,dice in next,self.dices do
        self.diceFaces[dice]:setFace(self.drawedDices[dice]) --update the ui
    end
end

function Round:setDrawedDices(draw)
    self.drawedDices = draw
end

--==UTILS==--

function Round:resetSelectedDices()
    self.selectedDices = {} --remove the dices
    self.selectedFaces = {} --remove the face numbers
    for key,uiFace in next,self.diceFaces do --unselect the UI Faces
        uiFace:setSelected(false)
    end
end

function Round:containsDice(diceList, targetDice)
    --Fonction pour vérifier qu'un élément est dans une liste
  for _, dice in ipairs(diceList) do
    if dice == targetDice then
      return true
    end
  end
  return false
end

return Round