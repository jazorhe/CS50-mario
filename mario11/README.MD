### Mario0: Tile Maps
-   Tile Map: cannot find CS50 original tilemap, so I found this online: [NES - Super Mario Bros. - The Spriters Resource](https://www.spriters-resource.com/nes/supermariobros/)

-   Sprite sheet
    -   Texture loaded into the game, can possiby be made into a table and access individual when needed
    -   tileWidth: can be thought as the quad / block width
    -   tileHeight: can be thought as the quad / block height
    -   mapWidth: how many blocks can fit into the virtual screen width
    -   mapHeight: how many blocks can fit into the virtual screen height
    -   tiles: tile table that is mapped and stored to be drawn later
    -   e.g.

    ```lua
    tiles = {
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        1, 1, 1, 1, 1,
        1, 1, 1, 1, 1,
    }
    ```

-   Quad
    -   Rectangles within the sprite sheet that has been devided into smaller blocks
    -   i.e. all texture materials stored in linear array in block format
    -   e.g. below image being transformed in to a table with length of 33 x 28 = 924 blocks of 16 x 16 pixel quad
    -   with their individual indexes, we can assign each quad to a position on tiles to be drawn onto screen
    -   Utility Class: For functions like generateQuads(), it is best to create a separate class for them

    ```
    TILE_BRICK_TOP       = 2
    TILE_BRICK_INNER     = 3
    TILE_QUESTION_NORMAL = 25
    TILE_QUESTION_USED   = 28
    TILE_EMPTY           = 330
    ```

**Environment Sprite Sheet**

<img src="img/environment-sprite.png" width="700">

-   GenerateQuads

    ```lua
    function generateQuads(atlas, tileWidth, tileHeight)

        local sheetWidth  = atlas:getWidth() / tileWidth
        local sheetHeight = atlas:getHeight() / tileHeight

        local sheetCounter = 1
        local quads = {}

        for y = 0, sheetHeight - 1 do
            for x = 0, sheetWidth - 1 do
                quads[sheetCounter] = love.graphics.newQuad(x * tileWidth, y * tileHeight,
                    tileWidth, tileHeight, atlas:getDimensions())
                sheetCounter = sheetCounter + 1
            end
        end

        return quads

    end
    ```


-   `love.graphics.draw( texture, quad, x, y, r, sx, sy, ox, oy, kx, ky )
`

    ```lua
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
    ```

**Hereby achived tile mapping:**

<img src="img/tile-map.png" width="700">
