local TutorialEvents = {}

function TutorialEvents.welcomeMessage()
	--Premier message affiché au début du tutorial.
	--Doit expliquer le concept du jeu (nombre de mains, nombre de lancés, points à atteindre), et inviter au premier lancer de dé
	G.currentRun.tutorial:pushOnce("welcome1", {
		text = "Bienvenue dans ((Dice Deluxe !)) Votre objectif est de vaincre vos collègues en jouant des figures de dés et en marquant plus de point que leur objectif.",
	})

	G.currentRun.tutorial:pushOnce("welcome4", {
		text = "Pour marquer plus de points, vous pouvez également personaliser toutes les faces de vos dés, ainsi qu'améliorer vos figures et votre tapis de jeu, et utiliser des Baguettes Magiques pour vous donner des effets spéciaux ! Mais je m'emporte...",
	})
end

function TutorialEvents.firstRoll()
	--Message affiché après le premier lancer. Explique comment reroll et sélectionner des dés.
	G.currentRun.tutorial:pushOnce("firstRoll1", {
		text = "Joli lancer ! Très prometteur.",
	})
	G.currentRun.tutorial:pushOnce("firstRoll2", {

		text = "Je vois que vous avez lancé trois 6! Vous pouvez essayer de jouer la figure des 6, elle rapporte pas mal de points!",
	})
	G.currentRun.tutorial:pushOnce("firstRoll3", {

		text = "Vous disposez encore de 2 lancer. Vous pouvez donc choisir de garder certains dés, et relancer les autres. Cliquez sur les dés que vous souhaitez garder pour les mettre de côté, puis cliquez à nouveau sur [[ROLL!]] pour relancer les autres et esperer avoir de meilleurs résultats.",
	})
end

function TutorialEvents.explainFigures()
	G.currentRun.tutorial:pushOnce("figureExplain0", {
		text = "Ce jeu est similaire au jeu traditionnel du Yahtzee. Ici, vous devez former des figures à partir de vos 5 dés. Ces figures vous rapporterons un certain nombre de points de base, celon la figure jouée et les dés employés pour la former.",
	})

	G.currentRun.tutorial:pushOnce("figureExplain1", {
		text = "Vous disposez de deux principaux types de figure. Les figures numérotés, qui consistent à jouer le plus de dés du même numéro possible, et les figures ((spéciales)), qui nécessitent de remplir certaines conditions.",
	})

	G.currentRun.tutorial:pushOnce("figureExplain2", {
		text = "Jouer la figure 'Sixes' revient à jouer tous vos dés en main d'une valeur de 6. Le nombre de points rapportés sera égal à la valeur numérotée de la figure jouée (ici, 6) multiplié par le nombre de dés joués. Jouer 4 dés dans la figure des 6 vous raportera donc 24 * 6 = ((24pts))",
	})
	G.currentRun.tutorial:pushOnce("figureExplain3", {
		text = "Autre exemple : le [[Full House]] nécessite 3 dés d'une valeur identique, et deux autres dés identiques d'une autre valeur. Celui-ci vous rapportera toujours le même nombre de points, soit ((30pts)).",
	})

	G.currentRun.tutorial:pushOnce("figureExplain4", {
		text = "Vous pouvez retrouver d'avantages d'informations sur les figures et les points qu'elles rapportent dans le menu 'Info', disponible en bas à droite de votre écran.",
	})

	G.currentRun.tutorial:pushOnce("figureExplain5", {
		text = "Votre ennemi nécessite 80 points pour être battu. Vous disposez de 3 [[mains]] pour atteindre ce palier, ainsi que 3 ((rerolls)) par mains.",
	})
end

return TutorialEvents
