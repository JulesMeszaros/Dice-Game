local Constants = require("src.utils.Constants")
local Inputs = require("src.utils.scripts.Inputs")
local AnimationUtils = require("src.utils.scripts.Animations")
local Sprites = require("src.utils.Sprites")
local Ciggie = require("src.classes.ui.Ciggie")
local FaceHoverInfo = require("src.classes.ui.FaceHoverInfo")
local Badge = require("src.classes.ui.Badge")
local DiceFace = require("src.classes.ui.DiceFace")
local FaceObject = require("src.classes.FaceObject")
local Screen = require("src.classes.GameScreen")
local DiceCustomization = require("src.screens.DiceCustomization")
local FaceTypes = require("src.classes.FaceTypes")


local Shop = setmetatable({}, {__index = Screen})
Shop.__index = Shop

function Shop:new(run)
    local self = setmetatable(Screen:new(run.currentFloor, run, Constants.RUN_STATES.SHOP, run.currentRound), Shop)

    self:createDiceNet()
    self:createDeck()
    self:generateCiggiesUI()

    --Shop Objects
    self.availableFaceObjects = {}
    self.availableCiggies = {}
    self.availableCoffees = {}

    --Shop Objects UI
    self.availableFaceObjectsUI = {}
    self.availableCiggiesUI = {}
    self.availableCoffeesUI = {}

    --Inventory faces
    self.inventoryFacesUI = {}

    self:generateNewShop()
    self:createInventoryFaces()

    return self
end

function Shop:update(dt)
    self.animator:update(dt)

    self:getCurrentlyHoveredCiggie()

    self:updateCanvas(dt)
end

