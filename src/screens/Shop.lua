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
local Fonts = require("src.utils.Fonts")
local CiggieTypes = require("src.classes.CiggieTypes")
local CiggieObject = require("src.classes.CiggieObject")

local Shop = setmetatable({}, {__index = Screen})
Shop.__index = Shop

function Shop:new(run)
    local self = setmetatable(Screen:new(run.currentFloor, run, Constants.RUN_STATES.SHOP, run.currentRound), Shop)

    self.priceTagsScale = 1

    self:createDiceNet()
    self:createDeck()

    self.dragAndDroppedObject = nil

    --Shop Objects
    self.availableFaceObjects = {}
    self.availableCiggies = {}
    self.availableCoffees = {}

    --Shop Objects UI
    self.availableFaceObjectsUI = {}
    self.availableCiggieObjectsUI = {}
    self.availableCoffeesUI = {}

    self.facesPriceTags = {}
    self.ciggiesPriceTags = {}

    --Inventory faces
    self.inventoryFacesUI = {}
    self.rewardsFacesUI = {}

    --Wait for all the animations to end, then show the inventory and the shop + ciggies UI
    self.animator:addDelay(0.5, 
        function()
            self:generateNewShop();
            self:createInventoryFaces();
            self:createRewardFaces();
            self:generateCiggiesUI()
        end)
    return self
end

function Shop:update(dt)
    self.animator:update(dt)

    --update all face objects
    --Inventory
    for i,face in next,self.run.facesInventory do
        face:update(dt,self.run)
    end

    --Shop
    for i,face in next,self.availableFaceObjects do
        face:update(dt, self.run)
    end

    self:getCurrentlyHoveredCiggie()
    self:getCurrentlyHoveredFace()

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
    self:drawInventoryBackGroundSmall()
    self:drawShopBackground()
    self:drawRewardsSmall()

    self:drawInventoryFaces(dt)

    --Ciggies UI
    for i, ciggie in next,self.uiElements.ciggiesUI do
        ciggie:update(dt)
        ciggie:draw()
    end

    self:drawCiggiesTrayFront()

    --Shop faces UI
    for i,faceUI in next,self.availableFaceObjectsUI do
        faceUI:update(dt)
        faceUI:draw()
    end

    --Shop Ciggie UI
    for i,ciggieUI in next,self.availableCiggieObjectsUI do
        ciggieUI:update(dt)
        ciggieUI:draw()
    end

    

    self:drawFacesPriceTags()

    --Draw the drag and dropped object on top of everything else
    if(self.dragAndDroppedObject) then
        self.dragAndDroppedObject:draw()
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

    --Inventory
    for key,uiFace in next,self.inventoryFacesUI do
        uiFace:clickEvent()
    end
    --Rewards
    for key,uiFace in next,self.rewardsFacesUI do
        uiFace:clickEvent()
    end

    --Shop elements
    --Faces
    for key,uiFace in next,self.availableFaceObjectsUI do
        uiFace:clickEvent()
    end

    --Ciggies
    for key,ciggie in next,self.availableCiggieObjectsUI do
        ciggie:clickEvent()
    end
end

function Shop:mousereleased(x, y, button, istouch, presses)
    self.dragAndDroppedObject = nil
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
        local wasReleased = ciggie:releaseEvent()
        ciggie.isBeingDragged = false

        if(wasReleased) then
            self:sellCiggie(ciggie.representedObject, ciggie, key)
        end
    end

    --Inventory
    for key,face in next,self.inventoryFacesUI do
        local wasReleased = face:releaseEvent()
        face.isBeingDragged = false

        face.targetX = face.anchorX
        face.targetY = face.anchorY

        if(wasReleased) then
            self:sellDiceFace(face.representedObject, face, key)
        end
    end
    --Rewards
    for key,face in next,self.rewardsFacesUI do
        local wasReleased = face:releaseEvent()
        face.isBeingDragged = false

        if(
            (face.targetX > self.inventorySMTX and face.targetX < self.inventorySMTX + self.inventoryCanvasSmall:getWidth()) and
            (face.targetY > self.inventorySMTY and face.targetY < self.inventorySMTY + self.inventoryCanvasSmall:getHeight()) and
            (table.getn(self.run.facesInventory)< 8)
        ) then
            self:addRewardToInventory(face, key)
        else
            face.targetX = face.anchorX
            face.targetY = face.anchorY
        end

        if(wasReleased) then
            self:sellReward(face.representedObject, face, key)
        end
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

    --Ciggies
    for key,ciggie in next,self.availableCiggieObjectsUI do
        local wasReleased = ciggie:releaseEvent()
        ciggie.isBeingDragged = false

        ciggie.targetX = ciggie.anchorX
        ciggie.targetY = ciggie.anchorY

        if(wasReleased)then
            self:buyCiggie(ciggie.representedObject, ciggie, key)
        end
    end
