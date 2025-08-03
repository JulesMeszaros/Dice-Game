local CiggieObject = {}
CiggieObject.__index = CiggieObject

function CiggieObject:new()
    local self = setmetatable({}, CiggieObject)
    self.name = "Cigarette"
    self.description = "Donne le cancer askiiiip"
    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Channel Cigarette.png")
    self.tier = "Clope"
    self.usableIn = nil
    return self
end

function CiggieObject:trigger(screen, screenType)
    if((self.usableIn == "any" or screenType == self.usableIn or isInList(self.usableIn, screenType)) and self:usageCondition(screen)==true) then
        screen.run.totalUsedCiggie = screen.run.totalUsedCiggie+1
        self:effect(screen)
        self:destruct(screen)
        screen:generateCiggiesUI()
    else
        print("not usable here", screenType)
    end
end

function CiggieObject:usageCondition(round)
    return true
end

function CiggieObject:effect(round)
    print("Clope fumée")
end

function CiggieObject:destruct(screen)
    for i,v in next,screen.run.ciggiesObjects do
        if(v==self)then
            table.remove(screen.run.ciggiesObjects, i)
            screen.uiElements.ciggiesUI[v] = nil
        end
    end
end

function isInList(diceList, targetDice)
    --Fonction pour vérifier qu'un élément est dans une liste
  for _, dice in ipairs(diceList) do
    if dice == targetDice then
      return true
    end
  end
  return false
end

return CiggieObject