local Player = {}
Player.__index = Player

function Player:new()
    local self = setmetatable({}, Player)

    self.deck = {}

    return self
end

function Player:update()

end

return Player