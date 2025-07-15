local Animator = require("src/utils/Animator")

local Infos = {}
Infos.__index = Infos

function Infos:new(run)
    local self = setmetatable({}, Infos)

    self.run = run

    return self
end

function Infos:update()

end

function Infos:updateCanvas()

end

function Infos:draw()

end

return Infos