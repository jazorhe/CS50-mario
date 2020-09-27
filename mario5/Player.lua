Player = Class{}

require 'Animation'

MARIO_STANDING_SMALL  = 43
MARIO_WALKING_SMALL   = 44
MARIO_STOPPING_SMALL  = 45
MARIO_RUNNING_SMALL   = 46
MARIO_TURNING_SMALL   = 47
MARIO_DYING_SMALL     = 48
MARIO_SITTING_SMALL   = 49
MARIO_ROWING_SMALL    = 50
MARIO_SWIMMING1_SMALL = 51
MARIO_SWIMMING2_SMALL = 52
MARIO_SWIMMING3_SMALL = 53
MARIO_SWIMMING4_SMALL = 54
MARIO_SWIMMING5_SMALL = 55

local MOVE_SPEED = 80

function Player:init(map)

    self.width = 16
    self.height = 16

    self.x = map.tileWidth * 5
    self.y = map.tileHeight * (map.mapHeight / 2 - 1 ) - self.height

    self.texture = love.graphics.newImage('graphics/mario-pixel.png')
    self.frames = generateQuads(self.texture, self.width, self.height)

    self.dx = 0
    self.dy = 0

    self.state = 'idle'
    self.direction = 'right'

    self.animations = {
        ['idle'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[MARIO_STANDING_SMALL]
            },
            interval = 1
        },
        ['walking'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[MARIO_WALKING_SMALL],                                 self.frames[MARIO_STOPPING_SMALL]
            },
            interval = 0.15
        }
    }

    self.animation = self.animations['idle']

    self.behaviours = {
        ['idle'] = function (dt)
            self:move(dt)
        end,
        ['walking'] = function(dt)
            self:move(dt)
        end
    }

end


function Player:update(dt)

    self.behaviours[self.state](dt)
    self.animation:update(dt)

end

function Player:move(dt)

    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self.dx =  - MOVE_SPEED
        self.x = math.max(0, self.x + self.dx * dt)
        self.animation = self.animations['walking']
        self.state = 'walking'
        self.direction = 'left'

    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.dx = MOVE_SPEED
        self.x = math.min(self.x + self.dx * dt, map.mapWidth * map.tileWidth - self.width)
        self.animation = self.animations['walking']
        self.state = 'walking'
        self.direction = 'right'

    else
        self.animation = self.animations['idle']
        self.state = 'idle'

    end


end

function Player:render()

    local scaleX
    local offsetX

    if self.direction == 'left' then
        scaleX = -1
        offsetX = self.width

    else
        scaleX = 1
        offsetX = 0

    end

    love.graphics.draw(self.texture, self.animation:getCurrentFrame(),      math.floor(self.x), math.floor(self.y), 0, scaleX, 1, offsetX, 0)

end
