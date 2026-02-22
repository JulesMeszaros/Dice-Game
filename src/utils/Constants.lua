local Sprites = require("src.utils.Sprites")

local Constants = {
	--Game metadatas
	VIRTUAL_GAME_WIDTH = 1920,
	VIRTUAL_GAME_HEIGHT = 1080,
	GAME_VERSION = "0.10.0",

	--Game base stats
	BASE_REROLLS = 2,
	DESKS_BY_FLOOR = 2,
	FLOORS_BY_RUN = 8,
	BASE_MAX_CIGGIES = 3,
	BASE_TURNS = 3,
	BASE_AVAILABLE_HANDS = 1,
	BASE_MAX_HANDS_FIGURES = 3,

	--Debug
	SHOP_EVERY_DESK = false,
	OVERPOWER = false,
	DEBUG = true,

	--Prices
	BASE_STICKER_PRICE = 10,
	BASE_HOLO_STICKER_PRICE = 15,
	BASE_FACE_PRICE = 5,
	BASE_FACE_SELL_PRICE = 3,
	BASE_CIGGIE_SELL_PRICE = 1,
	BASE_COFFEE_PRICE = 5,
	BASE_CIGGIE_PRICE = 2,
	BASE_SHOP_REROLL_PRICE = 3,
	BASE_SHOP_REROLL_PRINCE_INCREMENT = 1,
}

--Effects descriptions
Constants.EFFECT_DESCRIPTIONS = {
	GHOST = { "Ghost", "Becomes disabled until the end of this round if discarded or not used in the played figure." },
	BLANK = { "Blank", "Doesn't count as a numbered face, but can be used in any figure." },
	BACKUP = { "Backup", "Triggers its effect when not selected in the played hand." },
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
	DELUXE = 13,
}

Constants.FIGURES_LABELS = {
	"Ones",
	"Twos",
	"Threes",
	"Fours",
	"Fives",
	"Sixes",
	"Chance",
	"Three Of A Kind",
	"Four Of A Kind",
	"Full House",
	"Small Straight",
	"Large Straight",
	"Deluxe",
}

Constants.COFFEE_NAMES = {
	"Ristretto",
	"Piccolo",
	"Espresso",
	"Doppio",
	"Lungo",
	"Americano",
	"Rapido Y Sucio",
	"Macchiato",
	"Capuccino",
	"Mocaccino",
	"Corretto",
	"Mazagran",
	"Cafe Deluxe",
}

Constants.FIGURES_COFFES = {
	Sprites.COFFE_ONES,
	Sprites.COFFE_TWOS,
	Sprites.COFFE_THREES,
	Sprites.COFFE_FOUR,
	Sprites.COFFE_FIVES,
	Sprites.COFFE_SIXES,
	Sprites.COFFE_CHANCE,
	Sprites.COFFE_THREE_OAK,
	Sprites.COFFE_FOUR_OAK,
	Sprites.COFFE_FULL_HOUSE,
	Sprites.COFFE_SML_SUITE,
	Sprites.COFFE_LRG_SUITE,
	Sprites.COFFE_DELUXE,
}

Constants.COFFEE_PATHS = {
	"src/assets/sprites/coffee/Ristretto.png",
	"src/assets/sprites/coffee/Piccolo.png",
	"src/assets/sprites/coffee/Espresso.png",
	"src/assets/sprites/coffee/Doppio.png",
	"src/assets/sprites/coffee/Lungo.png",
	"src/assets/sprites/coffee/Americano.png",
	"src/assets/sprites/coffee/Rapido Y Sucio.png",
	"src/assets/sprites/coffee/Macchiato.png",
	"src/assets/sprites/coffee/Capuccino.png",
	"src/assets/sprites/coffee/Mocaccino.png",
	"src/assets/sprites/coffee/Corretto.png",
	"src/assets/sprites/coffee/Mazagran.png",
	"src/assets/sprites/coffee/Coffee Deluxe.png",
}

Constants.FIGURES_COLORS = {
	{ 209 / 255, 243 / 255, 226 / 255 },
	{ 179 / 255, 227 / 255, 218 / 255 },
	{ 172 / 255, 204 / 255, 228 / 255 },
	{ 176 / 255, 169 / 255, 228 / 255 },
	{ 122 / 255, 137 / 255, 239 / 255 },
	{ 97 / 255, 92 / 255, 245 / 255 },
	{ 255 / 255, 223 / 255, 120 / 255 },
	{ 221 / 255, 76 / 255, 173 / 255 },
	{ 255 / 255, 104 / 255, 147 / 255 },
	{ 249 / 255, 130 / 255, 132 / 255 },
	{ 245 / 255, 110 / 255, 86 / 255 },
	{ 232 / 255, 79 / 255, 79 / 255 },
	{ 108 / 255, 86 / 255, 113 / 255 },
}

Constants.PAGES = {
	MAIN_MENU = 0,
	GAME = 1,
	SETTINGS = 2,
	COLLECTION = 3,
	CHARACTER_CREATION = 4,
}

--Constante servant à déterminer quel écran est affiché.
Constants.RUN_STATES = {
	ROUND = 1, --Phase de jeu
	SHOP = 2, --SHOP
	ROUND_CHOICE = 3, --Choix du prochain round à jouer
	GAME_OVER = 4, --Ecran de game over
	MAP = 5, --Map du batiment, et infos de run
	DICE_CUSTOMIZATION = 6,
	RUN_END = 7,
}

Constants.ROUND_STATES = {
	REROLLING = 1,
	PLAYING = 2,
	TRIGGERING = 3,
	RECALLING = 4,
	END_ROUND = 5,
	GAME_OVER = 6,
}

Constants.ROUND_TYPES = {
	BASE = 1,
	BOSS = 2,
}

--Managers
Constants.BOSS_TYPES = {
	CHEF_DE_PROJET = 1,
	CHEF_COMPTABLE = 2,
	TRESORIER = 3,
	RESPONSABLE_SECURITE = 5,
	CHEF_RD = 4,
}

Constants.BOSS_TYPES_DESC = {
	{ "Project Manager", "Cannot play numbered figures (ones, twos, threes...)" },
	{ "Chief Accountant", "Cannot play non-numbered figures" },
	{ "Tresorier", "Playing a dice costs 1$" },
	{ "R/D Manager", "Rerolls are added to the numbers of turns, and is set to 0" },
	{ "Safety Advisor", "Cannot use magic wands this round" },
}

Constants.EMPLOIS = {
	"Intern",
	"Accountant",
	"HR",
	"Assistant",
	"Developer",
	"Project Manager",
	"Marketing Manager",
	"Designer",
	"Communications Officer",
	"Technician",
	"Customer Support",
	"Sales Rep",
	"Product Manager",
	"Data Analyst",
	"Legal Counsel",
	"Admin Assistant",
	"Manager",
	"Tax Fraudster",
	"Streamer",
	"Ghost Employee",
	"Expert",
}

Constants.PARALAXE_MAX_OFFSET = {
	--Layer 1 (front)
	40,
	--Layer 2 (middle)
	30,
	--Layer 3 (back)
	20,
	--Aucun layer (4)
	0,
}

--TODO
Constants.BACKGROUND_COLORS = {
	DARK_GRAY = { 40 / 255, 40 / 255, 43 / 255 },
	GREEN = { 81 / 255, 126 / 255, 84 / 255 },
	RED = { 208 / 255, 67 / 255, 67 / 255 },
	PURPLE = { 163 / 255, 149 / 255, 219 / 255 },
	TRIGGER = {},
	ORANGE = {},
	BLUE = {},
	DESK_CHOICE = {},
}

return Constants
