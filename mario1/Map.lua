require 'Util'
Map = Class{}

TILE_BRICK_TOP       = 2
TILE_BRICK_INNER     = 3
TILE_QUESTION_NORMAL = 25
TILE_QUESTION_USED   = 28
TILE_EMPTY           = 330

local SCROLL_SPEED = 62

function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/tiles.png')
    self.tileWidth   = 16   --  can be thought as the quad / block width
    self.tileHeight  = 16   --  can be thought as the quad / block height
    self.mapWidth    = 28   --  how many blocks can fit into the virtual screen width
    self.mapHeight   = 17   --  how many blocks can fit into the virtual screen height
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

    -- save empty block locations into tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do 
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- save brick top block locations into tiles
    y = 14
    for x = 1, self.mapWidth do 
        self:setTile(x, y, TILE_BRICK_TOP)
    end

    -- save brick inner block locations into tiles
    for y = 15, self.mapHeight do
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

    self.camX = self.camX + SCROLL_SPEED * dt

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