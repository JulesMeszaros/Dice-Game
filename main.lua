local Animator = require("src.utils.Animator")
local AudioUtils = require("src.utils.AudioUtils")
local Shaders = require("src.utils.Shaders")
local Inputs = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")
local AnimationUtils = require("src.utils.scripts.Animations")
local FaceTypes = require("src.classes.FaceTypes")
local StickerTypes = require("src.classes.StickerTypes")
local GenerateRandom = require("src.utils.scripts.GenerateRandom")

local seed = os.time()

G = {
	--Background color
	backgroundR = 40 / 255,
	backgroundG = 40 / 255,
	backgroundB = 43 / 255,

	--Background animation properties
	circleRad = 0.06,
	circleSpeed = 0.05,
	circleSpacing = 0.15,
	circleDarkness = -0.3,

	--screen shake
	--Screen target position
	rx = 0,
	ry = 0,
	--Screen position (relative)
	ox = 0,
	oy = 0,
	--Wave
	waveX = 0,
	waveY = 0,
	--Randoms
	--Pour le tiré de dés
	rngDices = love.math.newRandomGenerator(os.time()),
	--Pour la génération de shops
	rngShop = love.math.newRandomGenerator(os.time()),
	--Pour la création des dénemies
	rngEnemies = love.math.newRandomGenerator(os.time()),
	--RNG pour les trucs généraux, par exemple les animations etc
	rngGeneral = love.math.newRandomGenerator(os.time()),

	--Audio
	audio = AudioUtils:new(),
}

--Animators
G.animator = Animator:new(G)
G.bgAnimator = Animator:new(G)
G.circleAnimator = Animator:new(G)

G.faceNames = {}
G.commonDices = {}
G.uncommonDices = {}
G.rareDices = {}
G.faceTypes = FaceTypes

G.stickerNames = {}
G.basicStickers = {}
G.holoStickers = {}

--create list with faces objects placeholdersmain.lua
for key, facetype in next, FaceTypes do
	local f = facetype:new(1, 10)
	if f.tier == "Common" then
		table.insert(G.commonDices, key)
	elseif f.tier == "Uncommon" then
		table.insert(G.uncommonDices, key)
	elseif f.tier == "Rare" then
		table.insert(G.rareDices, key)
	end
	G.faceNames[key] = f.name
end

-- On trie les listes de noms pour qu'elles aient toujours le meme ordre
-- Cela est nécessaire car la liste FaceTypes est non ordonnée, et donc il est impossible de prévoir
-- quel sera son ordre au lancé du jeu.
G.faceNames = GenerateRandom.sorted(G.faceNames)
G.commonDices = GenerateRandom.sorted(G.commonDices)
G.uncommonDices = GenerateRandom.sorted(G.uncommonDices)
G.rareDices = GenerateRandom.sorted(G.rareDices)

--create list with stickers object placeholders
for key, facetype in next, StickerTypes do
	local s = facetype:new()
	if s.holographic == true then
		G.holoStickers[key] = s
	else
		G.basicStickers[key] = s
	end
	G.stickerNames[key] = s.name
end

G.stickerNames = GenerateRandom.sorted(G.stickerNames)
G.basicStickers = GenerateRandom.sorted(G.basicStickers)
G.holoStickers = GenerateRandom.sorted(G.holoStickers)

applyCRT = true

function G.backgroundChange(color, time)
	G.bgAnimator:addGroup({
		{ property = "backgroundR", from = G.backgroundR, targetValue = color[1], duration = 0.6 },
		{ property = "backgroundG", from = G.backgroundG, targetValue = color[2], duration = 0.6 },
		{ property = "backgroundB", from = G.backgroundB, targetValue = color[3], duration = 0.6 },
	})
end

-- Function to calculate parallax offset
function G.calculateParalaxeOffset(layer)
	local Constants = require("src.utils.Constants")
	return G.ox * Constants.PARALAXE_MAX_OFFSET[layer], G.oy * Constants.PARALAXE_MAX_OFFSET[layer]
end

local Fonts = require("src.utils.Fonts")
local Game = require("src.classes.Game")

local delta = 0
local fpstext = nil -- Cache the FPS text object

local fpsLimit = nil -- nil = pas de limite
local fpsOptions = { nil, 60, 30, 15, 5 }
local currentFpsIndex = 1

local backgroundCanvas = nil

bgShader = love.graphics.newShader("src/utils/bg.glsl")

