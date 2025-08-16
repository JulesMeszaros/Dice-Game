local CiggieObject = {}
CiggieObject.__index = CiggieObject

function CiggieObject:new()
    local self = setmetatable({}, CiggieObject)
    self.objectType = "Magic Wand"
    self.name = "Magic Wand"
    self.description = "[[Description Missing]]"
    self.sprite = love.graphics.newImage("src/assets/sprites/ciggies/Channel Cigarette.png")
    self.tier = "Clope"
    self.usableIn = nil
    return self
end

function CiggieObject:getDescription()
    return self.description
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
    if(not isList(diceList))then
        return false
    end
    --Fonction pour vérifier qu'un élément est dans une liste
  for _, dice in ipairs(diceList) do
    if dice == targetDice then
      return true
    end
  end
  return false
end

function isList(t)
    if type(t) ~= "table" then return false end

    local count = 0
    for k, _ in pairs(t) do
        if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
            return false -- contient une clé non-numérique ou invalide
        end
        count = count + 1
    end

    for i = 1, count do
        if t[i] == nil then
            return false -- trou détecté
        end
    end

    return true
end

return CiggieObject