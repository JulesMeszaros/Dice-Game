function love.conf(t)
	--Window configurations
	t.window.display = 2
	t.window.fullscreen = false
	t.window.width = 1290 / 4
	t.window.height = 720 / 4
	t.window.title = "DICE DX"
	t.window.resizable = true
	t.window.vsync = 1
	t.window.msaa = 0
	t.window.minheight = 300
	t.window.minwidth = 538
	t.window.usedpiscale = false
	t.window.highdpi = true
	--Debug configurations
	t.console = true
end