function love.load()
	--bien randomiser le jeu
	math.randomseed(os.clock() * 1000000)
	for i = 0, os.clock() * 1000000 do
		math.random()
	end

	love.graphics.setBackgroundColor(G.backgroundR, G.backgroundG, G.backgroundB)
	-- Use nearest neighbor filtering for crisp pixel art
	love.graphics.setDefaultFilter("linear", "linear")

	local sys = love.system.getOS()

	if sys == "OS X" or sys == "Windows" then
		cursor = love.mouse.newCursor("src/assets/sprites/ui/cursor.png", 0, 0)
		love.mouse.setCursor(cursor)
	end

	game = Game:start()
	-- Ensure the game canvas uses nearest filtering to avoid artifacts when scaling
	if game.gameCanvas then
		game.gameCanvas:setFilter("linear", "linear")
	end

	-- Create the FPS text object once
	fpstext = love.graphics.newText(Fonts.soraSmall, "fps:0")

	-- Create background canvas
	backgroundCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end

function love.textinput(t)
	game:textinput(t)
end

function love.update(dt)
	if love.timer.getTime() % 5 < dt then -- toutes les 5 secondes
		--print("Memory: " .. math.floor(collectgarbage("count")) .. " KB")
	end

	G.circleRad = 0.06 --+ AnimationUtils.osccilate(love.timer.getTime(), 4, 0.01)

	local vx, vy = Inputs.getVirtualMousePosition()
	--relative x/y mouse position (0-1)
	G.rx, G.ry = (vx / Constants.VIRTUAL_GAME_WIDTH) - 0.5, (vy / Constants.VIRTUAL_GAME_HEIGHT) - 0.5

	--Game animators
	G.circleAnimator:update(dt)
	G.animator:update(dt)
	G.bgAnimator:update(dt)

	game:update(dt)
	delta = love.timer.getFPS()

	-- Simulation de FPS faible
	if fpsLimit then
		local desiredFrameTime = 1 / fpsLimit
		local frameTime = love.timer.getDelta()
		local sleepTime = desiredFrameTime - frameTime
		if sleepTime > 0 then
			love.timer.sleep(sleepTime)
		end
	end
end

function love.draw()
	Shaders.crt:send("amount", 0.0025)
	Shaders.crt:send("warp", 0.15)
	Shaders.crt:send("scan", 0.2)
	-- set scanline opacity (0 = no scanlines, 1 = full effect)
	Shaders.crt:send("scanOpacity", 0.5)
	Shaders.crt:send("lineWidth", love.graphics.getHeight() / 180)
	if applyCRT then
		love.graphics.setShader(Shaders.crt)
	end

	-- drawBackground()
	love.graphics.setColor(G.backgroundR, G.backgroundG, G.backgroundB)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(1, 1, 1)

	game:draw()
	love.graphics.setShader()
	-- Update the cached FPS text object
	fpstext:set("fps:" .. delta)
	love.graphics.draw(fpstext, love.graphics.getWidth() - 5, 5, 0, 1, 1, fpstext:getWidth(), 0)

	--dimtext = love.graphics.newText(Fonts.soraSmall, tostring(love.graphics.getWidth()).."x"..tostring(love.graphics.getHeight()))
	--love.graphics.draw(dimtext, love.graphics.getWidth()-5, 30, 0, 1, 1, dimtext:getWidth(), 0)
end

function love.keypressed(key)
	game:keypressed(key)

	if Constants.DEBUG == true then
		if key == "f" then
			currentFpsIndex = currentFpsIndex % #fpsOptions + 1
			fpsLimit = fpsOptions[currentFpsIndex]
			if fpsLimit then
				print("FPS limité à " .. fpsLimit)
			else
				print("FPS illimité")
			end
		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	game:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	game:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy)
	game:mousemoved(x, y, dx, dy)
end

function love.resize(w, h)
	backgroundCanvas = love.graphics.newCanvas(w, h)
end

function drawBackground()
	-- Draw background to canvas with shader
	love.graphics.setCanvas(backgroundCanvas)
	love.graphics.clear(G.backgroundR, G.backgroundG, G.backgroundB)
	love.graphics.setColor(G.backgroundR, G.backgroundG, G.backgroundB)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	-- Set main canvas and draw background with shader
	love.graphics.setCanvas()
	-- love.graphics.setShader(Shaders.diagonalCircles)
	Shaders.diagonalCircles:send("time", love.timer.getTime())
	Shaders.diagonalCircles:send("base_size", 0.05)
	Shaders.diagonalCircles:send("amplitude", 0.03)
	Shaders.diagonalCircles:send("spacing", 0.15)
	Shaders.diagonalCircles:send("speed", 0.8)
	Shaders.diagonalCircles:send("waveScale", 5.0)
	Shaders.diagonalCircles:send("moveSpeed", 0.03)
	Shaders.diagonalCircles:send("darkness", 0.3)
	love.graphics.draw(backgroundCanvas, 0, 0)
	-- Restore default blend mode
	love.graphics.setBlendMode("alpha", "alphamultiply")

	love.graphics.setColor(1, 1, 1)
end
