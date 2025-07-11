local Constants = {
    VIRTUAL_GAME_WIDTH = 1920,
    VIRTUAL_GAME_HEIGHT = 1080,
    BASE_REROLLS = 2,
    BASE_TRIGGER_ANIMATION_TIME = 0.15,--secondes
    GAME_VERSION = "0.3.0",
    BASE_TURNS = 3,
    BASE_AVAILABLE_HANDS = 1,
    DESKS_BY_FLOOR = 2,
    BASE_MAX_CIGGIES = 5,
    SHOP_EVERY_DESK = true --Variable de debug : lance le shop après chaque round peu importe le type
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

Constants.FIGURES_COLORS = {
    {209/255, 243/255, 226/255},
    {179/255, 227/255, 218/255},
    {172/255, 204/255, 228/255},
    {176/255, 169/255, 228/255},
    {122/255, 137/255, 239/255},
    {97/255, 92/255, 245/255},
    {255/255, 223/255, 120/255},
    {221/255, 76/255, 173/255},
    {255/255, 104/255, 147/255},
    {249/255, 130/255, 132/255},
    {245/255, 110/255, 86/255},
    {232/255, 79/255, 79/255},
    {108/255, 86/255, 113/255}
}

Constants.PAGES = {
    MAIN_MENU = 0,
    GAME = 1,
    SETTINGS = 2,
    COLLECTION = 3
}

Constants.RUN_STATES = {
    ROUND = 1, --Phase de jeu
    SHOP = 2, --SHOP
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
    "Respo marketing",
    "Designer",
    "Chargé de com",
    "Technicien",
    "Support client",
    "Commercial",
    "Responsable produit",
    "Data analyst",
    "Juriste",
    "Assistant admin.",
    "Responsable"
}

Constants.CANVAS = { --Used for the ciggies
    DICE_MAT = 1,
}

return Constants