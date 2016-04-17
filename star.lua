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
    self.z = 1 + 3 * math.random()
    self.player = player
end

function Star:update(dt)

end

function Star:draw()
    local point = self.pos - self.player.vel * self.z
    love.graphics.setLineWidth(self.z)
    love.graphics.line(point.x, point.y, self.pos.x, self.pos.y)
    love.graphics.setLineWidth(1)
end

return Star