end

function Shop:mousemoved(x, y, dx, dy, isDragging)
    --Drag and drop Ciggies

    if(isDragging == true)then 
        for key,ciggie in next, self.uiElements.ciggiesUI do
            if(ciggie.isDraggable and ciggie.isBeingClicked) then
                ciggie.isBeingDragged = true
                self.dragAndDroppedObject = ciggie
                ciggie.dragXspeed = dx
                ciggie.targetX = x
                ciggie.targetY = y
                break;
            end
        end
    end

    --Inventory
    if(isDragging == true)then 
        for key,face in next, self.inventoryFacesUI do
            if(face.isDraggable and face.isBeingClicked) then
                face.isBeingDragged = true
                self.dragAndDroppedObject = face
                face.dragXspeed = dx
                face.targetX = (face.targetX + dx)
                face.targetY = (face.targetY + dy)
                break;
            end
        end
    end

    --Rewards
    if(isDragging == true)then 
        for key,face in next, self.rewardsFacesUI do
            if(face.isDraggable and face.isBeingClicked) then
                face.isBeingDragged = true
                self.dragAndDroppedObject = face
                face.dragXspeed = dx
                face.targetX = (face.targetX + dx)
                face.targetY = (face.targetY + dy)
                break;
            end
        end
    end

    --Shop
    --Faces
    if(isDragging == true)then 
        for key,face in next, self.availableFaceObjectsUI do
            if(face.isDraggable and face.isBeingClicked) then
                face.isBeingDragged = true
                self.dragAndDroppedObject = face
                face.dragXspeed = dx
                face.targetX = (face.targetX + dx) 
                face.targetY = (face.targetY + dy)
                break;
            end
        end
    end

    if(isDragging == true)then 
        for key,ciggie in next, self.availableCiggieObjectsUI do
            if(ciggie.isDraggable and ciggie.isBeingClicked) then
                ciggie.isBeingDragged = true
                self.dragAndDroppedObject = ciggie
                ciggie.dragXspeed = dx
                ciggie.targetX = x 
                ciggie.targetY = y
                break;
            end
        end
    end

end

function Shop:keypressed(key)
    print(key)
end

--==Shop Functions==--
function Shop:buyDiceFace(face, faceUI, key)
    if(table.getn(self.run.facesInventory)<8 and self.run.money>=5)then

        --Remove the money
        self.run.money = self.run.money-5

        --Add face to inventory
        table.insert(self.run.facesInventory, face)

        --Remove faceUI from shop list
        table.remove(self.availableFaceObjectsUI, key)

        --Add FaceUI to inventory
        table.insert(self.inventoryFacesUI, faceUI)

        --Remove face from shop
        table.remove(self.availableFaceObjects, key)

        --Update the positions of the dices
        self:updateInventoryPositions()
    else
        print("no more space in iventory")
    end
end

function Shop:buyCiggie(ciggie, ciggieUI, key)
    if(table.getn(self.run.ciggiesObjects)<Constants.BASE_MAX_CIGGIES and self.run.money>=5)then
        self.run.money = self.run.money - 5
        --Add the ciggie to the inventory
        table.insert(self.run.ciggiesObjects, ciggie)
        --Remove the ciggie from the shop
        table.remove(self.availableCiggies, key)
        --Remove the ciggie from the shop UI
        table.remove(self.availableCiggieObjectsUI, key)

        --Regenerate the ciggies inventory
        self:generateCiggiesUI()
    else
        print("too much ciggies")
    end
end

