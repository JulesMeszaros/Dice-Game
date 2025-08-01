--Enum used to store all the sprites paths
local Sprites = {}

Sprites.MAIN_LOGO = love.graphics.newImage("src/assets/sprites/ui/Main Logo.png")

Sprites.DESCRIPTION = love.graphics.newImage("src/assets/sprites/ui/Description.png")
Sprites.DICE_INFOS = love.graphics.newImage("src/assets/sprites/ui/DiceComposition.png")
Sprites.DECK = love.graphics.newImage("src/assets/sprites/ui/Deck.png")

Sprites.ENEMY_INFOS= love.graphics.newImage("src/assets/sprites/ui/Enemy.png")
Sprites.PLAYER_INFOS = love.graphics.newImage("src/assets/sprites/ui/Player.png")

Sprites.FLOOR_INFOS= love.graphics.newImage("src/assets/sprites/ui/Office.png")
Sprites.TURNS= love.graphics.newImage("src/assets/sprites/ui/Turns.png")
Sprites.MONEY= love.graphics.newImage("src/assets/sprites/ui/Money.png")
Sprites.REROLLS= love.graphics.newImage("src/assets/sprites/ui/Rerolls.png")

Sprites.GRID= love.graphics.newImage("src/assets/sprites/ui/Grid.png")
Sprites.DICE_MAT = love.graphics.newImage("src/assets/sprites/ui/Dice Mat.png")

Sprites.REWARDS = love.graphics.newImage("src/assets/sprites/ui/Rewards.png")
Sprites.CUSTOMIZATION_MAT = love.graphics.newImage("src/assets/sprites/ui/Customization Mat.png")

Sprites.CIGGIES_TRAY = love.graphics.newImage("src/assets/sprites/ui/CiggieTray.png")
Sprites.CIGGIES_TRAY_BACK = love.graphics.newImage("src/assets/sprites/ui/Ciggie Tray Back.png")
Sprites.CIGGIES_TRAY_FRONT = love.graphics.newImage("src/assets/sprites/ui/Ciggie Tray Front.png")

Sprites.BADGE = love.graphics.newImage("src/assets/sprites/ui/Badge.png")

Sprites.SHOP_BG = love.graphics.newImage("src/assets/sprites/ui/Shop.png")

Sprites.INVENTORY = love.graphics.newImage("src/assets/sprites/ui/Inventory.png")
Sprites.INVENTORY_SMALL = love.graphics.newImage("src/assets/sprites/ui/Inventory Small.png")
Sprites.INVENTORY_MEDIUM = love.graphics.newImage("src/assets/sprites/ui/Inventory Medium.png")
Sprites.INVENTORY_LARGE = love.graphics.newImage("src/assets/sprites/ui/Inventory Large.png")

Sprites.PRICE_TAG = love.graphics.newImage("src/assets/sprites/ui/PriceTag.png")

Sprites.REWARDS_SMALL = love.graphics.newImage("src/assets/sprites/ui/Rewards Small.png")
Sprites.REWARDS_MEDIUM = love.graphics.newImage("src/assets/sprites/ui/Rewards Medium.png")

Sprites.DISABLED = love.graphics.newImage("src/assets/sprites/ui/Disabled.png")

--End round
Sprites.END_ROUND_BG = love.graphics.newImage("src/assets/sprites/ui/End Round BG.png")
Sprites.CASH_REWARD = love.graphics.newImage("src/assets/sprites/ui/Cash Reward.png")
Sprites.END_ROUND_REWARDS = love.graphics.newImage("src/assets/sprites/ui/End Round Rewards.png")
Sprites.YOU_WON = love.graphics.newImage("src/assets/sprites/ui/You Won.png")

Sprites.LIGHTER = love.graphics.newImage("src/assets/sprites/ui/Lighter.png")
Sprites.SELL_CIGGIE = love.graphics.newImage("src/assets/sprites/ui/Sell Ciggie.png")

--Infos screen
Sprites.PLAYER_BADGE = love.graphics.newImage("src/assets/sprites/ui/Player Badge.png")
Sprites.GRID_LARGE = love.graphics.newImage("src/assets/sprites/ui/Grid Large.png")
Sprites.OFFICE_DESCRIPTION = love.graphics.newImage("src/assets/sprites/ui/Office Description.png")
Sprites.OFFICE_DESCRIPTION_EMPTY = love.graphics.newImage("src/assets/sprites/ui/Office Description Empty.png")
Sprites.FLOOR_DESCRIPTION = love.graphics.newImage("src/assets/sprites/ui/Floor Description.png")
Sprites.PROGRESSION = love.graphics.newImage("src/assets/sprites/ui/Progression.png")

--COFFE
Sprites.COFFEE_SPRITES = {
    love.graphics.newImage("src/assets/sprites/coffee/Ristretto.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Piccolo.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Espresso.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Doppio.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Lungo.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Americano.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Rapido Y Sucio.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Macchiato.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Capuccino.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Mocaccino.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Corretto.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Mazagran.png"),
    love.graphics.newImage("src/assets/sprites/coffee/Coffee Deluxe.png")
}

return Sprites