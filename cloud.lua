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

function Cloud:initialize(x, y, lowZ, highZ, player, camera)
    self.pos = Vector(x, y)
    self.z = math.random(lowZ, highZ)
    self.type = math.random(1, 3)
    self.player = player
    self.camera = camera
    self.body = HC.rectangle(self.pos.x - 80, self.pos.y - 24, 160, 48)
    self.body:scale(self.z / 3)
    self.dead = false
end

function Cloud:update(dt)
    self.body:moveTo(self.pos:unpack())

    if self.z == 3 then
        local collides, dx, dy = self.body:collidesWith(self.player.body)
        if collides then
            Particles.get('cloud'):setDirection(self.player.vel:angleTo(Vector(-1, 0)))
            Particles.emit('cloud', 0, 0, 1)
        end
    end

    x, _ = self.camera:toScreenCoordinates(self.pos:unpack())
    if x + 120 < 0 then
        self.dead = true
    end
end

function Cloud:draw()
    if self.z == 1 then
        love.graphics.setColor(210, 220, 230)
    elseif self.z == 2 then
        love.graphics.setColor(220, 230, 240)
    end

    love.graphics.draw(sprites.forms[self.type], self.pos.x, self.pos.y, 0, self.z / 3, self.z / 3, 120, 40)
    love.graphics.setColor(255, 255, 255)
end

return Cloud
