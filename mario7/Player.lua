Player = Class{}

require 'Animation'

MARIO_STANDING_SMALL  = 43
MARIO_WALKING_SMALL   = 44
MARIO_STOPPING_SMALL  = 45
MARIO_RUNNING_SMALL   = 46
MARIO_TURNING_SMALL   = 47
MARIO_JUMPING_SMALL   = 48
MARIO_DYING_SMALL     = 49
MARIO_SITTING_SMALL   = 50
MARIO_ROWING_SMALL    = 51
MARIO_SWIMMING1_SMALL = 52
MARIO_SWIMMING2_SMALL = 53
MARIO_SWIMMING3_SMALL = 54
MARIO_SWIMMING4_SMALL = 55
MARIO_SWIMMING5_SMALL = 56

local MOVE_SPEED      = 100
local JUMP_VELOCITY   = 400
local GRAVITY         = 40

function Player:init(map)

    self.width = 16
    self.height = 16

    INITIAL_X = map.tileWidth * 5
    GROUND_PIXEL_HEIGHT = map.tileHeight * (GROUND_TILE_HEIGHT - 1 )
    INITIAL_Y = GROUND_PIXEL_HEIGHT - self.height

    self.x = INITIAL_X
    self.y = INITIAL_Y

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
        },
        ['jumping'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[MARIO_JUMPING_SMALL]
            },
            interval = 1
        }
    }

    self.animation = self.animations['idle']

    self.behaviours = {
        ['idle'] = function (dt)
            self:idle(dt)
        end,
        ['walking'] = function(dt)
            self:walking(dt)
        end,
        ['jumping'] = function (dt)
            self:jumping(dt)
        end
    }

end


function Player:update(dt)

    self.behaviours[self.state](dt)
    self.animation:update(dt)

    self.x = math.max(0,
        math.min(self.x + self.dx * dt, map.mapWidth * map.tileWidth - self.width))

    self.y = self.y + self.dy *dt


end

function Player:idle(dt)

    self.state = 'walking'

    if love.keyboard.wasPressed('space') then
        self.dy = - JUMP_VELOCITY
        self.state = 'jumping'

    elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self.direction = 'left'
        self.dx =  - MOVE_SPEED

    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.direction = 'right'
        self.dx = MOVE_SPEED

    else
        self.dx = 0
        self.state = 'idle'

    end

    self.animation = self.animations[self.state]

end

function Player:walking(dt)

    self:idle(dt)

end

function Player:jumping(dt)

    self.state = 'jumping'

    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self.direction = 'left'
        self.dx =  - MOVE_SPEED

    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.direction = 'right'
        self.dx = MOVE_SPEED

    end

    self.dy = self.dy + GRAVITY

    if self.y >= INITIAL_Y then
        self.y = INITIAL_Y
        self.dy = 0
        self.state = 'idle'

    end

    self.animation = self.animations[self.state]

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
