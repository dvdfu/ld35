math.randomseed(os.time())
love.graphics.setDefaultFilter('nearest', 'nearest')
love.graphics.setLineStyle('rough')

require('global')
Input = require('input')

local Game = require('game')
local game = nil
local canvas = nil

function love.load()
    canvas = love.graphics.newCanvas(Screen.fakeW, Screen.fakeH)
    game = Game:new()
end

function love.update(dt)
    game:update(dt)
    if Input.pressed('escape') then
        love.event.quit()
    end
    Input.update()
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.push()
    love.graphics.translate(Screen.offsetX, Screen.offsetY)
    -- love.graphics.rectangle('line', 1, 1, Screen.targetW - 1, Screen.targetH - 1)

    game:draw()

    love.graphics.pop()
    love.graphics.setCanvas()
    love.graphics.scale(Screen.scale)
    love.graphics.draw(canvas)
end
