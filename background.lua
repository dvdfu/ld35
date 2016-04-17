local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Star = require('star')

local Background = Class('Background')
Background:include(Stateful)
Background.Earth = Background:addState('Earth')
Background.Cloud = Background:addState('Cloud')
Background.Atmosphere = Background:addState('Atmosphere')
Background.Space = Background:addState('Space')

function Background:initialize(player)
    self.player = player
    self:gotoState('Space')
end

--============================================================================== BACKGROUND.EARTH
function Background.Earth:enteredState()

end

function Background.Earth:update(dt)

end

function Background.Earth:draw()

end

--============================================================================== BACKGROUND.CLOUD
function Background.Cloud:enteredState()

end

function Background.Cloud:update(dt)

end

function Background.Cloud:draw()

end

--============================================================================== BACKGROUND.ATMOSPHERE
function Background.Atmosphere:enteredState()

end

function Background.Atmosphere:update(dt)

end

function Background.Atmosphere:draw()

end

--============================================================================== BACKGROUND.SPACE
function Background.Space:enteredState()
    self.stars = {}
    self.starTimer = Timer.new()
    self.starTimer.every(0.1,
        function()
            self:generateStar()
            self:generateStar()
            self:generateStar()
        end)
end

function Background.Space:update(dt)
    for k, star in pairs(self.stars) do
        if star.pos.x >= 2 * Screen.targetW or star.pos.x <= -2 * Screen.targetW or star.pos.y >= 2 * Screen.targetH or star.pos.y <= -2 * Screen.targetH then
            table.remove(self.stars, k)
        else
            star:update(dt)
        end
    end

    self.starTimer.update(dt)
end

function Background.Space:draw()
    for k, star in pairs(self.stars) do
        star:draw()
    end
end

function Background.Space:generateStar()
    local unitVector = self.player.vel:normalized()
    local x = math.random(1, Screen.targetW) + unitVector.x * Screen.targetW
    local y = math.random(1, Screen.targetH) + unitVector.y * Screen.targetH
    local z = math.random(1, 3)
    table.insert(self.stars, Star:new(x, y, z, self.player))
end

return Background

