require 'Util'
require 'Player'
Map = Class{}

TILE_BRICK_TOP       = 2
TILE_BRICK_INNER     = 3
TILE_QUESTION_NORMAL = 25
TILE_QUESTION_USED   = 28
TILE_EMPTY           = 330

CLOUD_TOP_LEFT       = 727
CLOUD_TOP_CENTER     = 728
CLOUD_TOP_RIGHT      = 729
CLOUD_BOTTOM_LEFT    = 760
CLOUD_BOTTOM_CENTER  = 761
CLOUD_BOTTOM_RIGHT   = 762

GRASS_LEFT           = 309
GRASS_CENTER         = 310
GRASS_RIGHT          = 311

PIPE_TOP_LEFT        = 265
PIPE_TOP_RIGHT       = 266
PIPE_BOTTOM_LEFT     = 298
PIPE_BOTTOM_RIGHT    = 299

STAIR_TILE           = 34
FLAG_POLE            = 314
FLAG_TOP             = 281

local SCROLLING      = 'player'
-- local SCROLLING      = 'keyboard'
local SCROLL_SPEED   = 200

function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/tiles.png')
    self.items       = love.graphics.newImage('graphics/items.png')
    self.tileWidth   = 16   --  can be thought as the quad / block width
    self.tileHeight  = 16   --  can be thought as the quad / block height
    self.mapWidth    = 70   --  how many blocks can fit into the virtual screen width
    self.mapHeight   = 28   --  how many blocks can fit into the virtual screen height
    self.tiles = {}         --  tile table that is mapped and stored to be drawn later

    self.music = love.audio.newSource(('sounds/beneath-the-mask.mp3'), 'static')
    self.sounds = {
        ['jump'] = love.audio.newSource(('sounds/jump.wav'), 'static'),
        ['hit'] = love.audio.newSource(('sounds/hit.wav'), 'static'),
        ['coin'] = love.audio.newSource(('sounds/coin.wav'), 'static')
    }

    GROUND_TILE_HEIGHT    = self.mapHeight / 2
    FINISH_TILES_WIDTH    = 20

    -- e.g.
    -- tiles = {
    --     0, 0, 0, 0, 0,
    --     0, 0, 0, 0, 0,
    --     1, 1, 1, 1, 1,
    --     1, 1, 1, 1, 1,
    -- }

    self.player = Player(self)

    self.camX = 0
    self.camY = 0

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    self:generateMap()
    self.music:setLooping(true)
    self.music:setVolume(0.25)
    self.music:play()

end

function Map:update(dt)

    if SCROLLING == 'keyboard' then
        self:keyboardScroll(dt)
    elseif SCROLLING == 'auto' then
        self:autoScroll(dt)
    elseif SCROLLING == 'player' then
        self:playerFollowScroll(dt)
    end

    self:checkWinGame()

end

function Map:playerFollowScroll(dt)

    self.camX = math.max(0,
        math.min(self.player.x - VIRTUAL_WIDTH / 2,
            math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))

    -- Keep camera from going across to the right end of map minus virtual width
    -- Keep player at 1/2 of the screen
    -- Keep camera from going across to the left end of the map

    self.player:update(dt)

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

    if self:checkWinGame() then
        love.graphics.printf("You have reached the goal!", self.camX, VIRTUAL_HEIGHT / 2, self.camX + VIRTUAL_WIDTH, 'center')
        map.sounds['coin']:play()
    end

    self.player:render()

end


function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end


function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:generateMap()

    -- save empty block locations into tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- save brick top block locations into tiles
    y = GROUND_TILE_HEIGHT
    for x = 1, self.mapWidth do
        self:setTile(x, y, TILE_BRICK_TOP)
    end

    -- save brick inner block locations into tiles
    for y = GROUND_TILE_HEIGHT + 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_BRICK_INNER)
        end
    end

    local x = 1
    while x < self.mapWidth - FINISH_TILES_WIDTH do

        -- auto generate gap
        if x < self.mapWidth - 10 and x > 6 then
            -- this is a  1/15 chance
            if math.random(10) == 1 then
                self:setGapTiles(x)
            end
        end
        x = x + 1
    end

    x = 1
    while x < self.mapWidth - FINISH_TILES_WIDTH do

        -- auto generate clouds
        if x < self.mapWidth - 3 then
            -- this is a 10 percent chance
            if math.random(10) == 1 then
                self:setCloudTiles(x)
            end
        end


        -- auto generate grass
        if x < self.mapWidth - 3 and x > 6 then
            -- this is a  1/15 chance
            if math.random(15) == 1 then
                self:setGrassTiles(x)
            end
        end


        -- auto generate pipes
        if x < self.mapWidth - 3 and x > 6 then
            -- this is a  1/15 chance
            if math.random(12) == 1 then
                self:setPipeTiles(x)
            end
        end

        -- auto generate question blocks
        if x < self.mapWidth - 3 and x > 6 then
            -- this is a  1/15 chance
            if math.random(10) == 1 then
                self:setQuestionTiles(x)
            end
        end

        x = x + 1
    end

    self:setFinishTiles()

