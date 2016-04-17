local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Clouds = require('clouds')

--============================================================================== LOCAL

--============================================================================== FOREGROUND
local Foreground = Class('Foreground')
Foreground:include(Stateful)
Foreground.Earth = Foreground:addState('Earth')
Foreground.Cloud = Foreground:addState('Cloud')
Foreground.Atmosphere = Foreground:addState('Atmosphere')
Foreground.Space = Foreground:addState('Space')

function Foreground:initialize(player, camera)
    self.player = player
    self.camera = camera
    self.clouds = Clouds:new(0.03, 3, 3, self.player)
    self:gotoState('Earth')
end

function Foreground:update(dt)
    self.clouds:updateMovement(dt)
end

function Foreground:draw()
    self.clouds:draw()

    if (DEBUG) then
        self.camera:detach()
        love.graphics.print('HEIGHT: ' .. math.floor(self.player.pos.y), 10, Screen.targetH - 20)
        self.camera:attach()
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
