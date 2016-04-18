local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
local Vector = require('modules/hump/vector')

local Ground = Class('Ground')

--============================================================================== Ground
function Ground:initialize(player, camera)
    self.player = player
    self.camera = camera
    self.body = HC.polygon(0, 0, Screen.targetW, 0, Screen.targetW, Screen.targetH, 0, Screen.targetH)
    self.pos = Vector(0, 0)
end

function Ground:update(dt)
    local collides, dx, dy = self.body:collidesWith(self.player.body)
    if collides then
        self.player:halt()
        self.player.pos = self.player.pos - Vector(dx, dy)
    end
end

function Ground:draw()
    x, y = self.camera:toWorldCoordinates(0, 0)
    y = INTRO.groundHeight
    self.body:moveTo(x + Screen.targetW / 2, y + Screen.targetH / 2)

    love.graphics.setColor(172, 138, 101)
    love.graphics.rectangle('fill', x, y, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)
end

return Ground
