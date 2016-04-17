local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Cloud = require('cloud')

local Clouds = Class('Clouds')

local clouds = {}

function Clouds:initialize(player)
    self.player = player
end

function Clouds:updateMovement(dt)
    for k, cloud in pairs(clouds) do
        if cloud.dead then
            table.remove(clouds, k)
        else
            cloud:update(dt)
        end
    end
end

function Clouds:updateCreation(dt)
    if math.random() < 0.1 then
        table.insert(clouds, Cloud:new(Screen.targetW + 120, math.random() * Screen.targetH, self.player))
    end
end

function Clouds:draw()
    for k, cloud in pairs(clouds) do
        cloud:draw()
    end

    Particles.update('cloud', 1 / 60)
    Particles.draw('cloud')
end

return Clouds
