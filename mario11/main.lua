WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Class = require 'Class'
push = require 'push'

require 'Util'
require 'Map'

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Try To Be Mario')
    math.randomseed(os.time())
    map = Map()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    love.keyboard.keysPressed = {}

end


function love.update(dt)

    map:update(dt)

    love.keyboard.keysPressed = {}

end


function love.draw()

    push:apply('start')

    love.graphics.translate(-map.camX, -map.camY)
    love.graphics.clear(108/255, 140/255, 1, 1)
    map:render()

    push:apply('end')

end

function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true

    if key == 'r' then
        map.player:reset()
    end

end

function love.keyboard.wasPressed(key)

    return love.keyboard.keysPressed[key]

end

function love.resize(w, h)

    push:resize(w, h)

end
