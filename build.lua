return {

	-- basic settings:
	name = "Dice Deluxe", -- name of the game for your executable
	developer = "AEROSOL DELUXE GAMES", -- dev name used in metadata of the file
	output = "dist", -- output location for your game, defaults to $SAVE_DIRECTORY
	version = "0.1a", -- 'version' of your game, used to name the folder in output
	love = "11.5", -- version of LÖVE to use, must match github releases
	icon = "test.png",
	ignore = {
		"dist",
		"ignoreme.txt",
		".git",
		".github",
		".vscode",
		".gitignore",
		".DS_STORE",
		"README.md",
		"Untitled",
	}, -- folders/files to ignore in your project

	-- optional settings:
	use32bit = false, -- set true to build windows 32-bit as well as 64-bit
	identifier = "com.love.dicedeluxe", -- macos team identifier, defaults to game.developer.name
	libs = { -- files to place in output directly rather than fuse
		windows = {}, -- can specify per platform or "all"
		all = { "resources/license.txt" },
	},
}
