local Animator = require("src.utils.Animator")
local Shaders = require("src.utils.Shaders")
local Inputs = require("src.utils.scripts.Inputs")
local Constants = require("src.utils.Constants")

G = {
    --Background color
    backgroundR = 40/255,
    backgroundG = 40/255,
    backgroundB = 43/255,

    --Background animation properties
    circleRad = 0.06,
    circleSpeed = 0.1,
    circleSpacing = 0.2,
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
    waveY = 0

}

--Animators
G.animator = Animator:new(G)
G.bgAnimator = Animator:new(G)
G.circleAnimator = Animator:new(G)

function G.backgroundChange(color, time)
    G.bgAnimator:addGroup({
                    {property = "backgroundR", from=G.backgroundR, targetValue = color[1], duration = 0.6},
                    {property = "backgroundG", from=G.backgroundG, targetValue = color[2], duration = 0.6},
                    {property = "backgroundB", from=G.backgroundB, targetValue = color[3], duration = 0.6},
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

function love.update(dt)
    print(applyCRT)
    if love.timer.getTime() % 5 < dt then -- toutes les 5 secondes
        print("Memory: " .. math.floor(collectgarbage("count")) .. " KB")
    end

    local vx,vy = Inputs.getVirtualMousePosition()
    --relative x/y mouse position (0-1)
    G.rx, G.ry = (vx/Constants.VIRTUAL_GAME_WIDTH)-0.5, (vy/Constants.VIRTUAL_GAME_HEIGHT)-0.5
    
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
	drawBackground()

	Shaders.aChrom:send("amount", 1)
	if applyCRT then
		love.graphics.setShader(Shaders.aChrom)
	end
	game:draw()
	love.graphics.setShader()
	-- Update the cached FPS text object
	fpstext:set("fps:" .. delta)
	love.graphics.draw(fpstext, love.graphics.getWidth() - 5, 5, 0, 1, 1, fpstext:getWidth(), 0)

	--dimtext = love.graphics.newText(Fonts.soraSmall, tostring(love.graphics.getWidth()).."x"..tostring(love.graphics.getHeight()))
	--love.graphics.draw(dimtext, love.graphics.getWidth()-5, 30, 0, 1, 1, dimtext:getWidth(), 0)
end

function love.keypressed(key)
	if key == "c" then
		applyCRT = not applyCRT
	end

	game:keypressed(key)

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
    love.graphics.setColor(1, 1, 1)
    
    -- Set main canvas and draw background with shader
    love.graphics.setCanvas()
    love.graphics.setShader(Shaders.diagonalCircles)
    Shaders.diagonalCircles:send("time", love.timer.getTime())
    Shaders.diagonalCircles:send("circle_size",G.circleRad)
    Shaders.diagonalCircles:send("spacing", G.circleSpacing)
    Shaders.diagonalCircles:send("speed", G.circleSpeed)
    Shaders.diagonalCircles:send("darkness",G.circleDarkness)
    love.graphics.draw(backgroundCanvas, 0, 0)
    love.graphics.setShader()
end

