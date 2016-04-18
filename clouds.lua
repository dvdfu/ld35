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

function Clouds:hash(n)
    val = (1 + math.cos(n)) * 415.92653;
    return val - math.floor(val);
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
    for i = 1, math.floor(self.player.vel.x) do
        xi = self.player.pos.x - i
        if self:hash(xi) < self.rate then
            x, _ = self.camera:toWorldCoordinates(Screen.targetW + 120 + xi - Screen.targetW / 2, 0)
            y = math.random(WORLD.earthHeight, WORLD.cloudHeight - 100)
            table.insert(self.clouds, Cloud:new(x, -y, self.lowZ, self.highZ, self.player, self.camera))
        end
    end
end

function Clouds:draw()
    for _, cloud in pairs(self.clouds) do
        if math.floor(cloud.z) ~= 3 then
            layer = self.camera:getLayer(math.floor(cloud.z) .. '')
            layer:push()
            cloud:draw()
            layer:pop()
        else
            cloud:draw()
        end
    end

    Particles.update('cloud', 1 / 60)
    love.graphics.push()
        love.graphics.translate(self.player.pos:unpack())
        Particles.draw('cloud')
    love.graphics.pop()
end

return Clouds