end

function Map:setGrassTiles(x)

    local y = GROUND_TILE_HEIGHT - 1

    if self:getTile(x, y) == TILE_EMPTY
    and self:getTile(x,     y + 1) == TILE_BRICK_TOP
    and self:getTile(x + 1, y + 1) == TILE_BRICK_TOP
    and self:getTile(x + 2, y + 1) == TILE_BRICK_TOP then

        self:setTile(x,     y, GRASS_LEFT)
        self:setTile(x + 1, y, GRASS_CENTER)
        self:setTile(x + 2, y, GRASS_RIGHT)

    end

end

function Map:setCloudTiles(x)

    local y = math.random(GROUND_TILE_HEIGHT - 6)

    if self:getTile(x, y) == TILE_EMPTY then

        self:setTile(x,     y, CLOUD_TOP_LEFT)
        self:setTile(x + 1, y, CLOUD_TOP_CENTER)
        self:setTile(x + 2, y, CLOUD_TOP_RIGHT)
        self:setTile(x,     y + 1, CLOUD_BOTTOM_LEFT)
        self:setTile(x + 1, y + 1, CLOUD_BOTTOM_CENTER)
        self:setTile(x + 2, y + 1, CLOUD_BOTTOM_RIGHT)

    end

end

function Map:setPipeTiles(x)

    local y = GROUND_TILE_HEIGHT - 2

    if self:getTile(x, y) == TILE_EMPTY
    and self:getTile(x,     y + 2) == TILE_BRICK_TOP
    and self:getTile(x + 1, y + 2) == TILE_BRICK_TOP then

        self:setTile(x,     y,     PIPE_TOP_LEFT)
        self:setTile(x + 1, y,     PIPE_TOP_RIGHT)
        self:setTile(x,     y + 1, PIPE_BOTTOM_LEFT)
        self:setTile(x + 1, y + 1, PIPE_BOTTOM_RIGHT)

    end

end

function Map:setGapTiles(x)

    -- save empty block locations into tiles
    for y = 1, self.mapHeight do
        for gapX = x, x + math.random(4) do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

end

function Map:setQuestionTiles(x)

    y = GROUND_TILE_HEIGHT - 3

    if self:getTile(x, y) == TILE_EMPTY then

        self:setTile(x, y, TILE_QUESTION_NORMAL)

    end

end


function Map:tileAt(x, y)

    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }

end

function Map:collides(tile)

    local collidables = {
        TILE_BRICK_TOP, TILE_BRICK_INNER, TILE_QUESTION_NORMAL, TILE_QUESTION_USED, PIPE_TOP_LEFT, PIPE_TOP_RIGHT, PIPE_BOTTOM_LEFT, PIPE_BOTTOM_RIGHT, STAIR_TILE
    }
    -- FLAG_POLE, FLAG_TOP
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end
end




function Map:setFinishTiles(x)

    local i = 0
    local j = 10
    local tempY = GROUND_TILE_HEIGHT - 1
    local tempX = self.mapWidth

    for y = GROUND_TILE_HEIGHT - 11, GROUND_TILE_HEIGHT - 1 do
        i = 0
        tempX = self.mapWidth
        for x = self.mapWidth - FINISH_TILES_WIDTH, self.mapWidth do
            -- self:setTile(x, y, TILE_EMPTY)

            if i >= j + 3 and i < 9 then
                self:setTile(x, y, STAIR_TILE)
            end

            if i == 12 and j < 8 then
                self:setTile(x, y, FLAG_POLE)
            end

            if i == 12 and j == 8 then
                self:setTile(x, y, FLAG_TOP)
            end

            i = i + 1
            tempX = tempX - 1

        end
        j = j - 1
        tempY = tempY - 1
    end

end


function Map:checkWinGame()
    -- TODO
    if map:tileAt(self.player.x, self.player.y).id  == FLAG_TOP
    or  map:tileAt(self.player.x, self.player.y).id  == FLAG_POLE
    or  map:tileAt(self.player.x + 1, self.player.y).id  == FLAG_POLE
    or  map:tileAt(self.player.x - 1, self.player.y).id  == FLAG_POLE then
        return true
    end
end
