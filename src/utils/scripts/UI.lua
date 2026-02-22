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

function drawWavyText(text, x, y, opts)
	opts = opts or {}
	local time = opts.time or love.timer.getTime()
	local amplitude = opts.amplitude or 10
	local speed = opts.speed or 6
	local spacing = opts.spacing or 0.3
	local font = opts.font or love.graphics.getFont()
	local centered = opts.centered or false
	local colorStart = opts.colorStart or { 1, 1, 1, 1 }
	local colorEnd = opts.colorEnd or colorStart
	local revealSpeed = opts.revealSpeed or 20
	local textSpacing = opts.textSpacing or 1

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
	o.revealSpeed = opts.revealSpeed or 1 -- temps total en secondes pour afficher tout le texte

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

function TextWavy:reset()
	self.time = 0
end

function TextWavy:setText(text)
	self.text = text
	self.charWidths, self.totalWidth = computeCharWidths(self.font, self.text)
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

	for i = 1, textLen do
		if i <= visibleChars then
			-- Calcul du progress du pop pour cette lettre
			local charRevealTime = (i - 1) / textLen * self.revealSpeed
			local timeSinceReveal = self.time - charRevealTime
			local progress = math.min(1, timeSinceReveal / self.popTime)

			local scale = computePopScale(progress, self.popStart, self.popOvershoot)
			local offsetY = math.sin(self.time * self.speed + i * self.spacing) * self.amplitude
			local color = getCharColor(self.colorStart, self.colorEnd, i, textLen)
			local charW = self.charWidths[i]
			local charH = self.font:getHeight()
			local progressAngle = math.min(1, timeSinceReveal / self.popAngleTime)

			local angle = computePopAngle(progressAngle, self.popAngleStart, self.popAngleOvershoot)
			love.graphics.setColor(color)
			love.graphics.push()

			love.graphics.translate(x + px + charW / 2, y + py + offsetY + charH / 2)
			love.graphics.scale(scale, scale)
			love.graphics.rotate(-angle) -- négatif = sens anti-horaire en Love2D

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

function drawFormattedText(text, x, y, font, maxWidth, centered)
	font = font or love.graphics.getFont()

	-- Définir la font pour les calculs de largeur et l'affichage
	love.graphics.setFont(font)

	-- Table des couleurs selon le type de formatage
	local colorMap = {
		normal = { 0, 0, 0 }, -- Noir
		red = { 1, 0, 0 }, -- Rouge pour [[]]
		blue = { 0, 0, 1 }, -- Bleu pour (())
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
				table.insert(segments, { text = normalText, color = "normal" })
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
				table.insert(segments, { text = formattedText, color = markerType })
				currentPos = endMarker + skipLength
			else
				-- Si pas de fermeture, traiter comme texte normal
				local remainingText = string.sub(text, nextMarker)
				table.insert(segments, { text = remainingText, color = "normal" })
				break
			end
		else
			-- Pas de marqueurs trouvés, ajouter le reste comme texte normal
			local remainingText = string.sub(text, currentPos)
			table.insert(segments, { text = remainingText, color = "normal" })
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
				table.insert(lines, { segments = currentLine, width = currentLineWidth })
				currentLine = {}
				currentLineWidth = 0
				wordWithSpace = word -- Pas d'espace au début d'une nouvelle ligne
				wordWidth = font:getWidth(wordWithSpace)
			end

			-- Ajouter le mot à la ligne actuelle
			table.insert(currentLine, { text = wordWithSpace, color = segment.color })
			currentLineWidth = currentLineWidth + wordWidth
		end
	end

	-- Ajouter la dernière ligne
	if #currentLine > 0 then
		table.insert(lines, { segments = currentLine, width = currentLineWidth })
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
UI.Text.drawWavyText = drawWavyText
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
