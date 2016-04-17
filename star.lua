local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Vector = require('modules/hump/vector')

local Star = Class('Star')
Star:include(Stateful)

--============================================================================== STAR
function Star:initialize(x, y, player)
    self.pos = Vector(x, y)
    self.prev = self.pos:clone()
    self.z = 1 + 2 * math.random()
    self.player = player
end

function Star:update(dt)
    self.prev = self.pos:clone()
    self.pos = self.pos - self.player.vel * self.z
end

function Star:draw()
    love.graphics.setLineWidth(self.z)
    love.graphics.line(self.pos.x, self.pos.y, self.prev.x, self.prev.y)
    love.graphics.setLineWidth(1)
end

return Star
