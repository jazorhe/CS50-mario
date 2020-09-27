Player = Class{}

MARIO_STANDING_SMALL = 43


function Player:init(map)

    self.width = 16
    self.height = 16

    self.x = map.tileWidth * 5
    self.y = map.tileHeight * (map.mapHeight / 2 - 1 ) - self.height

    self.texture = love.graphics.newImage('graphics/mario-pixel.png')
    self.frames = generateQuads(self.texture, self.width, self.height)

end


function Player:update(dt)


end



function Player:render()

    love.graphics.draw(self.texture, self.frames[MARIO_STANDING_SMALL], self.x, self.y)

end
