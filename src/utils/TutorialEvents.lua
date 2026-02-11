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
			print("tutorial ok")
		end,
	})
end

function TutorialEvents.firstRoll()
	--Message affiché après le premier lancer. Explique comment reroll et sélectionner des dés.
	G.currentRun.tutorial:pushOnce("firstRoll1", {
		text = "Hey, good throw ! You almost got a Small Straight. Keep those 3, 4 and 5 by clicking on them and reroll the other two.",
		pos = "ul",
	})
end

function TutorialEvents.secondRoll()
	--Message affiché après le premier lancer. Explique comment reroll et sélectionner des dés.
	G.currentRun.tutorial:pushOnce("secondRoll", {
		text = "Too bad! But you still have one chance. Roll Again!",
		pos = "ul",
	})
end

function TutorialEvents.thirdRoll()
	--Message affiché après le premier lancer. Explique comment reroll et sélectionner des dés.
	G.currentRun.tutorial:pushOnce("thirdroll1", {
		text = "Nice! We just rolled a 2 AND a 6! Even better than a Small Straight, we just rolled a Large one. Select the two last dices by clicking on them also, and select the Large Straight on the table on your left.",
		pos = "ur",
	})

	G.currentRun.tutorial:pushOnce("thirdroll2", {
		text = "As you can see, this figure gives us 25 points. But when you play a figure, each dice applies an effect based on its played side. Here your dices are a bit boring...",
		pos = "ur",
	})
	G.currentRun.tutorial:pushOnce("thirdroll3", {
		text = "All they do is giving an additional 10 points when scored... You can see that by hovering your mouse above one of them.",
		pos = "ur",
	})
	G.currentRun.tutorial:pushOnce("thirdroll4", {
		text = "When added to our base 25 points though, these 10 points per dices should be enough to reach our 80 points objective. Play your large straight to win this round, i'll give you something special if you do.'",
		pos = "ur",
		onConfirm = function()
			G.currentRun.tutorialCanPlayFigure = true
		end,
	})
end

function TutorialEvents.firstRoundWin()
	G.currentRun.tutorial:pushOnce("firstWin", {
		text = "Well done, you won your first round!",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("firstWin2", {
		text = "You get money for each round you beat, depending on the coworker your beat. Add to that 1$ for each hand you didn't use.",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("firstWin3", {
		text = "Also, you earned two new ((dice faces)! Hover you mouse over them to see what their effect are.",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("firstWin4", {
		text = "Last, but not least, you earned your first magic wand ! Magic Wands give you an instant bonus when used, like an additional reroll or even 5 extra bucks when needed.",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("firstWin5", {
		text = "Use them when needed by grabbing one of them and sliding it to the center of your screen.",
		pos = "ul",
	})
end

function TutorialEvents.customizationScreen()
	G.currentRun.tutorial:pushOnce("customScreen1", {
		pos = "ur",
		text = "This is the ((customization screen)). Here, you can use the dice faces you just earned to customize your dices.",
	})

	G.currentRun.tutorial:pushOnce("customScreen2", {
		text = "Each of the 6 sides of your 5 dices can be completely personalized. Want a dice with six 6? You are free to do so ! You can evenreorganize all of the existing faces right now.",
		pos = "ur",
	})
	G.currentRun.tutorial:pushOnce("customScreen3", {
		text = "You can drag and drop one of your fresh rewards on the face you want to apply it. When you are satisfied with your creation, hit[[NEXT OFFICE!]] to carry on.",
		pos = "ur",
	})
end

function TutorialEvents.deskChoice()
	--Doit expliquer qu'il y a 4 choix pour chaque bureau, avec des rewards différentes
	G.currentRun.tutorial:pushOnce("deskChoice", {
		text = "Time to choose your next oponent ! Before each round, you will be faced with four of your coworkers.",
	})

	G.currentRun.tutorial:pushOnce("deskChoice2", {
		text = "Each coworker offers a unique reward, so chose wisely !",
	})
	G.currentRun.tutorial:pushOnce("deskChoice3", {
		text = "Again, you can hover your mouse hover the rewards to see their in-game effects. Click on the badge of the coworkeryou want to battle to start the next round.",
	})
end

function TutorialEvents.secondRoundStart()
	G.currentRun.tutorial:pushOnce("secondRound", {
		pos = "ur",
		text = "Time to fight your second coworker !",
	})
	G.currentRun.tutorial:pushOnce("secondRound2", {
		pos = "ur",
		text = "As you can see, the line corresponding to your Large Straight is grayed. That is because you ran out of hands for this figure.",
	})
	G.currentRun.tutorial:pushOnce("secondRound3", {
		pos = "ur",
		text = "Each figure can only be played once per floor! So be careful not to waste your best figures on your round.",
	})
	G.currentRun.tutorial:pushOnce("secondRound4", {
		pos = "ur",
		text = "Each floor is composed of two coworkers and a manager. So you got two rounds before going to the next floor and regaining the ability to play your Large Straight.",
	})
end

function TutorialEvents.managerSelection()
	G.currentRun.tutorial:pushOnce("managerSelection", {
		text = "Time to fight the first floor's manager!",
		pos = "ur",
	})
	G.currentRun.tutorial:pushOnce("managerSelection2", {
		text = "The manager is a special kind of oponent. He can apply special rules to the round.",
		pos = "ur",
	})
	G.currentRun.tutorial:pushOnce("managerSelection3", {
		text = "This one prevents you from playing non-numbered figures. Interesting... you can't play either Full Houses, Straights and so on...",
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
	G.currentRun.tutorial:pushOnce("shop2", {
		text = "First, you can buy dice faces to compose your dices.Slide one to your inventory to buy it",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("shop3", {
		text = "Magic Wands are also on your disposal! Grab one and slide it to your Magic Wand Box to add it to your inventory.",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("shop4", {
		text = "You can also level up your figures. Drinking a coffee will permanently increase the base value of the corresponding figure.",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("shop5", {
		text = "Finally, Stickers are here to grant you permanent bonuses and abilities. They are a little bit expensives, but worth it!",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("shop6", {
		text = "There are two types of Stickers. Normal ones and Holographics. Holographic Stickers have more powerfull advantages, but cost a little more.",
		pos = "ul",
	})
	G.currentRun.tutorial:pushOnce("shop7", {
		text = "Grab one of them and your play mat will appear. Drop it where you want to stick it to buy it!",
		pos = "ul",
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
	})
end

return TutorialEvents
