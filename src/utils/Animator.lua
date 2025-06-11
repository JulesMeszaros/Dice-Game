local Animator = {}

function Animator:new(target)
    local anim = {
        target = target,
        queue = {},      -- file d’attente des animations
        current = nil    -- animation en cours
    }
    setmetatable(anim, { __index = self })
    return anim
end

function Animator:add(property,from, targetValue, duration, easing, onComplete)
    table.insert(self.queue, {
        property = property,
        from = from,
        to = targetValue,
        duration = duration,
        time = 0,
        easing = easing or function(t) return t end,
        onComplete = onComplete -- callback optionnel
    })
end

-- Ajoute un délai dans la file d’attente (ne fait rien, sert juste à attendre)
function Animator:addDelay(duration, callback)
    self:add("_dummy", 0, 0, duration, nil, callback)
end

function Animator:update(dt)
    -- Si aucune animation en cours et la queue n’est pas vide, en démarrer une
    if not self.current and #self.queue > 0 then
        self.current = table.remove(self.queue, 1)
    end

    -- Si une animation est en cours, la mettre à jour
    if self.current then
        local a = self.current
        a.time = a.time + dt
        local t = math.min(a.time / a.duration, 1)
        local eased = a.easing(t)
        self.target[a.property] = a.from + (a.to - a.from) * eased

        if t >= 1 then
            self.target[a.property] = a.to
            if a.onComplete then
                a.onComplete() -- exécute le callback
            end
            self.current = nil
        end
    end
end

function Animator:isBusy()
    return self.current ~= nil or #self.queue > 0
end

return Animator