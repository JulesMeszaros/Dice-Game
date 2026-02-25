local Constants = require("src.utils.Constants")
local TutorialEvents = {}

function TutorialEvents.welcomeMessage()
	--Premier message affiché au début du tutorial.
	--Doit expliquer le concept du jeu (nombre de mains, nombre de lancés, points à atteindre), et inviter au premier lancer de dé
	G.currentRun.tutorial:pushOnce("welcome1", {
		text = "Hey there! Wanna play a little game of dice?",
		pos = "ul",
	})

	G.currentRun.tutorial:pushOnce("welcome4", {
		text = "Just throw them on the board by hitting the [[ROLL!]] button !",
		pos = "ul",
		onConfirm = function()
			G.currentRun.tutorialCanReroll = true
			G.currentRun.tutorial:pushToast({
				text = "Press the [[REROLL!]] button.",
				key = "firstThrow",
				arrows = {
					{ x = Constants.VIRTUAL_GAME_WIDTH / 2, y = Constants.VIRTUAL_GAME_HEIGHT - 200, angle = 180 },
				},
			})
		end,
		arrows = {
			{ x = Constants.VIRTUAL_GAME_WIDTH / 2, y = Constants.VIRTUAL_GAME_HEIGHT - 200, angle = 180 },
		},
		buttons = {
			G.currentGameScreen.uiElements.buttons.rerollButton,
		},
	})
end

function TutorialEvents.firstRoll()
	--Message affiché après le premier lancer. Explique comment reroll et sélectionner des dés.
	G.currentRun.tutorial:pushOnce("firstRoll1", {
		text = "Not bad! I can see a 3, 4 and 5. Select these dices and reroll the other two, we can try to play a Large Straight.",
		pos = "ul",
		onConfirm = function()
			G.currentRun.currentRound.terrain.firstThrow = true
			G.currentRun.tutorial:pushToast({
				text = "Click on the dices with ((3, 4 & 5)) and [[reroll]]",
				key = "secondThrow",
			})
		end,
	})
end