function Shop:updateCanvas(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    --Buttons
    for key,button in next,self.uiElements.buttons do
        button:update(dt)
        button:draw()
    end

    --UI
    self:drawDeck(dt)
    self:drawDescription()
    self:drawFigureGrid()
    self:drawRoundDetails()
    self:drawDiceDetails(dt)
    self:drawCiggiesTray()
    self:drawInventoryBackGround()
    self:drawShopBackground()

    self:drawInventoryFaces(dt)

    --Shop faces UI
    for i,faceUI in next,self.availableFaceObjectsUI do
        faceUI:update(dt)
        faceUI:draw()
    end

    --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
        ciggie:draw()
    end
    
    love.graphics.setCanvas(currentCanvas)
end

function Shop:draw()
    love.graphics.draw(self.canvas, 0, 0)
end

--==Update functions==--
function Shop:updateDiceNet(dt)
   local i = 1
    for k,df in next,self.infoFaces do
        df:setRepresentedFace(self.currentlySelectedDice.diceObject:getFace(i))
        df:updateSprite()
        df:update(dt)
        df:draw()
        i =i+1
    end
end

--==Input functions==--
function Shop:mousepressed(x, y, button, istouch, presses)
    --Buttons
   for key,button in next,self.uiElements.buttons do
        button:clickEvent()
    end

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:clickEvent()
    end

    --Deck faces
    for key,uiFace in next,self.deckFaces do
        uiFace:clickEvent()
    end

    --Shop elements
    --Faces
    for key,uiFace in next,self.availableFaceObjectsUI do
        uiFace:clickEvent()
    end
end

function Shop:mousereleased(x, y, button, istouch, presses)

    --release event on UI elements (buttons)
    for key,button in next,self.uiElements.buttons do
        local wasReleased = button:releaseEvent()
        if(wasReleased) then --Si le click a été complété
            button:getCallback()()
        end
    end

    for key,face in next,self.deckFaces do
        local wasReleased = face:releaseEvent()
        if(wasReleased)then --On sélectionne la face a switcher
            self:resetSelectedDices()
            face:setSelected(true)
            self.currentlySelectedDice = face
        end
    end

    --Ciggies
    for key,ciggie in next,self.uiElements.ciggiesUI do
        ciggie:releaseEvent()
        ciggie.isBeingDragged = false
    end

    --Shop
    --Faces
    for key,face in next,self.availableFaceObjectsUI do
        local wasReleased = face:releaseEvent()
        face.isBeingDragged = false

        face.targetX = face.anchorX
        face.targetY = face.anchorY

        if(wasReleased)then
            self:buyDiceFace(face.representedObject, face, key)
        end
    end
end

function Shop:mousemoved(x, y, dx, dy, isDragging)
    --Drag and drop Ciggies

    if(isDragging == true)then 
        for key,ciggie in next, self.uiElements.ciggiesUI do
            if(ciggie.isDraggable and ciggie.isBeingClicked) then
                ciggie.isBeingDragged = true
                ciggie.dragXspeed = dx
                if(ciggie.targetX+dx<self.canvas:getWidth()-ciggie.width/2 and ciggie.targetX+dx>0+ciggie.width/2) then --Vérification qu'on ne dépasse par les limites horizontales
                    ciggie.targetX = (ciggie.targetX + dx) 
                end

                if(ciggie.targetY+dy<self.canvas:getHeight()-ciggie.height/2 and ciggie.targetY+dy>0+ciggie.height/2) then --Vérification qu'on ne dépasse pas les limites verticales
                    ciggie.targetY = (ciggie.targetY + dy) 
                end
            end
        end
    end

    --Shop
    --Faces
    if(isDragging == true)then 
        for key,face in next, self.availableFaceObjectsUI do
            if(face.isDraggable and face.isBeingClicked) then
                face.isBeingDragged = true
                face.dragXspeed = dx
                face.targetX = (face.targetX + dx) 
                face.targetY = (face.targetY + dy) 
            end
        end
    end

end

function Shop:keypressed(key)
    print(key)
end

--==Shop Functions==--
function Shop:buyDiceFace(face, faceUI, key)
    if(table.getn(self.run.facesInventory)<8)then
        print("face bought : ", face.name, face.faceValue)

        --Add face to inventory
        table.insert(self.run.facesInventory, face)

        --Remove faceUI from shop list
        table.remove(self.availableFaceObjectsUI, key)

        --Add FaceUI to inventory
        table.insert(self.inventoryFacesUI, faceUI)

        --Remove face from shop
        table.remove(self.availableFaceObjects, key)
        print("-------")
        print("Inventory")

        --Update the positions of the dices
        self:updateInventoryPositions()

        for i,k in next,self.run.facesInventory do
            print(k.name, k.faceValue)
        end
    else
        print("no more space in iventory")
    end
end

--==Shop generation==--
function Shop:generateNewShop()
    --Generate the objects to buy
    self:generateAvailableFaces()
    self.availableFaceObjectsUI = {}
    --Generate the UI elements    
    for i,f in next,self.availableFaceObjects do
        local faceUI = DiceFace:new(
            nil,
            f,
            180*i + self.shopBGTX - 60,
            80+ self.shopBGTY + 60,
            120,
            false,
            true,
            function() return Inputs.getMouseInCanvas(0, 0) end,
            nil
        )
        faceUI.anchorX = 180*i + self.shopBGTX - 60
        faceUI.anchorY = 80+ self.shopBGTY + 60

        table.insert(self.availableFaceObjectsUI, faceUI)
    end
end

function Shop:generateAvailableFaces()
    self.availableFaceObjects = {}
    for i=1, 4 do
        local f = self:getRandomFaceObject()
        table.insert(self.availableFaceObjects, f)
    end
end

--==UTILS==--
function Shop:getCurrentlyHoveredObject()
    return nil
end

function Shop:resetSelectedDices()
    --Dice faces
    for key,face in next,self.deckFaces do
        face:setSelected(false)
    end
end

function Shop:getRandomFaceObject()
    --Get the list of keys
    local keys = {}
    for key, _ in pairs(FaceTypes) do
        table.insert(keys, key)
    end

    local randomFaceKey = keys[math.random(#keys)]
    local randomFaceType = FaceTypes[randomFaceKey] --On récupère une face type au hasard
    local randomFaceValue = math.random(1,6) --La face numérique

    local randomFaceObject = randomFaceType:new(randomFaceValue, randomFaceValue)

    return randomFaceObject 
end

--==Additionnal init functions==--
function Shop:createDeck()
    local deckFaces = {}
    for i,dice in next,self.diceObjects do
        --Create the UIFaces
        local faceUI = DiceFace:new(
                dice,
                dice:getFace(1),
                self.deckCanvas:getWidth()/2+1,
                70+((i-1)*180),
                120,
                true,
                true,
                function()return Inputs.getMouseInCanvas(1300, 110)end,
                nil
            )
        deckFaces[dice] = faceUI
    end
    self.deckFaces = deckFaces
end 

function Shop:createInventoryFaces()
    local xPos = {160, 320, 480, 640, 160, 320, 480, 640}
    local yPos = {160,160,160,160, 320, 320, 320, 320}

    for i,face in next,self.run.facesInventory do
        --Create the UIFaces

        local faceUI = DiceFace:new(
                nil,
                face,
                xPos[i] - 60 + self.inventoryTX,
                yPos[i] + self.inventoryTY -10,
                120,
                false,
                true,
                function()return Inputs.getMouseInCanvas(0, 0)end,
                nil
            )

        table.insert(self.inventoryFacesUI, faceUI)
    end
end

--==Additionnal draw functions==--
function Shop:drawDeck(dt)
    local targetCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.deckCanvas)
    love.graphics.clear()
    
    --Draw the background
    love.graphics.draw(Sprites.DECK, 0, 0)

    --draw the deck faces
    for dice,face in next,self.deckFaces do
        if(face:getIsSelected())then
            face.selectionScale = 0.1
        else
            face.selectionScale = 0
        end
        face:update(dt)
        face:draw()
    end

    love.graphics.setCanvas(targetCanvas)
    love.graphics.draw(self.deckCanvas, self.deckX, self.deckY)
end

function Shop:drawDiceDetails(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.diceDetailsCanvas)
    love.graphics.clear()

    --Draw sprite
    love.graphics.draw(Sprites.DICE_INFOS, 0, 0)
    
    --Draw the dice net
    if(self.currentlySelectedDice)then
        self:updateDiceNet(dt)
    end

    love.graphics.setCanvas(currentCanvas)

    love.graphics.draw(self.diceDetailsCanvas, self.diceDetailsX, self.diceDetailsY, 0, 1, 1, self.diceDetailsCanvas:getWidth(), 0)
end

function Shop:drawInventoryFaces(dt)
    for k,uiFace in next,self.inventoryFacesUI do
        uiFace:update(dt)
        uiFace:draw()
    end
end

function Shop:updateInventoryPositions()
    local xPos = {160, 320, 480, 640, 160, 320, 480, 640}
    local yPos = {160,160,160,160, 320, 320, 320, 320}

    for i,uiFace in next,self.inventoryFacesUI do
        uiFace.anchorX = xPos[i] - 60 + self.inventoryTX
        uiFace.anchorY = yPos[i] + self.inventoryTY -10
        uiFace.targetX = xPos[i] - 60 + self.inventoryTX
        uiFace.targetY = yPos[i] + self.inventoryTY -10
    end
end

--==Hover functions==--
function Shop:getCurrentlyHoveredCiggie()
    self.currentlyHoveredCiggie = nil

    for i,ciggie in next,self.uiElements.ciggiesUI do
        if(ciggie:isHovered())then
            self.currentlyHoveredCiggie = ciggie
            break
        end
    end
end

return Shop