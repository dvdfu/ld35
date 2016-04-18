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
        x, _ = self.camera:toScreenCoordinates(boost.pos:unpack())
        if boost.dead or x + 64 < 0 then
            table.remove(self.boosts, k)
        else
            boost:update(dt)
        end
    end
end

function Boosts:draw()
    if self.boosts then
        Boost:updateFeatherAnimation()
    end
    for k, boost in pairs(self.boosts) do
        boost:draw()
    end

    if (DEBUG) then
        self.camera:pop()
        love.graphics.setFont(FONT.babyblue)
        love.graphics.print('BOOSTS: ' .. #self.boosts, 10, Screen.targetH - 35)
        self.camera:push()
    end
end

function Boosts:generateBoost()
    local unitVector = self.player.vel:normalized()
    x, y = self.camera:toWorldCoordinates(math.random(Screen.targetW/2, Screen.targetW) + unitVector.x * Screen.targetW, math.random(1, Screen.targetH/2) + unitVector.y * Screen.targetH)
    table.insert(self.boosts, Boost:new(x, y, self.player, self.camera))
end

function Boosts:startGeneration()
    self.boostsTimer = Timer.new()
    self.boostsTimer.every(2,
        function()
            self:generateBoost()
        end)
end

return Boosts
