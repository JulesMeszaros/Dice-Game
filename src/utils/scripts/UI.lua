local UI = {}

--UTILS
local function lerpColor(c1, c2, t)
	return {
		c1[1] + (c2[1] - c1[1]) * t,
		c1[2] + (c2[2] - c1[2]) * t,
		c1[3] + (c2[3] - c1[3]) * t,
		(c1[4] or 1) + ((c2[4] or 1) - (c1[4] or 1)) * t,
	}
end

--TEXT
UI.Text = {}

-- Classe TextWavy
--
-- Grosse classe qui permet d'afficher un texte animé : peut
-- 	- Apparaitre de manière animée avec un temps précis
-- 	- Etre coloré en dégradé ou de maniere stock
-- 	- Apparition de chaque lettre animée avec une rotation et un grossissement
-- 	- Disparaitre de manière animée après une durée de vie
--
--
TextWavy = {}
TextWavy.__index = TextWavy

-- ─── Helpers privés ───────────────────────────────────────────────────────────

local function computeCharWidths(font, text)
	local widths = {}
	local total = 0
	for i = 1, #text do
		local w = font:getWidth(text:sub(i, i))
		widths[i] = w
		total = total + w
	end
	return widths, total
end

local function getCharColor(colorStart, colorEnd, index, textLen)
	local t = (textLen > 1) and ((index - 1) / (textLen - 1)) or 0
	return lerpColor(colorStart, colorEnd, t)
end

local function computePopScale(progress, popStart, popOvershoot)
	-- progress : 0 -> 1 (1 = lettre complètement apparue)
	if progress <= 0 then
		return popStart
	end
	if progress >= 1 then
		return 1
	end
	-- Courbe avec overshoot : monte jusqu'à 1+overshoot puis redescend à 1
	local peak = 0.6 -- moment où on atteint le pic (entre 0 et 1)
	if progress < peak then
		local t = progress / peak
		return popStart + (1 + popOvershoot - popStart) * (t * t)
	else
		local t = (progress - peak) / (1 - peak)
		return 1 + popOvershoot * (1 - t) * (1 - t)
	end
end

local function computePopAngle(progress, angleStart, angleOvershoot)
	if progress <= 0 then
		return angleStart
	end
	if progress >= 1 then
		return 0
	end
	local peak = 0.6
	if progress < peak then
		local t = progress / peak
		return angleStart + (-angleOvershoot - angleStart) * (t * t)
	else
		local t = (progress - peak) / (1 - peak)
		return -angleOvershoot * (1 - t) * (1 - t)
	end
end
-- ─── Constructeur ─────────────────────────────────────────────────────────────

function TextWavy:new(text, x, y, opts)
	local o = setmetatable({}, TextWavy)
	opts = opts or {}

	-- Position & contenu
	o.text = text
	o.x = x
	o.y = y
	o.centered = opts.centered or false
	o.layer = opts.layer or 4

	-- Rendu du texte
	o.font = opts.font or love.graphics.getFont()
	o.colorStart = opts.colorStart or { 1, 1, 1, 1 }
	o.colorEnd = opts.colorEnd or o.colorStart

	-- Animation d'ondulation
	o.amplitude = opts.amplitude or 10
	o.speed = opts.speed or 6
	o.spacing = opts.spacing or 0.3

	--Paramètres de l'effet de pop
	o.popTime = opts.popTime or 0.3
	o.popOvershoot = opts.popOvershoot or 0.2
	o.popStart = opts.popStart or 0
	--Pop Angle
	o.popAngleStart = math.rad(opts.popAngleStart or 50)
	o.popAngleOvershoot = math.rad(opts.popAngleOvershoot or 30)
	o.popAngleTime = opts.popAngleTime or o.popTime * 1.2

	-- Animation d'apparition
	o.revealSpeed = opts.revealSpeed or 0.5 -- temps total en secondes pour afficher tout le texte

	-- Durée de vie (0 = infini)
	o.lifetime = opts.lifetime or 0

	--Ombre
	-- Ombre
	o.shadowOffset = opts.shadowOffset or { -5, 5 }
	o.shadowOpacity = opts.shadowOpacity or 0.3
	o.shadow = opts.shadow or false

	-- État interne
	o.time = 0
	o.charWidths, o.totalWidth = computeCharWidths(o.font, o.text)

	return o
end

-- ─── API publique ─────────────────────────────────────────────────────────────

function TextWavy:update(dt)
	self.time = self.time + dt
end

