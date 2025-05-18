local UIEllement = {}
UIEllement.__index = {}

function UIEllement:new(callback)
    local self = setmetatable({}, UIEllement)

    return self
end

function UIEllement:update()

end

function UIEllement:draw()

end

function UIEllement:isHovered()

end

function UIEllement:clickEvent()

end

return UIEllement