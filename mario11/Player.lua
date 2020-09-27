Player = Class{}

require 'Animation'

MARIO_STANDING_SMALL = 43
MARIO_WALKING_SMALL = 44
MARIO_STOPPING_SMALL = 45
MARIO_RUNNING_SMALL = 46
MARIO_TURNING_SMALL = 47
MARIO_JUMPING_SMALL = 48
MARIO_DYING_SMALL = 49
MARIO_SITTING_SMALL = 50
MARIO_ROWING_SMALL = 51
MARIO_SWIMMING1_SMALL = 52
MARIO_SWIMMING2_SMALL = 53
MARIO_SWIMMING3_SMALL = 54
MARIO_SWIMMING4_SMALL = 55
MARIO_SWIMMING5_SMALL = 56

local MOVE_SPEED = 100
local JUMP_VELOCITY = 600
local GRAVITY = 40

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
                self.frames[MARIO_WALKING_SMALL], self.frames[MARIO_STOPPING_SMALL]
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

    self.y = self.y + self.dy * dt
    -- self:hitBox()

    if self.y > map.mapHeight * map.tileHeight then
        self:reset()
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

    love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x), math.floor(self.y), 0, scaleX, 1, offsetX, 0)

end


function Player:idle(dt)

    self.state = 'idle'

    if love.keyboard.wasPressed('space') then
        map.sounds['jump']:play()
        self.dy = - JUMP_VELOCITY
        self.state = 'jumping'

    elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self.direction = 'left'
        self.dx = - MOVE_SPEED
        self.state = 'walking'
        self:checkLeftCollision()

    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.direction = 'right'
        self.dx = MOVE_SPEED
        self.state = 'walking'
        self:checkRigthCollision()

    else
        self.dx = 0
        self.state = 'idle'

    end

    if not self:checkBottomCollision() then
        self.state = 'jumping'
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
        self.dx = - MOVE_SPEED
        self:checkLeftCollision()

    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.direction = 'right'
        self.dx = MOVE_SPEED
        self:checkRigthCollision()

    end

    self.dy = self.dy + GRAVITY

    self:checkTopCollision()
    if self:checkBottomCollision() then
        self.state = 'idle'
    end

    self.animation = self.animations[self.state]

end

function Player:checkTopCollision()

    if self.dy < 0 then

        if map:tileAt(self.x, self.y).id ~= TILE_EMPTY or
        map:tileAt(self.x + self.width + 1, self.y).id ~= TILE_EMPTY then
            self.dy = 0

            if map:tileAt(self.x, self.y).id  == TILE_QUESTION_NORMAL then
                map.sounds['coin']:play()
                map:setTile(math.floor(self.x / map.tileWidth) + 1,
                math.floor(self.y / map.tileHeight) + 1, TILE_QUESTION_USED)
            end

            if map:tileAt(self.x + self.width - 1, self.y).id  == TILE_QUESTION_NORMAL then
                map.sounds['coin']:play()
                map:setTile(math.floor((self.x + self.width -1) / map.tileWidth) + 1,
                math.floor(self.y / map.tileHeight) + 1, TILE_QUESTION_USED)
            end
        end

    end

end


function Player:checkLeftCollision()

    if self.dx < 0 then
        if map:collides(map:tileAt(self.x - self.width, self.y)) or
        map:collides(map:tileAt(self.x - self.width, self.y - self.height)) then
            map.sounds['hit']:play()
            self.x = math.max((map:tileAt(self.x, self.y).x - 1) * map.tileWidth, self.x - 3)
            self.dx = 0
            return true
        end
    end
end


function Player:checkRigthCollision()

    if self.dx > 0 then
        if map:collides(map:tileAt(self.x + self.width, self.y)) or
        map:collides(map:tileAt(self.x + self.width, self.y - self.height)) then
            map.sounds['hit']:play()
            self.x = math.min((map:tileAt(self.x, self.y).x - 1) * map.tileWidth, self.x + 3)
            self.dx = 0
            return true
        end
    end
end

function Player:checkBottomCollision()

    -- if self.dy >= 0 then
    --     if map:collides(map:tileAt(self.x, self.y + self.height)) or
    --     map:collides(map:tileAt(self.x + self.width + 1, self.y + self.height)) then
    --         self.y = (map:tileAt(self.x, self.y).y - 1) * map.tileHeight
    --         self.dy = 0
    --         return true
    --     end
    -- end

    if self.dy >= 0 then
        if map:collides(map:tileAt(self.x, self.y + self.height)) then
            self.y = (map:tileAt(self.x, self.y).y - 1) * map.tileHeight
            self.dy = 0
            return true
        end
    end

end

function Player:reset()

    self.x = INITIAL_X
    self.y = INITIAL_Y
    self.dx = 0
    self.dy = 0
    self.state = 'idle'
    self.animation = self.animations[self.state]

end
