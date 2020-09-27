require 'Util'
Map = Class{}

TILE_BRICK_TOP       = 2
TILE_BRICK_INNER     = 3
TILE_QUESTION_NORMAL = 25
TILE_QUESTION_USED   = 28
TILE_EMPTY           = 330


local SCROLLING    = 'keyboard'
local SCROLL_SPEED = 62

function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/tiles.png')
    self.tileWidth   = 16   --  can be thought as the quad / block width
    self.tileHeight  = 16   --  can be thought as the quad / block height
    self.mapWidth    = 28   --  how many blocks can fit into the virtual screen width
    self.mapHeight   = 28   --  how many blocks can fit into the virtual screen height
    self.tiles = {}         --  tile table that is mapped and stored to be drawn later

    -- e.g.
    -- tiles = {
    --     0, 0, 0, 0, 0,
    --     0, 0, 0, 0, 0,
    --     1, 1, 1, 1, 1,
    --     1, 1, 1, 1, 1,
    -- }

    self.camX = 0
    self.camY = 0

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight


    -- save empty block locations into tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do 
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- save brick top block locations into tiles
    y = self.mapHeight / 2
    for x = 1, self.mapWidth do 
        self:setTile(x, y, TILE_BRICK_TOP)
    end

    -- save brick inner block locations into tiles
    for y = self.mapHeight / 2 + 1, self.mapHeight do
        for x = 1, self.mapWidth do 
            self:setTile(x, y, TILE_BRICK_INNER)
        end   
    end

    -- save a single test block into tiles
    -- self:setTile(1, 1, TILE_QUESTION_NORMAL)

end

function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end


function Map:update(dt)

    if SCROLLING == 'keyboard' then
        self:keyboardScroll(dt)
    elseif SCROLLING == 'auto' then
        self:autoScroll(dt)
    end

end

function Map:keyboardScroll(dt)

    if love.keyboard.isDown('w') then
        -- up movements
        self.camY = math.floor(self.camY - SCROLL_SPEED * dt)
        self.camY = math.max(0, self.camY)

    elseif love.keyboard.isDown('a') then
        -- left movements
        self.camX = math.floor(self.camX - SCROLL_SPEED * dt)
        self.camX = math.max(0, self.camX)

    elseif love.keyboard.isDown('s') then
        -- down movements
        self.camY = math.floor(self.camY + SCROLL_SPEED * dt)
        self.camY = math.min(self.mapHeightPixels - VIRTUAL_HEIGHT, self.camY)

    elseif love.keyboard.isDown('d') then
        -- right movements
        self.camX = math.floor(self.camX + SCROLL_SPEED * dt)
        self.camX = math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.camX)

    end

end

function Map:autoScroll(dt)

    self.camX = math.floor(self.camX + SCROLL_SPEED * dt)
    self.camX = math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.camX)

end


function Map:render()

    -- get each tile from tiles and draw at pixel location
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do 
            -- spritesheet: texture material in png, has imagery infomation
            -- titleSprites: quads that we generated, has quad to spritesheet relationship with quad index
            -- getTile: from tiles get corresponding quad for specific locaiton, has location and quad index infoamtion
            -- x and y in virtual location
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)],
                (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end

end