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
    if(screenType == self.usableIn or self.usableIn == "any") then
        screen.run.totalUsedCiggie = screen.run.totalUsedCiggie+1
        self:effect(screen)
        self:destruct(screen)
        screen:generateCiggiesUI()
    else
        print("not usable here", screenType)
    end
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

return CiggieObject