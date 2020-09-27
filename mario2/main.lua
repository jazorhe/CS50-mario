WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Class = require 'Class'
push = require 'push'

require 'Util'
require 'Map'

function love.load()

    map = Map()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

end



function love.update(dt)

    map:update(dt)

end

function love.resize(w, h)

    push:resize(w, h)

end

function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
    end

end


function love.draw()

    push:apply('start')

    love.graphics.translate(-map.camX, -map.camY)
    love.graphics.clear(108/255, 140/255, 1, 1)
    map:render()

    push:apply('end')

end
