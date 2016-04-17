local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Vector = require('modules/hump/vector')

local Star = Class('Star')
Star:include(Stateful)

--============================================================================== PLAYER
function Star:initialize(x, y, z, player)
    self.pos = Vector(x,y)
    self.z = z
    self.player = player
    self.speedRatio = 0.5
    self.lineLengthRatio = 1
end

function Star:update(dt)
    self.pos = self.pos - self.player.vel * self.z * self.speedRatio
end

function Star:draw()
    local prev = self.pos + self.player.vel * self.z * self.lineLengthRatio * self.speedRatio
    love.graphics.setLineWidth(self.z)
    love.graphics.line(self.pos.x, self.pos.y, prev.x, prev.y)
end

--============================================================================== PLAYER.BALL

return Star
