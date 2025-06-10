local Animator = {}
Animator.__index = Animator

-- Crée une nouvelle instance d'Animator pour animer un objet (target)
function Animator.new(target)
    local self = setmetatable({}, Animator)
    self.target = target -- l’objet que l’on va animer (ex: un dé)
    self.queue = {}      -- file d’attente des animations à jouer
    self.timer = 0       -- temps écoulé pour l’animation en cours
    self.current = nil   -- animation en cours
    return self
end

-- Met à jour l’Animator à chaque frame (appelé depuis update)
function Animator:update(dt)
    if not self.current and #self.queue > 0 then
        self.current = table.remove(self.queue, 1) -- on prend la prochaine animation
        self.timer = 0
    end

    if self.current then
        local a = self.current
        self.timer = self.timer + dt
        local t = math.min(self.timer / a.duration, 1)

        -- Interpolation linéaire entre la valeur de départ et la valeur cible
        self.target[a.field] = a.from + (a.to - a.from) * t

        if t >= 1 then
            -- Fin de l’animation, on applique la valeur finale
            self.target[a.field] = a.to
            if a.callback then a.callback() end
            self.current = nil
        end
    end
end

-- Ajoute une animation dans la file d’attente
-- field : le nom du champ à modifier (ex: "x", "y", "scale")
-- to : valeur cible à atteindre
-- duration : durée de l’animation
-- callback : fonction appelée à la fin de l’animation
function Animator:add(field, to, duration, callback)
    local from = self.target[field] or 0
    table.insert(self.queue, {
        field = field,
        from = from,
        to = to,
        duration = duration or 0.2,
        callback = callback
    })
end

-- Ajoute un délai dans la file d’attente (ne fait rien, sert juste à attendre)
function Animator:addDelay(duration, callback)
    self:add("_dummy", 0, duration, callback)
end

-- Crée un effet de secousse (shake) sur un axe donné ou sur les deux
-- intensity : force de la secousse
-- duration : durée totale de l’effet
-- axis : "x", "y" ou "both"
-- onComplete : callback à la fin du shake
function Animator:shake(intensity, duration, axis, onComplete)
    intensity = intensity or 5
    duration = duration or 0.4
    axis = axis or "x"

    local steps = 8
    local interval = duration / steps

    for i = 1, steps do
        local offset = (math.random() * 2 - 1) * intensity
        local dx, dy = 0, 0
        if axis == "x" then dx = offset end
        if axis == "y" then dy = offset end
        if axis == "both" then dx, dy = offset, offset end

        self:add("x", self.target.x + dx, interval / 2)
        self:add("y", self.target.y + dy, interval / 2)
        self:add("x", self.target.x, interval / 2)
        self:add("y", self.target.y, interval / 2)
    end

    if onComplete then
        self:addDelay(duration, onComplete)
    end
end

return Animator