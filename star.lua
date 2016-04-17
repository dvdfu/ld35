local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Vector = require('modules/hump/vector')

local Star = Class('Star')
Star:include(Stateful)

--============================================================================== PLAYER
function Star:initialize(x, y, player)
    self.pos = Vector(x,y)
    self.prev = self.pos:clone()
    self.z = 1 + 2 * math.random()
    self.player = player
    self.speedRatio = 0.5
    self.lineLengthRatio = 1
end

function Star:update(dt)
    self.prev = self.pos:clone()
    self.pos = self.pos - self.player.vel * self.z * self.speedRatio * 2
end

function Star:draw()
    love.graphics.setLineWidth(self.z)
    love.graphics.line(self.pos.x, self.pos.y, self.prev.x, self.prev.y)
    love.graphics.setLineWidth(1)
end

--============================================================================== PLAYER.BALL

return Star