function TextWavy:isDead()
	if self.lifetime == 0 then
		return false
	end
	local lastCharDisappearTime = self.lifetime + ((#self.text - 1) / #self.text * self.popTime) + self.popTime
	return self.time >= lastCharDisappearTime
end

function TextWavy:reset()
	self.time = 0
end

function TextWavy:setText(text)
	self.text = text
	self.charWidths, self.totalWidth = computeCharWidths(self.font, self.text)
end

function TextWavy:setColor(colorStart, colorEnd)
	self.colorStart = colorStart
	self.colorEnd = colorEnd or colorStart
end

function TextWavy:draw()
	love.graphics.setFont(self.font)

	local px, py = G.calculateParalaxeOffset(self.layer)
	local x = self.x
	local y = self.y
	local textLen = #self.text
	local charH = self.font:getHeight()

	if self.centered then
		x = x - self.totalWidth / 2
		y = y - charH / 2
	end

	local visibleChars = math.min(textLen, math.floor(self.time / self.revealSpeed * textLen))

	local disappearing = self.lifetime > 0 and self.time >= self.lifetime

	for i = 1, textLen do
		local charRevealTime = (i - 1) / textLen * self.revealSpeed
		local timeSinceReveal = self.time - charRevealTime
		local progressAppear = math.min(1, timeSinceReveal / self.popTime)

		local visible = i <= visibleChars
		local progressPop = progressAppear
		local progressAngle = math.min(1, timeSinceReveal / self.popAngleTime)

		if disappearing then
			local timeSinceDisappear = self.time - self.lifetime - charRevealTime
			if timeSinceDisappear >= 0 then
				-- On inverse le progress : 1 -> 0
				progressPop = 1 - math.min(1, timeSinceDisappear / self.popTime)
				progressAngle = 1 - math.min(1, timeSinceDisappear / self.popAngleTime)
			end
			-- La lettre est invisible quand le pop est retombé à 0
			if timeSinceDisappear >= self.popTime then
				visible = false
			end
		end

		if visible then
			local scale = computePopScale(progressPop, self.popStart, self.popOvershoot)
			local angle = computePopAngle(progressAngle, self.popAngleStart, self.popAngleOvershoot)
			local offsetY = math.sin(self.time * self.speed + i * self.spacing) * self.amplitude
			local color = getCharColor(self.colorStart, self.colorEnd, i, textLen)
			local charW = self.charWidths[i]

			love.graphics.push()
			love.graphics.translate(x + px + charW / 2, y + py + offsetY + charH / 2)
			love.graphics.scale(scale, scale)
			love.graphics.rotate(-angle)
			if self.shadow then
				love.graphics.setColor(0, 0, 0, self.shadowOpacity)
				love.graphics.print(
					self.text:sub(i, i),
					-charW / 2 + self.shadowOffset[1],
					-charH / 2 + self.shadowOffset[2]
				)
			end
			love.graphics.setColor(color)
			love.graphics.print(self.text:sub(i, i), -charW / 2, -charH / 2)
			love.graphics.pop()
		end
		x = x + self.charWidths[i]
	end

	love.graphics.setColor(1, 1, 1, 1)
end

--Fonction qui permet de dessiner du texte de manière propre sur plusieurs lignes avec des couleurs données par des délimiteurs

function drawFormattedText(text, x, y, font, maxWidth, centered)
	font = font or love.graphics.getFont()
	love.graphics.setFont(font)
	-- Configuration des couleurs et délimiteurs
	local textFormats = {
		{ open = "[[", close = "]]", color = { 1, 0, 0 } }, -- Rouge
		{ open = "((", close = "))", color = { 0, 0, 1 } }, -- Bleu
		{ open = "{{", close = "}}", color = { 0, 1, 1 } }, -- Vert (exemple)
	}

	local defaultColor = { 0, 0, 0 }
	-- ─── Parser ───────────────────────────────────────────────────────────────

	local function findNextMarker(text, pos)
		local best, bestFormat = nil, nil
		for _, fmt in ipairs(textFormats) do
			local s = string.find(text, fmt.open, pos, true)
			if s and (not best or s < best) then
				best, bestFormat = s, fmt
			end
		end
		return best, bestFormat
	end

	local segments = {}
	local currentPos = 1

	while currentPos <= #text do
		local nextMarker, fmt = findNextMarker(text, currentPos)

		if nextMarker then
			if nextMarker > currentPos then
				table.insert(segments, { text = text:sub(currentPos, nextMarker - 1), color = defaultColor })
			end
			local endMarker = string.find(text, fmt.close, nextMarker + #fmt.open, true)
			if endMarker then
				table.insert(segments, { text = text:sub(nextMarker + #fmt.open, endMarker - 1), color = fmt.color })
				currentPos = endMarker + #fmt.close
			else
				table.insert(segments, { text = text:sub(nextMarker), color = defaultColor })
				break
			end
		else
			table.insert(segments, { text = text:sub(currentPos), color = defaultColor })
			break
		end
	end

	-- ─── Affichage sans wrapping ───────────────────────────────────────────────

	if not maxWidth then
		local currentX = x
		if centered then
			local totalWidth = 0
			for _, seg in ipairs(segments) do
				totalWidth = totalWidth + font:getWidth(seg.text)
			end
			currentX = x - totalWidth / 2
		end
		for _, seg in ipairs(segments) do
			love.graphics.setColor(seg.color)
			love.graphics.print(seg.text, currentX, y)
			currentX = currentX + font:getWidth(seg.text)
		end
		love.graphics.setColor(1, 1, 1)
		return
	end

	-- ─── Affichage avec wrapping ───────────────────────────────────────────────

	local lines = {}
	local currentLine = {}
	local currentLineWidth = 0

	for _, seg in ipairs(segments) do
		for word in seg.text:gmatch("%S+") do
			local wordWithSpace = (#currentLine > 0) and (" " .. word) or word
			local wordWidth = font:getWidth(wordWithSpace)

			if currentLineWidth + wordWidth > maxWidth and #currentLine > 0 then
				table.insert(lines, { segments = currentLine, width = currentLineWidth })
				currentLine = {}
				currentLineWidth = 0
				wordWithSpace = word
				wordWidth = font:getWidth(word)
			end

			table.insert(currentLine, { text = wordWithSpace, color = seg.color })
			currentLineWidth = currentLineWidth + wordWidth
		end
	end

	if #currentLine > 0 then
		table.insert(lines, { segments = currentLine, width = currentLineWidth })
	end

	local currentY = y
	for _, line in ipairs(lines) do
		local currentX = centered and (x - line.width / 2) or x
		for _, word in ipairs(line.segments) do
			love.graphics.setColor(word.color)
			love.graphics.print(word.text, currentX, currentY)
			currentX = currentX + font:getWidth(word.text)
		end
		currentY = currentY + font:getHeight()
	end

	love.graphics.setColor(1, 1, 1)
end

function arrangeImagesWrapped(images, centerX, startY, maxWidth, spacingX, spacingY)
	spacingX = spacingX or 0
	spacingY = spacingY or 0

	local lines = {}
	local currentLine = {}
	local lineWidth = 0

	-- 1. Découpage en lignes
	for _, img in ipairs(images) do
		local imgWidth = img:getWidth()
		if #currentLine > 0 and (lineWidth + spacingX + imgWidth) > maxWidth then
			table.insert(lines, currentLine)
			currentLine = {}
			lineWidth = 0
		end
		table.insert(currentLine, img)
		lineWidth = lineWidth + ((#currentLine > 1) and spacingX or 0) + imgWidth
	end
	if #currentLine > 0 then
		table.insert(lines, currentLine)
	end

	-- 2. Calcul des positions
	local positions = {}
	local y = startY
	for _, line in ipairs(lines) do
		-- largeur totale de la ligne
		local totalWidth = 0
		for i, img in ipairs(line) do
			totalWidth = totalWidth + img:getWidth()
			if i < #line then
				totalWidth = totalWidth + spacingX
			end
		end

		-- point de départ pour centrer la ligne autour de centerX
		local startX = centerX - totalWidth / 2
		local x = startX

		-- positions de chaque image
		for _, img in ipairs(line) do
			table.insert(positions, {
				image = img,
				x = x + img:getWidth() / 2,
				y = y + img:getHeight() / 2,
			})
			x = x + img:getWidth() + spacingX
		end

		y = y + (line[1]:getHeight()) + spacingY
	end

	return positions
end

UI.arrangeImagesWrapped = arrangeImagesWrapped

UI.Text.drawFormattedText = drawFormattedText
UI.Text.TextWavy = TextWavy
UI.Text.TextPulse = TextPulse

UI.ScreenWave = function(rx, ry)
	--Fonction qui permet de faire bouger le paralaxe de l'écran de manière smooth.
	--Prend en parametre le ratio de paralaxe voulu (donc pas une valeur en pixels, mais une valeur
	--Généralement entre -1 et 1 qui permet de calculer le paralaxe pour tous les layers)

	local ratiox = rx or 0
	local ratioy = ry or 0
	G.animator:finishAll()
	G.animator:addGroup({
		{ property = "waveX", from = rx, targetValue = 0, duration = 0.3 },
		{ property = "waveY", from = ry, targetValue = 0, duration = 0.3 },
	})
end

return UI