function TutorialEvents.secondRoll()
	--Message affiché après le premier lancer. Explique comment reroll et sélectionner des dés.
	G.currentRun.tutorial:pushOnce("secondRoll", {
		text = "Too bad! We didnt roll the dices we needed...",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("secondRoll2", {
		text = "But don't fret, you can reroll up to two time for each turn you play so you still have one chance left. Reroll again !",
		pos = "ul",
		onConfirm = function()
			G.currentRun.currentRound.terrain.secondThrow = true
			G.currentRun.currentRound.terrain.firstThrow = true
			G.currentRun.tutorial:pushToast({
				text = "[[Reroll]] the two remaining dices",
				key = "thirdThrow",
				arrows = {
					{ x = Constants.VIRTUAL_GAME_WIDTH / 2, y = Constants.VIRTUAL_GAME_HEIGHT - 200, angle = 180 },
				},
			})
		end,
		draw = function(opts)
			G.currentGameScreen:drawRightPanel(opts.dt, { drawRoundDetails = true })
		end,
		arrows = {
			{ x = 1600, y = 380, angle = 90 },
		},
	})
end

function TutorialEvents.selectLastDices()
	--Message affiché après le premier lancer. Explique comment reroll et sélectionner des dés.
	G.currentRun.tutorial:pushOnce("selectLastDices0", {
		text = "Great! We rolled a Large Straight. Large Straight is one of the figure you can play to earn points and win rounds.",
		pos = "ur",
	})
	G.currentRun.tutorial:pushOnce("selectLastDicesX", {
		text = "To beat your coworker, you must reach his points target.",
		pos = "ll",
		draw = function(opts)
			G.currentGameScreen:drawPlayersInfos(opts.dt, { enemy = true })
		end,
	})
	G.currentRun.tutorial:pushOnce("selectLastDicesXX", {
		text = "To do so, you have a limited number of turn. You start your run with 3 turns.",
		pos = "ul",
		draw = function(opts)
			G.currentGameScreen:drawRightPanel(opts.dt, { drawRoundDetails = true })
		end,
		arrows = {
			{ x = 1600, y = 250, angle = 90 },
		},
	})
	G.currentRun.tutorial:pushOnce("selectLastDicesXXX", {
		text = "This grid shows you the figures you can play and the points they give you. Large Straights are played with 5 numbers in a row: 2, 3, 4, 5 and 6 for instance.",
		pos = "ur",
		draw = function(opts)
			G.currentGameScreen:drawFigureGrid(opts.dt)
		end,
	})
	G.currentRun.tutorial:pushOnce("selectLastDicesZZ", {
		text = "Select your two last dices and i'll show you how to play a figure !",
		pos = "ur",

		onConfirm = function()
			G.currentRun.tutorial.isSelectingLastDices = true
			G.currentRun.currentRound.terrain.thirdThrow = true
			G.currentRun.tutorial:pushToast({
				text = "Select the two remaining dices.",
				key = "selectLastDices",
			})
		end,
		draw = function(opts)
			local px, py = G.calculateParalaxeOffset(3)
			G.currentGameScreen:drawDiceTray(
				G.currentGameScreen.diceMatx + px,
				G.currentGameScreen.diceMaty + py,
				G.currentGameScreen.diceFaces,
				opts.dt
			)
		end,
	})
end

function TutorialEvents.figureInfo()
	G.currentRun.tutorial:pushOnce("figureinfo1", {
		text = "As you can see, Large Straights give us 40 points. But that's not all !",
		pos = "ur",
		draw = function(opts)
			G.currentGameScreen:drawFigureGrid(opts.dt)
		end,
		arrows = { { x = 500, y = 900, angle = 270 } },
	})
	G.currentRun.tutorial:pushOnce("figureinfo2", {
		text = "When playing a figure, each played dice triggers an unique effect from left to right.",
		pos = "ur",
		draw = function(opts)
			G.currentGameScreen:drawDicesOnly()
		end,
	})
	G.currentRun.tutorial:pushOnce("figureinfo3", {
		text = "You can hover your dices to see their effect. For now, you only have ((White Faces)). When triggered, they each add 10 points to your hand score.",
		pos = "ur",
		draw = function(opts)
			G.currentGameScreen:drawDicesOnly()
			if G.currentGameScreen.currentlyHoveredObject then
				G.currentGameScreen.infoBubble:draw()
			end
		end,
	})
	G.currentRun.tutorial:pushOnce("figureinfo4", {
		text = "You can now click on the Large Straight on the figure table to play it, and watch your dices apply their effects !",
		pos = "ur",
		draw = function(opts)
			G.currentGameScreen:drawFigureGrid(opts.dt)
		end,
		arrows = { { x = 500, y = 900, angle = 270 } },

		onConfirm = function()
			G.currentRun.tutorialCanPlayFigure = true
			G.currentRun.tutorialCanPlayStraights = true
			G.currentRun.tutorial:pushToast({
				text = "Play a Large Straight.",
				key = "playFigure",
				arrows = { { x = 500, y = 900, angle = 270 } },
			})
		end,
	})
end

function TutorialEvents.firstRoundWin()
	G.currentRun.tutorial:pushOnce("firstWin", {
		text = "Well done, you won your first round!",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("firstWin2", {
		text = "When winning against a coworker, you get two new dice faces. See their effect by hovering them.",
		pos = "ul",
		draw = function(opts)
			G.currentGameScreen.endRoundPopUp:updateCanvas(opts.dt, { rewards = true })

			G.currentGameScreen.endRoundPopUp:draw()
			if G.currentGameScreen.currentlyHoveredObject then
				G.currentGameScreen.infoBubble:draw()
			end
		end,
	})
	G.currentRun.tutorial:pushOnce("firstWin3", {
		text = "You also win a Magic Wand! Magic Wands give special bonuses when used.",
		pos = "ul",
		draw = function(opts)
			G.currentGameScreen.endRoundPopUp:updateCanvas(opts.dt, { rewards = true })
			G.currentGameScreen.endRoundPopUp:draw()
		end,
	})
	G.currentRun.tutorial:pushOnce("firstWin4", {
		text = "This one for instance gives you an additional turn during a round.",
		pos = "ul",
		draw = function(opts)
			G.currentGameScreen.endRoundPopUp:updateCanvas(opts.dt, { rewards = true })
			G.currentGameScreen.endRoundPopUp:draw()
		end,
	})
	G.currentRun.tutorial:pushOnce("firstWin5", {
		text = "Finally, you get some money, depending on the coworker you beat, plus one dollar per unused turn.",
		pos = "ul",
		onConfirm = function()
			G.currentRun.tutorialCanPlayStraights = false
		end,
		draw = function(opts)
			G.currentGameScreen.endRoundPopUp:updateCanvas(opts.dt, { money = true })
			G.currentGameScreen.endRoundPopUp:draw()
		end,
	})
	G.currentRun.tutorial:pushOnce("firstWin6", {
		text = "You can click [[Next!]] I'll show you how to customize your dices now.'",
		pos = "ul",
	})
end

function TutorialEvents.customizationScreen()
	G.currentRun.tutorial:pushOnce("customScreen1", {
		pos = "ur",
		text = "This is the ((customization screen)). After each round, you can use the dice faces you just earned to customize your dices.",
	})

	G.currentRun.tutorial:pushOnce("customScreenx", {
		pos = "ul",
		text = "These are your 5 dices, layed down for you to modify them.",
		draw = function(opts)
			G.currentGameScreen:drawCustomizationMat()
			G.currentGameScreen:drawDeckDices()
			--print(G.currentGameScreen.screenType)
		end,
	})

	G.currentRun.tutorial:pushOnce("customScreen2", {
		text = "Each of the 6 sides of your 5 dices can be completely personalized. You can swap faces across dices, and apply the faces in your inventory.",
		pos = "ul",
		draw = function(opts)
			G.currentGameScreen:drawCustomizationMat()
			G.currentGameScreen:drawDeckDices() --print(G.currentGameScreen.screenType)
		end,
	})

	G.currentRun.tutorial:pushOnce("customScreen3", {
		text = "Let your creativity speak by drag and dropping one of your rewards where you want to place it. Click confirm when you are satisfied with your work.",
		pos = "ur",
		onConfirm = function()
			G.currentRun.tutorial:pushToast({
				text = "Customize you dices with your rewards and ((confirm))",
				key = "customizeDice",
			})
		end,
		draw = function(opts)
			G.currentGameScreen:drawRewardsMedium()
			G.currentGameScreen:drawRewards()

			--print(G.currentGameScreen.screenType)
		end,
	})
end

function TutorialEvents.deskChoice()
	--Doit expliquer qu'il y a 4 choix pour chaque bureau, avec des rewards différentes
	G.currentRun.tutorial:pushOnce("deskChoice", {
		text = "Before each round, you can choose your next oponent.",
	})

	G.currentRun.tutorial:pushOnce("deskChoice2", {
		text = "Each coworker offers a unique reward, so choose wisely !",
		draw = function(opts)
			G.currentGameScreen:updateChoiceCanvas(opts.dt, { rewards = true })
			if G.currentGameScreen.currentlyHoveredObject then
				G.currentGameScreen.infoBubble:draw()
			end
		end,
	})
	G.currentRun.tutorial:pushOnce("deskChoice3", {
		text = "Click on one of your coworkers badge to fight him.",
		onConfirm = function()
			G.currentRun.tutorialCanReroll = false
			G.currentRun.deskChoice.canSelectRound = true
			G.currentRun.tutorial:pushToast({
				text = "Select your next oponent by clicking on a badge.",
				key = "oponentSelect",
			})
		end,
		draw = function(opts)
			G.currentGameScreen:updateChoiceCanvas(opts.dt, { rewards = true })
		end,
	})
end

function TutorialEvents.secondRoundStart()
	G.currentRun.tutorial:pushOnce("secondRound", {
		pos = "ur",
		text = "Time to fight your second coworker !",
	})
	G.currentRun.tutorial:pushOnce("secondRound2", {
		pos = "ur",
		text = "As you can see, your Large Straight is grayed out... That's because you can only play your figures a limited amount of time on each flor!'",
	})
	G.currentRun.tutorial:pushOnce("secondRound3", {
		pos = "ur",
		text = "That amount is indicated by the number of dot on each line of the table.",
	})
	G.currentRun.tutorial:pushOnce("secondRound4", {
		pos = "ur",
		text = "A floor is composed of two coworkers and one manager, so you'll have to survive two more rounds before all your figures become available again",
		onConfirm = function() end,
	})
	G.currentRun.tutorial:pushOnce("secondRound5", {
		pos = "ur",
		text = "You can click on the [[Info]] button to se how your other figures can be played.",
		onConfirm = function()
			G.currentRun.tutorial:pushToast({
				text = "Open the Info menu.",
				key = "openInfoMenu",
				arrows = {
					{ x = 1780, y = 875, angle = 180 },
				},
			})
			G.currentRun.tutorialInfos = true
		end,
	})
end

function TutorialEvents.infoMenu()
	G.currentRun.tutorial:pushOnce("info1", {
		pos = "ur",
		text = "All of your figures are shown there, along with other useful informations.",
		draw = function()
			G.currentRun.infoScreen:drawGridLarge()
		end,
	})

	G.currentRun.tutorial:pushOnce("info2", {
		pos = "ur",
		text = "The rightmost column of the table explain how figures can be played.",

		draw = function()
			G.currentRun.infoScreen:drawGridLarge()
		end,
	})

	G.currentRun.tutorial:pushOnce("info3", {
		pos = "ur",
		text = "This screen can be exited by clicking the Info button once again.",
		onConfirm = function()
			G.currentRun.tutorialInfos = false
			G.currentRun.tutorialInfosEnd = true
		end,
	})
end

function TutorialEvents.secondRoundStart2()
	G.currentRun.tutorial:pushOnce("info12", {
		pos = "ur",
		text = "Alright, I'll let you play this round on your own, good luck !",
		onConfirm = function()
			G.currentRun.tutorialCanReroll = true
		end,
	})
end

function TutorialEvents.managerSelection()
	G.currentRun.tutorial:pushOnce("managerSelection", {
		text = "This is the first floor manager.",
		pos = "ur",
	})
	G.currentRun.tutorial:pushOnce("managerSelection2", {
		text = "Managers apply special rules to their round. This one prevents you from playing non-numerical figures...",
		pos = "ur",
		draw = function(opts)
			G.currentGameScreen:drawBossDesc(opts.dt)
		end,
	})
	G.currentRun.tutorial:pushOnce("managerSelection3", {
		text = "That means you can't play either Full Houses, Straights, Three of a Kind and so on... You must improvise with those rules!",
		pos = "ur",
		onConfirm = function()
			G.currentRun.deskChoice.canSelectRound = true
		end,
		draw = function(opts)
			G.currentGameScreen:drawBossDesc(opts.dt)
		end,
	})
end

function TutorialEvents.managerRound()
	G.currentRun.tutorial:pushOnce("managerRound1", {
		text = "Oof! All of your non-numerical figures are down!",
		pos = "ur",
	})

	G.currentRun.tutorial:pushOnce("managerRound2", {
		text = "Lucky you, your last round earned you an Ebb! Ebb can regenerate your hands for your figures.",
		pos = "ll",
		draw = function()
			G.currentGameScreen:drawCiggiesTray()

			--Ciggies UI
			for i, ciggie in next, G.currentGameScreen.uiElements.ciggiesUI do
				if G.currentGameScreen.dragAndDroppedCiggie ~= ciggie then
					ciggie:draw()
				end
			end

			G.currentGameScreen:drawCiggiesTrayFront()
		end,
	})
	G.currentRun.tutorial:pushOnce("managerRound3", {
		text = "That means you can reuse the numercal figures you used earlier before accessing the next floor. ",
		pos = "ll",
		draw = function()
			G.currentGameScreen:drawCiggiesTray()

			--Ciggies UI
			for i, ciggie in next, G.currentGameScreen.uiElements.ciggiesUI do
				if G.currentGameScreen.dragAndDroppedCiggie ~= ciggie then
					ciggie:draw()
				end
			end

			G.currentGameScreen:drawCiggiesTrayFront()
		end,
	})
	G.currentRun.tutorial:pushOnce("managerRound4", {
		text = "If you need to, drag and drop it to the center of your screen to use it.",
		pos = "ll",
		draw = function()
			G.currentGameScreen:drawCiggiesTray()

			--Ciggies UI
			for i, ciggie in next, G.currentGameScreen.uiElements.ciggiesUI do
				if G.currentGameScreen.dragAndDroppedCiggie ~= ciggie then
					ciggie:draw()
				end
			end

			G.currentGameScreen:drawCiggiesTrayFront()
		end,
	})
	G.currentRun.tutorial:pushOnce("managerRound5", {
		text = "Alright, i'll let you beat this guy. Good luck!",
		pos = "ur",
	})
end

function TutorialEvents.shop()
	G.currentRun.tutorial:pushOnce("shop", {
		text = "Welcome to the shop!",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("shop1", {
		text = "Every floor ends with a shop. Here you can buy everything you need to improve your run with your hard earned money.",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("givingMoney", {
		text = "Because I like you, im giving you 10$ so you can treat yourself right. But only for this one time!",
		pos = "ul",
		onConfirm = function()
			G.currentRun.shop:setMoneyTo(G.currentRun.money + 10)
		end,
	})

	G.currentRun.tutorial:pushOnce("shop2", {
		text = "Now, buy yourself a dice face of your choice. ((Slide a dice face to your inventory to buy it)).",
		pos = "ul",
		onConfirm = function()
			G.currentRun.shop.canBuyDiceFace = true
			G.currentRun.tutorial:pushToast({
				text = "Slide a dice face to your inventory to buy it.",
				key = "diceFaceBuy",
			})
		end,
	})
end

function TutorialEvents.shop2()
	G.currentRun.tutorial:pushOnce("presentingStickers", {
		text = "Great! You just bought your first dice face. You'll be able to apply it to one of your dices after exiting the shop.",
		pos = "ul",
		onStart = function()
			G.currentRun.tutorial:confirmToast("diceFaceBuy")
		end,
	})

	G.currentRun.tutorial:pushOnce("presentingStickers2", {
		text = "Here, you can also buy stickers that can grant you permanent bonuses and abilities. They are a little bit expensives, but worth it!",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("presentingStickers3", {
		text = "There are two types of Stickers. Normal ones and Holographics. Holographic Stickers have more powerfull advantages, but cost a little more.",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("presentingStickers4", {
		text = "Grab one of them and your play mat will appear. Drop it where you want to stick it to buy it!",
		pos = "ul",
		onConfirm = function()
			G.currentRun.shop.canBuySticker = true
			G.currentRun.shop.canBuyDiceFace = false
			G.currentRun.tutorial:pushToast({
				text = "Grab a sticker and slide it to your play mat to buy it.",
				key = "stickerBuy",
			})
		end,
	})
end

function TutorialEvents.shop3()
	G.currentRun.tutorial:pushOnce("finishingShopPres", {
		text = "Great Choice! Magic Wands are also on your disposal! Grab one and slide it to your Magic Wand Box to add it to your inventory.",
		pos = "ul",
		onStart = function()
			G.currentRun.tutorial:confirmToast("dstickerBuy")
		end,
	})
	G.currentRun.tutorial:pushOnce("finishingShopPres2", {
		text = "Finally, figures can be leveled up. Drinking a coffee will permanently increase the base value of the corresponding figure.",
		pos = "ul",
	})

	G.currentRun.tutorial:pushOnce("finishingShopPres3", {
		text = "You can always refresh the shop if the selection is not your cup of tea. But be careful, it cost money! And the price keeps going up each time you refresh it.",
		pos = "ul",
	})

	G.currentRun.tutorial:pushOnce("finishingShopPres4", {
		text = "Okay i'll let you skim through everything there is and let you spend your last dollars. You can click [[Next!]] to carry on to the customization screen.",
		pos = "ul",
		onConfirm = function()
			G.currentRun.shop.canBuySticker = true
			G.currentRun.shop.canBuyAnything = true
			G.currentRun.shop.canBuySticker = true
			G.currentRun.shop.canRerollShop = true
			G.currentRun.shop.canGoToNextRound = true
			G.currentRun.shop.canBuyDiceFace = true
		end,
	})
end

function TutorialEvents.secondFloor()
	G.currentRun.tutorial:pushOnce("secondFloor", {
		text = "Alrighty! You managed to reach the second floor",
		pos = "ur",
	})

	G.currentRun.tutorial:pushOnce("secondFloor2", {
		text = "As promised, your Large Straight can be used again! But don't worry, there are ways to increase the number of times a figure can be used in a single floor... But i'm not saying more.",
		pos = "ur",
	})

	G.currentRun.tutorial:pushOnce("secondFloor3", {
		text = "Well, I think you know the basis now. You need to reach and beat the manager of the 8th floor to escape this [[sh&#@!ty company]]. Good luck mate!",
		pos = "ur",
		onConfirm = function()
			G.currentRun.deskChoice.canSelectRound = true
		end,
	})
end

function TutorialEvents.gameOver()
	G.currentRun.tutorial:push({
		text = "Wait, you lost ..? Okay i'm giving you another chance, but do better !",
		pos = "ur",
		onConfirm = function()
			G.currentRun.currentRound:resetRound()
			G.currentRun:resetAvailableFigures()
		end,
	})
end

return TutorialEvents
