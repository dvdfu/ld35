local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Vector = require('modules/hump/vector')

local Star = Class('Star')
Star:include(Stateful)

--============================================================================== PLAYER
function Star:initialize(x, y, z, player)
    self.pos = Vector(x,y)
    self.prev = self.pos
    self.z = z
    self.player = player
end

function Star:update(dt)
    self.prev = self.pos
    self.pos = self.pos - self.player.vel*dt*self.z
end

function Star:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.line(self.pos.x, self.pos.y, self.prev*0.1, self.prev*0.1)
end

--============================================================================== PLAYER.BALL

return Star
