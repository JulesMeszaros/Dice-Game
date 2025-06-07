local Constants = {
    VIRTUAL_GAME_WIDTH = 1920,
    VIRTUAL_GAME_HEIGHT = 1080,
    BASE_TRIGGER_ANIMATION_TIME = 0.15,--secondes
    GAME_VERSION = "0.0.6-dev"
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
    GAME = 1
}

Constants.RUN_STATES = {
    ROUND = 1,
    SHOP = 2,
    GAME_OVER = 3
}



return Constants