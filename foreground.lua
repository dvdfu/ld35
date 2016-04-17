local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Clouds = require('clouds')
local Boosts = require('boosts')

--============================================================================== LOCAL

--============================================================================== FOREGROUND
local Foreground = Class('Foreground')
Foreground:include(Stateful)
Foreground.Earth = Foreground:addState('Earth')
Foreground.Cloud = Foreground:addState('Cloud')
Foreground.Atmosphere = Foreground:addState('Atmosphere')
Foreground.Space = Foreground:addState('Space')
Foreground.Moon = Foreground:addState('Moon')

function Foreground:initialize(player)
    self.player = player
    self.clouds = Clouds:new(0.03, 3, 3, self.player)
    self.boosts = Boosts:new(player)
    self:gotoState('Earth')
end

function Foreground:update(dt)
    self.clouds:updateMovement(dt)
    self.boosts:update(dt)
end

function Foreground:draw()
    self.clouds:draw()
    self.boosts:draw()

    if (DEBUG) then
        love.graphics.print('HEIGHT: ' .. math.floor(self.player.pos.y), 10, Screen.targetH - 20)
    end
end

--============================================================================== FOREGROUND.EARTH
function Foreground.Earth:enteredState()

end

function Foreground.Earth:update(dt)
    Foreground.update(self, dt)
end

function Foreground.Earth:draw()
    Foreground.draw(self)
end

--============================================================================== FOREGROUND.CLOUD
function Foreground.Cloud:enteredState()
    self.boosts:startGeneration()
end

function Foreground.Cloud:update(dt)
    Foreground.update(self, dt)
    self.clouds:updateCreation(dt)
end

function Foreground.Cloud:draw()
    Foreground.draw(self)
end

--============================================================================== FOREGROUND.ATMOSPHERE
function Foreground.Atmosphere:enteredState()

end

function Foreground.Atmosphere:update(dt)
    Foreground.update(self, dt)
end

function Foreground.Atmosphere:draw()
    Foreground.draw(self)
end

--============================================================================== FOREGROUND.SPACE
function Foreground.Space:enteredState()

end

function Foreground.Space:update(dt)
    Foreground.update(self, dt)
end

function Foreground.Space:draw()
    Foreground.draw(self)
end

return Foreground
