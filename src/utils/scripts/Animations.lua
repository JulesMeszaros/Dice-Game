local AnimationUtils = {}

function AnimationUtils.osccilate(time, periode, amp) --Periode en secondes
    return (amp/2) + (amp/2) * math.sin(2 * math.pi * time / periode)
end

function AnimationUtils.springUpdate(current, target, velocity, dt, frequency, damping)
    dt = math.min(dt, 1 / 30)
    
    local f = frequency * 2 * math.pi
    local g = damping
    local delta = target - current
    local accel = f * f * delta - 2 * g * f * velocity
    velocity = velocity + accel * dt
    current = current + velocity * dt
    return current, velocity
end

function AnimationUtils.shake(target, xintensity, yintensity, duration)
    local shakeDuration = 0.01 --seconds
    local nIterations = duration/shakeDuration

    for i=1, nIterations do

        local xShake = math.random(-1*xintensity, xintensity)
        local yShake = math.random(-1*yintensity, yintensity)

        target.animator:addGroup({
            {property = "x", from=0, targetValue=xShake, duration=shakeDuration},
            {property = "y", from=0, targetValue=yShake, duration=shakeDuration},
        })
    end
    target.animator:addGroup({
            {property = "x", from=target.x, targetValue=0, duration=shakeDuration},
            {property = "y", from=target.y, targetValue=0, duration=shakeDuration},
        })

end

function AnimationUtils.dampLerp(current, target, speed, dt)
    return current + (target - current) * (1 - math.exp(-speed * dt))
end

--Easings
local Easing = {}

function Easing.linear(t)
    return t
end

function Easing.inQuad(t)
    return t * t
end

function Easing.outQuad(t)
    return t * (2 - t)
end

function Easing.inOutQuad(t)
    if t < 0.5 then
        return 2 * t * t
    else
        return -1 + (4 - 2 * t) * t
    end
end

function Easing.inCubic(t)
    return t * t * t
end

function Easing.outCubic(t)
    t = t - 1
    return t * t * t + 1
end

function Easing.inOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        t = t - 1
        return 1 + 4 * t * t * t
    end
end

function Easing.easeOutBack(t)
    local c1 = 2.3
    local c3 = c1 + 1

    return 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2
end

function Easing.outBounce(t)
    local n1 = 7.5625
    local d1 = 2.75

    if t < 1 / d1 then
        return n1 * t * t
    elseif t < 2 / d1 then
        t = t - 1.5 / d1
        return n1 * t * t + 0.75
    elseif t < 2.5 / d1 then
        t = t - 2.25 / d1
        return n1 * t * t + 0.9375
    else
        t = t - 2.625 / d1
        return n1 * t * t + 0.984375
    end
end

AnimationUtils.Easing = Easing

AnimationUtils.EntryDuration = 0.2

-- bruit 1D déterministe (value noise simple)
local function valueNoise(x)
    -- constants magiques pour dispersion
    return (math.sin(x * 12.9898 + 78.233) * 43758.5453) % 1
end

-- Retourne une fonction easing qui va de 0 à 1 avec jitter contrôlé.
-- params :
--   strength : amplitude maximale du jitter (ex : 0.2 pour ±20%)
--   frequency : fréquence du jitter dans l’espace de t (plus grand = variations plus rapides)
--   decayFn : fonction de décroissance du jitter en fonction de t (par défaut linéaire : 1 - t)
-- Exemples de decayFn : 
--    function(t) return 1 - t end
--    function(t) return (1 - t)^2 end -- décroissance plus douce au début
function AnimationUtils.makeRandomEasing(strength, frequency, decayFn)
    strength = strength or 0.2
    frequency = frequency or 5
    decayFn = decayFn or function(t) return 1 - t end

    return function(t)
        -- t dans [0,1]
        local base = t -- interpolation linéaire de base; tu peux remplacer par un easing classique si tu veux
        local jitterFactor = decayFn(t)
        -- Génère un bruit selon t pour être déterministe
        local noise = valueNoise(t * frequency)
        local jitter = (noise * 2 - 1) * strength * jitterFactor -- entre -strength*decay et +...

        return base + jitter
    end
end

return AnimationUtils 