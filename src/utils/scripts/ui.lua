local UI = {}

--TEXT
UI.Text = {}

function drawWavyText(text, x, y, opts)
    opts = opts or {}
    local time = opts.time or love.timer.getTime()
    local amplitude = opts.amplitude or 10
    local speed = opts.speed or 6
    local spacing = opts.spacing or 0.3
    local font = opts.font or love.graphics.getFont()
    local centered = opts.centered or false
    local color = opts.color or {1, 1, 1, 1}
    local revealSpeed = opts.revealSpeed or 20 -- lettres par seconde

    love.graphics.setFont(font)

    -- Nombre de lettres à afficher selon le temps
    local visibleChars = math.min(#text, math.floor(time * revealSpeed))

    -- Calculer les largeurs de chaque lettre à l’avance
    local charWidths = {}
    local totalWidth = 0
    for i = 1, #text do
        local w = font:getWidth(text:sub(i, i))
        table.insert(charWidths, w)
        totalWidth = totalWidth + w
    end

    if centered then
        x = x - totalWidth / 2
    end

    -- Sauvegarder la couleur actuelle
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(color)

    -- Affichage des lettres visibles
    for i = 1, #text do
        local char = text:sub(i, i)
        if i <= visibleChars then
            local offsetY = math.sin(time * speed + i * spacing) * amplitude
            love.graphics.print(char, x, y + offsetY)
        end
        x = x + charWidths[i]
    end

    love.graphics.setColor(r, g, b, a)
end

UI.Text.drawWavyText = drawWavyText

return UI