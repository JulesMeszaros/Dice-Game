local AudioFiles = {
	DICE_HOVER = {
		love.sound.newDecoder("src/assets/sounds/placeholders/00100 - WAV_100_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00101 - WAV_101_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00102 - WAV_102_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00103 - WAV_103_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00104 - WAV_104_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00105 - WAV_105_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00106 - WAV_106_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00107 - WAV_107_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00108 - WAV_108_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00109 - WAV_109_GUESS_BNK_SE_GAM036.wav"),
	},

	DICE_SELECTION = {
		love.sound.newDecoder("src/assets/sounds/placeholders/00010 - WAV_10_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00011 - WAV_11_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00012 - WAV_12_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00013 - WAV_13_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00014 - WAV_14_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00015 - WAV_15_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00016 - WAV_16_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00017 - WAV_17_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00018 - WAV_18_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00019 - WAV_19_GUESS_BNK_SE_GAM036.wav"),
	},

	DICE_DESELECTION = {
		love.sound.newDecoder("src/assets/sounds/placeholders/00000 - WAV_0_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00001 - WAV_1_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00002 - WAV_2_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00003 - WAV_3_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00004 - WAV_4_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00005 - WAV_5_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00006 - WAV_6_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00007 - WAV_7_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00008 - WAV_8_GUESS_BNK_SE_GAM036.wav"),
		love.sound.newDecoder("src/assets/sounds/placeholders/00009 - WAV_9_GUESS_BNK_SE_GAM036.wav"),
	},

	MOUSE_CLICK_1 = love.sound.newDecoder("src/assets/sounds/click_on.ogg"),
	MOUSE_CLICK_2 = love.sound.newDecoder("src/assets/sounds/click_off.ogg"),
}

return AudioFiles
