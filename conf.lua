function love.conf(t)
	--Window configurations
	t.window.display = 1
	t.window.fullscreen = false
	t.window.width = 1290
	t.window.height = 720
	t.window.title = "Dice Deluxe!"
	t.title = "Dice Deluxe!"
	t.window.resizable = true
	t.window.vsync = 1
	t.version = "11.5"
	t.window.msaa = 0
	t.window.minheight = 300
	t.window.minwidth = 538
	t.window.usedpiscale = false
	t.window.highdpi = true
	t.window.borderless = false
	--Debug configurations
	t.console = true
	t.gammacorrect = true
end
