local UI = {}

--UTILS
local function lerpColor(c1, c2, t)
    return {
        c1[1] + (c2[1] - c1[1]) * t,
        c1[2] + (c2[2] - c1[2]) * t,
        c1[3] + (c2[3] - c1[3]) * t,
        (c1[4] or 1) + ((c2[4] or 1) - (c1[4] or 1)) * t
    }
end

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
    local colorStart = opts.colorStart or {1, 1, 1, 1}
    local colorEnd = opts.colorEnd or colorStart
    local revealSpeed = opts.revealSpeed or 20

    love.graphics.setFont(font)

    local visibleChars = math.min(#text, math.floor(time * revealSpeed))

    -- Pré-calcul des largeurs
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

    for i = 1, #text do
        local char = text:sub(i, i)
        if i <= visibleChars then
            local offsetY = math.sin(time * speed + i * spacing) * amplitude

            -- Interpolation de couleur
            local t = (#text > 1) and ((i - 1) / (#text - 1)) or 0
            local color = lerpColor(colorStart, colorEnd, t)
            love.graphics.setColor(color)

            love.graphics.print(char, x, y + offsetY)
        end
        x = x + charWidths[i]
    end

    love.graphics.setColor(1, 1, 1, 1) -- reset color
end

-- Classe TextWavy
TextWavy = {}
TextWavy.__index = TextWavy

function TextWavy:new(text, x, y, opts)
    local self = setmetatable({}, TextWavy)
    opts = opts or {}

    self.text = text
    self.x = x
    self.y = y
    self.amplitude = opts.amplitude or 10
    self.speed = opts.speed or 6
    self.spacing = opts.spacing or 0.3
    self.font = opts.font or love.graphics.getFont()
    self.centered = opts.centered or false
    self.colorStart = opts.colorStart or {1, 1, 1, 1}
    self.colorEnd = opts.colorEnd or self.colorStart
    self.revealSpeed = opts.revealSpeed or 20
    self.time = 0

    -- Pré-calcul des largeurs de caractères
    self.charWidths = {}
    self.totalWidth = 0
    for i = 1, #text do
        local w = self.font:getWidth(text:sub(i, i))
        table.insert(self.charWidths, w)
        self.totalWidth = self.totalWidth + w
    end

    return self
end

function TextWavy:update(dt)
    self.time = self.time + dt
end

function TextWavy:reset()
    self.time = 0
end

function TextWavy:draw()
    love.graphics.setFont(self.font)
    --TODO: peut etre ne mettre à jour cette portion du code que quand le text change d'une frame à l'autre?
    self.charWidths = {}
    self.totalWidth = 0
    for i = 1, #self.text do
        local w = self.font:getWidth(self.text:sub(i, i))
        table.insert(self.charWidths, w)
        self.totalWidth = self.totalWidth + w
    end

    local totalHeight = self.font:getHeight()

    local x = self.x
    local y = self.y
    if self.centered then
        x = x - self.totalWidth / 2
        y = y - totalHeight/2
    end

    local visibleChars = math.min(#self.text, math.floor(self.time * self.revealSpeed))

    for i = 1, #self.text do
        local char = self.text:sub(i, i)
        if i <= visibleChars then
            local offsetY = math.sin(self.time * self.speed + i * self.spacing) * self.amplitude

            local t = (#self.text > 1) and ((i - 1) / (#self.text - 1)) or 0
            local color = lerpColor(self.colorStart, self.colorEnd, t)
            love.graphics.setColor(color)

            love.graphics.print(char, x, y + offsetY)
        end
        x = x + self.charWidths[i]
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function drawFormattedText(text, x, y, font, maxWidth, centered)
    font = font or love.graphics.getFont()
    
    -- Définir la font pour les calculs de largeur et l'affichage
    love.graphics.setFont(font)
    
    -- Table des couleurs selon le type de formatage
    local colorMap = {
        normal = {0, 0, 0},     -- Noir
        red = {1, 0, 0},        -- Rouge pour [[]]
        blue = {0, 0, 1}        -- Bleu pour (())
    }
    
    local segments = {}
    local currentPos = 1
    
    -- Parser le texte pour extraire les segments
    while currentPos <= #text do
        local redStart = string.find(text, "%[%[", currentPos)
        local blueStart = string.find(text, "%(%(", currentPos)
        
        -- Trouver le prochain marqueur (le plus proche)
        local nextMarker = nil
        local markerType = nil
        
        if redStart and blueStart then
            if redStart < blueStart then
                nextMarker = redStart
                markerType = "red"
            else
                nextMarker = blueStart
                markerType = "blue"
            end
        elseif redStart then
            nextMarker = redStart
            markerType = "red"
        elseif blueStart then
            nextMarker = blueStart
            markerType = "blue"
        end
        
        if nextMarker then
            -- Ajouter le texte avant le marqueur (texte normal)
            if nextMarker > currentPos then
                local normalText = string.sub(text, currentPos, nextMarker - 1)
                table.insert(segments, {text = normalText, color = "normal"})
            end
            
            -- Chercher la fin selon le type de marqueur
            local endPattern, skipLength
            if markerType == "red" then
                endPattern = "%]%]"
                skipLength = 2
            else -- blue
                endPattern = "%)%)"
                skipLength = 2
            end
            
            local endMarker = string.find(text, endPattern, nextMarker + 2)
            if endMarker then
                -- Extraire le texte formaté
                local formattedText = string.sub(text, nextMarker + 2, endMarker - 1)
                table.insert(segments, {text = formattedText, color = markerType})
                currentPos = endMarker + skipLength
            else
                -- Si pas de fermeture, traiter comme texte normal
                local remainingText = string.sub(text, nextMarker)
                table.insert(segments, {text = remainingText, color = "normal"})
                break
            end
        else
            -- Pas de marqueurs trouvés, ajouter le reste comme texte normal
            local remainingText = string.sub(text, currentPos)
            table.insert(segments, {text = remainingText, color = "normal"})
            break
        end
    end
    
    -- Si pas de maxWidth spécifiée, affichage simple sur une ligne
    if not maxWidth then
        local currentX = x
        
        -- Si centré, calculer la largeur totale d'abord
        if centered then
            local totalWidth = 0
            for _, segment in ipairs(segments) do
                totalWidth = totalWidth + font:getWidth(segment.text)
            end
            currentX = x - totalWidth / 2
        end
        
        for _, segment in ipairs(segments) do
            local color = colorMap[segment.color]
            love.graphics.setColor(color[1], color[2], color[3])
            
            love.graphics.print(segment.text, currentX, y)
            currentX = currentX + font:getWidth(segment.text)
        end
        
        -- Remettre la couleur par défaut
        love.graphics.setColor(1, 1, 1)
        return
    end
    
    -- Affichage avec wrapping
    local lines = {}
    local currentLine = {}
    local currentLineWidth = 0
    local startX = centered and (x - maxWidth / 2) or x
    
    -- Construire les lignes
    for _, segment in ipairs(segments) do
        local words = {}
        -- Séparer en mots
        for word in segment.text:gmatch("%S+") do
            table.insert(words, word)
        end
        
        -- Gérer les espaces entre les mots
        for i, word in ipairs(words) do
            -- Ajouter un espace avant le mot (sauf pour le premier mot du segment ou de la ligne)
            local wordWithSpace = word
            local needsSpace = i > 1 or (#currentLine > 0)
            if needsSpace then
                wordWithSpace = " " .. word
            end
            
            local wordWidth = font:getWidth(wordWithSpace)
            
            -- Vérifier si le mot dépasse la largeur max
            if currentLineWidth + wordWidth > maxWidth and #currentLine > 0 then
                -- Terminer la ligne actuelle et commencer une nouvelle
                table.insert(lines, {segments = currentLine, width = currentLineWidth})
                currentLine = {}
                currentLineWidth = 0
                wordWithSpace = word -- Pas d'espace au début d'une nouvelle ligne
                wordWidth = font:getWidth(wordWithSpace)
            end
            
            -- Ajouter le mot à la ligne actuelle
            table.insert(currentLine, {text = wordWithSpace, color = segment.color})
            currentLineWidth = currentLineWidth + wordWidth
        end
    end
    
    -- Ajouter la dernière ligne
    if #currentLine > 0 then
        table.insert(lines, {segments = currentLine, width = currentLineWidth})
    end
    
    -- Afficher toutes les lignes
    local currentY = y
    local lineHeight = font:getHeight()
    
    for _, line in ipairs(lines) do
        local lineStartX = startX
        
        -- Si centré, ajuster la position x pour cette ligne
        if centered then
            lineStartX = x - line.width / 2
        end
        
        local currentX = lineStartX
        for _, wordSegment in ipairs(line.segments) do
            -- Définir la couleur
            local color = colorMap[wordSegment.color]
            love.graphics.setColor(color[1], color[2], color[3])
            
            -- Afficher le mot
            love.graphics.print(wordSegment.text, currentX, currentY)
            currentX = currentX + font:getWidth(wordSegment.text)
        end
        
        currentY = currentY + lineHeight
    end
    
    -- Remettre la couleur par défaut
    love.graphics.setColor(1, 1, 1)
end

UI.Text.drawFormattedText = drawFormattedText
UI.Text.drawWavyText = drawWavyText
UI.Text.TextWavy = TextWavy

return UI