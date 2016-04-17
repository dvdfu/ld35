local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Cloud = require('cloud')

local Clouds = Class('Clouds')

function Clouds:initialize(rate, lowZ, highZ, player)
    self.rate = rate
    self.lowZ = lowZ
    self.highZ = highZ
    self.player = player

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
        table.insert(self.clouds, Cloud:new(Screen.targetW + 120, math.random() * Screen.targetH, self.lowZ, self.highZ, self.player))
    end
end

function Clouds:draw()
    for k, cloud in pairs(self.clouds) do
        cloud:draw()
    end

    Particles.update('cloud', 1 / 60)
    Particles.draw('cloud')
end

return Clouds