function Shop:sellDiceFace(face, faceUI, key)
    --Add money to bank account
    self.run.money = self.run.money + 3

    --Remove dice face object from inventory

    table.remove(self.run.facesInventory, key)
    local apparitionDuration = 0.3

    --Remove dice face from ui with animation
    faceUI.animator:addGroup({
            --Rotation
            {property = "rotation", from = 0, targetValue = -2, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 0, targetValue = -2, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            --Scale
            {property = "baseTargetedScale", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack, onComplete = function()table.remove(self.inventoryFacesUI, key);self:updateInventoryPositions()end},
            
        })
    
end

function Shop:sellReward(face, faceUI, key)
    --Add money to bank account
    self.run.money = self.run.money + 3

    --Remove dice face object from inventory

    table.remove(self.run.facesRewardsInventory, key)
    local apparitionDuration = 0.3

    --Remove dice face from ui with animation
    faceUI.animator:addGroup({
            --Rotation
            {property = "rotation", from = 0, targetValue = -2, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 0, targetValue = -2, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            --Scale
            {property = "baseTargetedScale", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 1, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack, onComplete = function()table.remove(self.rewardsFacesUI, key);self:updateRewardsPositions()end},
            
        })
    
end

function Shop:sellCiggie(ciggie, ciggieUI, key)
    --Add money to bank account
    self.run.money = self.run.money+3
    print("-------")
    print("ciggies list")
    for k,m in next,self.run.ciggiesObjects do
        print(m.name)
    end
    
    --On retire l'objet de l'inventaire
    for j,c in next,self.run.ciggiesObjects do
        if(c==ciggie) then table.remove(self.run.ciggiesObjects, j)end
    end
    
    self:generateCiggiesUI()

end

--==Shop generation==--
function Shop:generateNewShop()
    --Generate the objects to buy
    self:generateAvailableFaces()
    self:generateAvailableCiggies()

    self.availableFaceObjectsUI = {}
    self.availableCiggieObjectsUI = {}
    --Generate the UI elements--
    --Faces
    for i,f in next,self.availableFaceObjects do
        local faceUI = DiceFace:new(
            nil,
            f,
            180*i + self.shopBGTX - 60,
            190,
            120,
            false,
            true,
            function() return Inputs.getMouseInCanvas(0, 0) end,
            nil
        )
        --Add them an anchor
        faceUI.anchorX = 180*i + self.shopBGTX - 60
        faceUI.anchorY = 190

        --Add an animation for their apparition
        local apparitionDuration = 0.3
        faceUI.animator:addGroup({
            --Rotation
            {property = "rotation", from = 3, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 3, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            --Scale
            {property = "baseTargetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            
        })

        

        table.insert(self.availableFaceObjectsUI, faceUI)
    end

    
    --Ciggies
    --Create the UI
    for i,c in next,self.availableCiggies do
        local ciggieUI = Ciggie:new(
            c,
            self.shopBGTX+(205+(1-i%2)*370),
            self.shopBGTY+(410+(math.floor(i/3))*60),
            false,
            true,
            function()return Inputs.getMouseInCanvas(0, 0)end,
            nil
        )
        --Set an anchor
        ciggieUI.anchorX = self.shopBGTX+(205+(1-i%2)*370)
        ciggieUI.anchorY = self.shopBGTY+(410+(math.floor(i/3))*60)
        --Insert in the table
        table.insert(self.availableCiggieObjectsUI, ciggieUI)
        
        --Add them an animation
        local apparitionDuration = 0.3
        ciggieUI.animator:addGroup({
            --Rotation
            {property = "rotation", from = 0.5, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 0.5, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            --Scale
            {property = "baseTargetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            
        })
    end


    self:createFacesPriceTags()
end

function Shop:generateAvailableFaces()
    self.availableFaceObjects = {}
    for i=1, 4 do
        local f = self:getRandomFaceObject()
        table.insert(self.availableFaceObjects, f)
    end
end

function Shop:generateAvailableCiggies()
    self.availableCiggies = {}
    for i=1, 4 do
        local c = self:generateRandomCiggie()
        table.insert(self.availableCiggies, c)
        print(c.name)
    end
end

--==UTILS==--
function Shop:getCurrentlyHoveredFace()
    self.currentlyHoveredFace = nil
    --Dice Net
    for i,face in next,self.infoFaces do
        if(face:isHovered() and self.currentlySelectedDice) then self.currentlyHoveredFace = face ; return end
    end
    --Shop faces
    for i,face in next,self.availableFaceObjectsUI do
        if(face:isHovered()) then self.currentlyHoveredFace = face ; return end
    end
    --Inventory Faces
    for i,face in next,self.inventoryFacesUI do
        if(face:isHovered()) then self.currentlyHoveredFace = face ; return end
    end
end

function Shop:getCurrentlyHoveredObject()
    if(self.currentlyHoveredFace) then
        return self.currentlyHoveredFace.representedObject
    elseif(self.currentlyHoveredCiggie)then
        return self.currentlyHoveredCiggie.representedObject
    else
        return nil
    end
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

    local randomFaceObject = randomFaceType:new(randomFaceValue, 10)

    return randomFaceObject 
end

function Shop:generateRandomCiggie()
    --Get the list of keys
    local keys = {}
    for key, _ in pairs(CiggieTypes) do
        table.insert(keys, key)
    end

    local randomCiggieKey = keys[math.random(#keys)]
    local randomCiggieType = CiggieTypes[randomCiggieKey] --On récupère une face type au hasard

    local randomCiggieObject = randomCiggieType:new()

    return randomCiggieObject
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
    local xPos = {20, 150, 280, 410, 20, 150, 280, 410}
    local yPos = {81, 81, 81, 81, 220, 220, 220, 220}

    for i,face in next,self.run.facesInventory do
        --Create the UIFaces

        local faceUI = DiceFace:new(
                nil,
                face,
                xPos[i] + 60+ self.inventorySMTX,
                yPos[i] + self.inventorySMTY + 60,
                120,
                false,
                true,
                function()return Inputs.getMouseInCanvas(0, 0)end,
                nil
            )

        faceUI.anchorX = xPos[i] + 60+ self.inventorySMTX
        faceUI.anchorY = yPos[i] + self.inventorySMTY + 60

        local apparitionDuration = 0.3
        faceUI.animator:addGroup({
            --Rotation
            {property = "rotation", from = 3, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 3, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            --Scale
            {property = "baseTargetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            
        })

        table.insert(self.inventoryFacesUI, faceUI)
    end
end

function Shop:createRewardFaces()
    local xPos = {45, 45}
    local yPos = {80, 220}

    for i,face in next,self.run.facesRewardsInventory do
        --Create the UIFaces

        local faceUI = DiceFace:new(
                nil,
                face,
                xPos[i] + 60+ self.rewardsSMTX,
                yPos[i] + self.rewardsSMTY + 60,
                120,
                false,
                true,
                function()return Inputs.getMouseInCanvas(0, 0)end,
                nil
            )

        faceUI.anchorX = xPos[i] + 60+ self.rewardsSMTX
        faceUI.anchorY = yPos[i] + self.rewardsSMTY + 60

        local apparitionDuration = 0.3
        faceUI.animator:addGroup({
            --Rotation
            {property = "rotation", from = 3, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 3, targetValue = 0, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            --Scale
            {property = "baseTargetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleX", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "scaleY", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = 0, targetValue = 1, duration = apparitionDuration, easing = AnimationUtils.Easing.easeOutBack},
            
        })

        table.insert(self.rewardsFacesUI, faceUI)
    end
end

function Shop:createFacesPriceTags()
    self.facesPriceTags = {}
    --Faces
    for i=1, 4 do
        local c = love.graphics.newCanvas(110, 40)
        love.graphics.setBlendMode( "alpha" )

        table.insert(self.facesPriceTags, c)
    end

    --Ciggies
    self.ciggiesPriceTags = {}
    for i=1, 4 do
        local c = love.graphics.newCanvas(110, 40)
        love.graphics.setBlendMode( "alpha" )

        table.insert(self.ciggiesPriceTags, c)
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

    for k,uiFace in next,self.rewardsFacesUI do
        uiFace:update(dt)
        uiFace:draw()
    end
end



function Shop:updateInventoryPositions()
    local xPos = {20, 150, 280, 410, 20, 150, 280, 410}
    local yPos = {81, 81, 81, 81, 220, 220, 220, 220}


    for i,uiFace in next,self.inventoryFacesUI do
        uiFace.anchorX = xPos[i] + 60+ self.inventorySMTX
        uiFace.anchorY = yPos[i] + self.inventorySMTY + 60
        uiFace.targetX = xPos[i] + 60+ self.inventorySMTX
        uiFace.targetY = yPos[i] + self.inventorySMTY + 60
    end
end

function Shop:updateRewardsPositions()
    local xPos = {45, 45}
    local yPos = {80, 220}


    for i,uiFace in next,self.rewardsFacesUI do
        uiFace.anchorX = xPos[i] + 60+ self.rewardsSMTX
        uiFace.anchorY = yPos[i] + self.rewardsSMTY + 60
        uiFace.targetX = xPos[i] + 60+ self.rewardsSMTX
        uiFace.targetY = yPos[i] + self.rewardsSMTY + 60
    end
end

function Shop:drawFacesPriceTags()
    local currentCanvas = love.graphics.getCanvas()
    for i,c in next,self.facesPriceTags do
        love.graphics.setCanvas(c)
        love.graphics.clear()
        --Background
        love.graphics.draw(Sprites.PRICE_TAG, 0, 0)
        --Text
        local priceText = love.graphics.newText(Fonts.soraPrice, '5€')

        love.graphics.setColor(232/255, 79/255, 79/255, 1)
        love.graphics.draw(priceText, c:getWidth()/2, c:getHeight()/2, 0, 1, 1, priceText:getWidth()/2, priceText:getHeight()/2)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setCanvas(currentCanvas)
        love.graphics.draw(c, 180*i + self.shopBGTX - 60, self.shopBGTY+200, 0, self.priceTagsScale, self.priceTagsScale, c:getWidth()/2, 0)
    end

    for i,c in next,self.ciggiesPriceTags do
        love.graphics.setCanvas(c)
        love.graphics.clear()
        --Background
        love.graphics.draw(Sprites.PRICE_TAG, 0, 0)
        --Text
        local priceText = love.graphics.newText(Fonts.soraPrice, '5€')

        love.graphics.setColor(232/255, 79/255, 79/255, 1)
        love.graphics.draw(priceText, c:getWidth()/2, c:getHeight()/2, 0, 1,1, priceText:getWidth()/2, priceText:getHeight()/2)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setCanvas(currentCanvas)
        love.graphics.draw(c, self.shopBGTX+(205+(1-i%2)*370), self.shopBGTY+(410+(math.floor(i/3))*60)-10, 0, self.priceTagsScale, self.priceTagsScale, c:getWidth()/2, 0)

    end
end

function Shop:addRewardToInventory(face, key)
    print("added", face.representedObject.name)

    --Supprimer la face de la liste des rewards
    table.remove(self.run.facesRewardsInventory, key)
    --Ajouter la face à l'inventaire de jeu
    table.insert(self.run.facesInventory, face.representedObject)
    --Supprimer la face UI des rewards
    table.remove(self.rewardsFacesUI, key)
    --Ajouter la face UI à l'inventaire
    table.insert(self.inventoryFacesUI, face)
    --Réorganiser les rewards
    self:updateRewardsPositions()

    --Réorganiser l'inventaire
    self:updateInventoryPositions()
end


--==Hover functions==--
function Shop:getCurrentlyHoveredCiggie()
    self.currentlyHoveredCiggie = nil
    --Inventaire
    for i,ciggie in next,self.uiElements.ciggiesUI do
        if(ciggie:isHovered())then
            self.currentlyHoveredCiggie = ciggie
            break
        end
    end
    --Shop
    for i,ciggie in next,self.availableCiggieObjectsUI do
        if(ciggie:isHovered())then
            self.currentlyHoveredCiggie = ciggie
            break
        end
    end
end

function Shop:outAnimation()
    local outDuration = 0.4

    --Out animation for inventory faces
    for i,face in next,self.inventoryFacesUI do
        face.animator:addGroup({
            {property="scaleX", from=face.scaleX, targetValue=0, duration = outDuration/2},
            {property="scaleY", from=face.scaleY, targetValue=0, duration = outDuration/2},
            {property = "baseTargetedScale", from = face.baseTargetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = face.targetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},

            --Rotation
            {property = "rotation", from = 0, targetValue = -1, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 0, targetValue = -1, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
        })
    end

    --Out animation for reward faces
    for i,face in next,self.rewardsFacesUI do
        face.animator:addGroup({
            {property="scaleX", from=face.scaleX, targetValue=0, duration = outDuration/2},
            {property="scaleY", from=face.scaleY, targetValue=0, duration = outDuration/2},
            {property = "baseTargetedScale", from = face.baseTargetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = face.targetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},

            --Rotation
            {property = "rotation", from = 0, targetValue = -1, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 0, targetValue = -1, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
        })
    end

    --Out animation of shop faces
    for i,face in next,self.availableFaceObjectsUI do
        face.animator:addGroup({
            {property="scaleX", from=face.scaleX, targetValue=0, duration = outDuration/2},
            {property="scaleY", from=face.scaleY, targetValue=0, duration = outDuration/2},
            {property = "baseTargetedScale", from = face.baseTargetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = face.targetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},

            --Rotation
            {property = "rotation", from = 0, targetValue = -1, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
            {property = "baseRotation", from = 0, targetValue = -1, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
        })
    end

    --Out animation for ciggies
    for i,face in next,self.availableCiggieObjectsUI do
        face.animator:addGroup({
            {property="scaleX", from=face.scaleX, targetValue=0, duration = outDuration/2},
            {property="scaleY", from=face.scaleY, targetValue=0, duration = outDuration/2},
            {property = "baseTargetedScale", from = face.baseTargetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
            {property = "targetedScale", from = face.targetedScale, targetValue = 0, duration = outDuration/2, easing = AnimationUtils.Easing.easeOutBack},
            })
    end

    self.animator:add("priceTagsScale", 1, 0, outDuration/4, AnimationUtils.Easing.easeOutBack)
    self.animator:addDelay(outDuration/2)
    
    --Remove the elements from the UI
    self.animator:addGroup({
        {property = "gridY", from = self.gridY, targetValue = -820, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "diceDetailsX", from = self.diceDetailsX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "descriptionX", from = self.descriptionX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        {property = "ciggiesTrayX", from = self.ciggiesTrayX, targetValue = self.canvas:getWidth()+420, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        
        {property = "shopBGY", from = self.shopBGY, targetValue = -1000, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        
        {property = "deckY", from = self.deckY, targetValue = self.canvas:getHeight()+20, duration = outDuration, easing = AnimationUtils.Easing.inCubic},
        
        {property = "moneyY", from = self.moneyY, targetValue = self.canvas:getHeight()+300, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "turnsX", from = self.turnsX, targetValue = -730, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rerollsX", from = self.rerollsX, targetValue = -500, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "floorY", from = self.floorY, targetValue = self.canvas:getHeight()+400, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},

        {property = "inventorySMY", from = self.inventorySMY, targetValue = self.canvas:getHeight()+600, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},
        {property = "rewardsSMY", from = self.rewardsSMY, targetValue = self.canvas:getHeight()+600, duration = outDuration, easing = AnimationUtils.Easing.inOutCubic},

    })
    self.animator:addDelay(0.5, function()self.run:goToDiceCustomization()end)

    --Buttons animation
    self.uiElements.buttons["menuButton"].animator:add('x', self.menuBtnX, -150, outDuration, AnimationUtils.Easing.inOutCubic)
    self.uiElements.buttons["planButton"].animator:add('x', self.planBtnX, -150, outDuration, AnimationUtils.Easing.inOutCubic)
    self.uiElements.buttons["nextRoundSmallBtn"].animator:add('x', self.uiElements.buttons["nextRoundSmallBtn"].x, self.canvas:getWidth()+400, outDuration, AnimationUtils.Easing.inOutCubic)
    self.uiElements.buttons["rerollShopButton"].animator:add('x', self.uiElements.buttons["rerollShopButton"].x, -400, outDuration, AnimationUtils.Easing.inOutCubic)

end

function Shop:isInList(diceList, targetDice)
    --Fonction pour vérifier qu'un élément est dans une liste
  for _, dice in ipairs(diceList) do
    if dice == targetDice then
      return true
    end
  end
  return false
end

return Shop