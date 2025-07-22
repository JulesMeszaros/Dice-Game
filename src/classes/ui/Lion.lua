local Lion = {}
Lion.__index = Lion

function Lion:new()
    local self = setmetatable({}, Lion)

    self.canvas = love.graphics.newCanvas(500, 500)

    --Default indexes for the different parts of the body
    self.backgroundIndex = 1
    self.crownOneIndex = 1
    self.crownTwoIndex = 1
    self.eyesIndex = 1
    self.headIndex = 1
    self.mouthIndex = 1
    self.noseIndex = 1
    self.shouldersIndex = 1

    self:generateRandomLion()
    return self
end

function Lion:update(dt)
    local currentCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    love.graphics.rectangle("fill", 0, 0, self.canvas:getWidth(), self.canvas:getHeight())

    --drawing the images one by one
    love.graphics.draw(self.backgroundImage, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.backgroundImage:getWidth()/2, self.backgroundImage:getHeight()/2)
    love.graphics.draw(self.shouldersImage, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.shouldersImage:getWidth()/2, self.shouldersImage:getHeight()/2)
    love.graphics.draw(self.crownOneImage, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.crownOneImage:getWidth()/2, self.crownOneImage:getHeight()/2)
    love.graphics.draw(self.crownTwoImage, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.crownTwoImage:getWidth()/2, self.crownTwoImage:getHeight()/2)
    love.graphics.draw(self.headImage, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.headImage:getWidth()/2, self.headImage:getHeight()/2)
    love.graphics.draw(self.eyesImage, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.eyesImage:getWidth()/2, self.eyesImage:getHeight()/2)
    love.graphics.draw(self.mouthImage, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.mouthImage:getWidth()/2, self.mouthImage:getHeight()/2)
    love.graphics.draw(self.noseImage, self.canvas:getWidth()/2, self.canvas:getHeight()/2, 0, 1, 1, self.noseImage:getWidth()/2, self.noseImage:getHeight()/2)

    love.graphics.setCanvas(currentCanvas)
end

function Lion:draw(x, y)
    love.graphics.draw(self.canvas, x, y, 0, 1/4, 1/4, self.canvas:getWidth()/2, self.canvas:getHeight()/2)
end

function Lion:generateRandomLion()
    local maxIndex = 10
    --Creating the indexes
    self.backgroundIndex = math.random(1, countFilesInFolder("src/assets/lion/background/"))
    self.crownOneIndex = math.random(1, countFilesInFolder("src/assets/lion/crownone/"))
    self.crownTwoIndex = math.random(1, countFilesInFolder("src/assets/lion/crowntwo/"))
    self.eyesIndex = math.random(1, countFilesInFolder("src/assets/lion/eyes/"))
    self.headIndex = math.random(1, countFilesInFolder("src/assets/lion/head/"))
    self.mouthIndex = math.random(1, countFilesInFolder("src/assets/lion/mouth/"))
    self.noseIndex = math.random(1, countFilesInFolder("src/assets/lion/nose/"))
    self.shouldersIndex = math.random(1, countFilesInFolder("src/assets/lion/shoulders/"))
    --Importing the images
    self.backgroundImage = love.graphics.newImage("src/assets/lion/background/background"..tostring(self.backgroundIndex)..".png")
    self.crownOneImage = love.graphics.newImage("src/assets/lion/crownone/crownone"..tostring(self.crownOneIndex)..".png")
    self.crownTwoImage = love.graphics.newImage("src/assets/lion/crowntwo/crowntwo"..tostring(self.crownTwoIndex)..".png")
    self.eyesImage = love.graphics.newImage("src/assets/lion/eyes/eyes"..tostring(self.eyesIndex)..".png")
    self.headImage = love.graphics.newImage("src/assets/lion/head/head"..tostring(self.headIndex)..".png")
    self.mouthImage = love.graphics.newImage("src/assets/lion/mouth/mouth"..tostring(self.mouthIndex)..".png")
    self.noseImage = love.graphics.newImage("src/assets/lion/nose/nose"..tostring(self.noseIndex)..".png")
    self.shouldersImage = love.graphics.newImage("src/assets/lion/shoulders/shoulders"..tostring(self.shouldersIndex)..".png")
end

function countFilesInFolder(folder)
    local files = love.filesystem.getDirectoryItems(folder)
    local count = 0

    for _, file in ipairs(files) do
        local path = folder .. "/" .. file
        if love.filesystem.getInfo(path, "file") then
            count = count + 1
        end
    end

    return count
end

return Lion