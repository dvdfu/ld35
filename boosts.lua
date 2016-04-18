local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Boost = require('boost')

local Boosts = Class('Boosts')

function Boosts:initialize(player, camera)
    self.player = player
    self.camera = camera
    self.boosts = {}
    self.boostsTimer = nil
end

function Boosts:update(dt)
    if self.boostsTimer then
        self.boostsTimer.update(dt)
    end
    for k, boost in pairs(self.boosts) do
        if boost.dead or boost.pos.x >= 2 * Screen.targetW + self.player.pos.x or boost.pos.x <= -2 * Screen.targetW + self.player.pos.x or boost.pos.y >= 2 * Screen.targetH + self.player.pos.y or boost.pos.y <= -2 * Screen.targetH + self.player.pos.y then
            table.remove(self.boosts, k)
        else
            boost:update(dt)
        end
    end
end

function Boosts:draw()
    for k, boost in pairs(self.boosts) do
        boost:draw()
    end

    if (DEBUG) then
        love.graphics.print('BOOSTS: ' .. #self.boosts, 10, Screen.targetH - 35)
    end
end

function Boosts:generateBoost()
    local unitVector = self.player.vel:normalized()
    local x = math.random(1, Screen.targetW) + unitVector.x * Screen.targetW
    local y = math.random(1, Screen.targetH) + unitVector.y * Screen.targetH
    table.insert(self.boosts, Boost:new(x + self.player.pos.x - Screen.targetW / 2, y + self.player.pos.y - Screen.targetH / 2, self.player, self.camera))
end

function Boosts:startGeneration()
    self.boostsTimer = Timer.new()
    self.boostsTimer.every(2,
        function()
            self:generateBoost()
        end)
end

return Boosts
