return {

	-- basic settings:
	name = "Dice Deluxe!", -- name of the game for your executable
	developer = "AEROSOL DELUXE Interactives", -- dev name used in metadata of the file
	output = "dist", -- output location for your game, defaults to $SAVE_DIRECTORY
	version = "0.1a", -- 'version' of your game, used to name the folder in output
	love = "11.5", -- version of LÖVE to use, must match github releases
	ignore = { "dist", "README.md", ".git", ".github", "build.lua", "Untitled", ".gitignore", "misc" }, -- folders/files to ignore in your project
	icon = "misc/icon.png", -- 256x256px PNG icon for game, will be converted for you

	-- optional settings:
	use32bit = false, -- set true to build windows 32-bit as well as 64-bit
	identifier = "com.adxgames.dicedeluxe",
}
