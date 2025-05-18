local Button = {}
Button.__index = {}

function Button:new(callback)
    local self = setmetatable({}, Button)

    return self
end

function Button:update()

end

function Button:draw()

end

function Button:isHovered()

end

function Button:clickEvent()

end

return Button