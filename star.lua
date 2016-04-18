local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Vector = require('modules/hump/vector')

local Star = Class('Star')
Star:include(Stateful)

--============================================================================== STAR
function Star:initialize(x, y, player)
    self.pos = Vector(x, y)
    self.z = math.random(1, 3)
    self.player = player
end

function Star:update(dt)
end

function Star:draw()
    love.graphics.setLineWidth(self.z)
    love.graphics.setLineStyle('smooth')
    local point = self.pos - self.player.vel/self.player.vel:len() * (self.player.vel:len() - self.player.birdFallSpeedX + 1) * self.z
    love.graphics.line(self.pos.x, self.pos.y, point.x, point.y)
    love.graphics.setLineWidth(1)
end

return Star
