local Constants = {
    VIRTUAL_GAME_WIDTH = 1920,
    VIRTUAL_GAME_HEIGHT = 1080,
    BASE_REROLLS = 2,
    BASE_TRIGGER_ANIMATION_TIME = 0.15,--secondes
    GAME_VERSION = "0.0.7-dev"
}

--Enums
Constants.FIGURES = {
    ONES = 1,
    TWOS = 2,
    THREES = 3,
    FOURS = 4,
    FIVES = 5,
    SIXS = 6,
    CHANCE = 7,
    THREE_OAK = 8,
    FOUR_OAK = 9,
    FULL_HOUSE = 10,
    SMALL_SUITE = 11,
    LARGE_SUITE = 12,
    DELUXE = 13
}

Constants.PAGES = {
    MAIN_MENU = 0,
    GAME = 1,
    SETTINGS = 2,
    COLLECTION = 3
}

Constants.RUN_STATES = {
    ROUND = 1, --Phase de jeu
    SHOP = 2, --TBD
    ROUND_CHOICE = 3, --Choix du prochain round à jouer
    GAME_OVER = 4, --Ecran de game over
    MAP = 5, --Map du batiment, et infos de run
    DICE_CUSTOMIZATION = 6
}

Constants.ROUND_STATES = {
    REROLLING = 1,
    PLAYING = 2,
    TRIGGERING_DICE = 3,
    RECALLING = 4
}

Constants.ROUND_TYPES = {
    BASE = 1,
    BOSS = 2
}

Constants.EMPLOIS = {
    "Stagiaire",
    "Comptable",
    "RH",
    "Assistant.e",
    "Développeur",
    "Chef.fe de projet",
    "Responsable marketing",
    "Designer graphique",
    "Chargé de communication",
    "Ressources humaines",
    "Technicien informatique",
    "Support client",
    "Vendeur / Commercial",
    "Responsable produit",
    "Data analyst",
    "Juriste d’entreprise",
    "Assistant administratif",
    "Responsable logistique"
}

return Constants