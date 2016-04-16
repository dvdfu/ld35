local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')

local Ball = Class('Ball')
Ball.SIZE = 16

local sprites = {
    spinning = love.graphics.newImage('res/images/baseball.png')
}

function Ball:initialize(x, y)
    self.x = x
    self.y = y

    local grid = Anim8.newGrid(Ball.SIZE, Ball.SIZE, Ball.SIZE * 6, Ball.SIZE)
    self.animation = Anim8.newAnimation(grid:getFrames('1-6', 1), 0.05)
    self.sprite = sprites.spinning
end

function Ball:update(dt)
    self.animation:update(dt)
end

function Ball:draw()
    self.animation:draw(self.sprite, self.x, self.y, 0, 1, 1, Ball.SIZE / 2, Ball.SIZE / 2)
end

return Ball
