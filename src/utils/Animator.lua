local Animator = {}

function Animator:new(target)
    local anim = {
        target = target,
        queue = {},    -- Queue de groupes d’animations
        active = {}    -- Animations actuellement en cours (parallèles)
    }
    setmetatable(anim, { __index = self })
    return anim
end

-- Ajoute une animation solo dans un groupe unique
function Animator:add(property, from, targetValue, duration, easing, onComplete)
    table.insert(self.queue, {
        {
            property = property,
            from = from,
            to = targetValue,
            duration = duration,
            time = 0,
            easing = easing or function(t) return t end,
            onComplete = onComplete
        }
    })
end

-- Ajoute un groupe d’animations parallèles
function Animator:addGroup(animations)
    local group = {}
    for _, a in ipairs(animations) do
        table.insert(group, {
            property = a.property,
            from = a.from,
            to = a.targetValue,
            duration = a.duration,
            time = 0,
            easing = a.easing or function(t) return t end,
            onComplete = a.onComplete
        })
    end
    table.insert(self.queue, group)
end

-- Ajoute un délai (utilise une animation "fictive")
function Animator:addDelay(duration, callback)
    self:add("_dummy", 0, 0, duration, nil, callback)
end

function Animator:update(dt)
    -- Si aucune animation active et une en attente : démarrer le groupe suivant
    if #self.active == 0 and #self.queue > 0 then
        self.active = table.remove(self.queue, 1)
    end

    -- Met à jour chaque animation active (en parallèle)
    for i = #self.active, 1, -1 do
        local a = self.active[i]
        a.time = a.time + dt
        local t = math.min(a.time / a.duration, 1)
        local eased = a.easing(t)
        self.target[a.property] = a.from + (a.to - a.from) * eased

        if t >= 1 then
            self.target[a.property] = a.to
            if a.onComplete then a.onComplete() end
            table.remove(self.active, i)
        end
    end
end

function Animator:isBusy()
    return #self.active > 0 or #self.queue > 0
end

function Animator:finishAll()
    -- Complete all active animations
    for _, a in ipairs(self.active) do
        self.target[a.property] = a.to
        if a.onComplete then a.onComplete() end
    end
    
    -- Complete all queued animations
    for _, group in ipairs(self.queue) do
        for _, a in ipairs(group) do
            self.target[a.property] = a.to
            if a.onComplete then a.onComplete() end
        end
    end
    
    -- Clear all animations
    self.active = {}
    self.queue = {}
end

return Animator