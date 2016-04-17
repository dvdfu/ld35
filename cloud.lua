local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
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
    self.z = 1 + 2 * math.random()
    self.type = math.random(1, 3)
    self.player = player
    self.body = HC.rectangle(self.pos.x - 80, self.pos.y - 24, 160, 48)
    self.dead = false
end

function Cloud:update(dt)
    self.pos = self.pos - self.player.vel / 2 * self.z
    self.body:moveTo(self.pos:unpack())
    if self.pos.x + 120 < 0 or self.pos.y - 80 > Screen.targetH then
        self.dead = true
    end
end

function Cloud:draw()
    love.graphics.draw(sprites.forms[self.type], self.pos.x, self.pos.y, 0, self.z / 3, self.z / 3, 120, 40)
end

return Cloud
