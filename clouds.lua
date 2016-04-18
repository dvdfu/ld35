local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Cloud = require('cloud')

local Clouds = Class('Clouds')

function Clouds:initialize(rate, lowZ, highZ, player, camera)
    self.rate = rate
    self.lowZ = lowZ
    self.highZ = highZ
    self.player = player
    self.camera = camera

    self.clouds = {}
end

function Clouds:updateMovement(dt)
    for k, cloud in pairs(self.clouds) do
        if cloud.dead then
            table.remove(self.clouds, k)
        else
            cloud:update(dt)
        end
    end
end

function Clouds:updateCreation(dt)
    if math.random() < self.rate then
        table.insert(self.clouds, Cloud:new(Screen.targetW + 120 + self.player.pos.x - Screen.targetW / 2, math.random() * Screen.targetH + self.player.pos.y - Screen.targetH / 2, self.lowZ, self.highZ, self.player, self.camera))
    end
end

function Clouds:draw()
    for _, cloud in pairs(self.clouds) do
        if math.floor(cloud.z) ~= 3 then
            layer = self.camera:getLayer(3 - math.floor(cloud.z) .. '')
            layer:push()
            cloud:draw()
            layer:pop()
        else
            cloud:draw()
        end
    end

    Particles.update('cloud', 1 / 60)
    Particles.draw('cloud')
end

return Clouds
