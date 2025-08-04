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

UI.Text.drawWavyText = drawWavyText
UI.Text.TextWavy = TextWavy




return UI