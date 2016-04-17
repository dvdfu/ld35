local Class = require('modules/middleclass/middleclass')
local Vector = require('modules/hump/vector')

local Cloud = Class('Cloud')
Cloud:include(Stateful)

local sprites = {
    forms = {
        love.graphics.newImage('res/images/cloud_1.png'),
        love.graphics.newImage('res/images/cloud_2.png'),
        love.graphics.newImage('res/images/cloud_3.png')
    }
}

function Cloud:initialize(x, y, player)
    self.pos = Vector(x, y)
    self.type = math.random(1, 3)
    self.player = player
end

function Cloud:update(dt)
    self.pos = self.pos - self.player.vel / 8
end

function Cloud:draw()
    love.graphics.draw(sprites.forms[self.type], self.pos.x, self.pos.y, 0, 1, 1, 120, 40)
end

return Cloud
