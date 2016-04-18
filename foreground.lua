local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Vector = require('modules/hump/vector')

local Clouds = require('clouds')
local Boosts = require('boosts')
local Moon = require('moon')

--============================================================================== LOCAL

local sprites = {
    cloudLayer = love.graphics.newImage('res/images/cloud_layer.png')
}

--============================================================================== FOREGROUND
local Foreground = Class('Foreground')
Foreground:include(Stateful)
Foreground.Earth = Foreground:addState('Earth')
Foreground.Cloud = Foreground:addState('Cloud')
Foreground.Atmosphere = Foreground:addState('Atmosphere')
Foreground.Space = Foreground:addState('Space')
Foreground.Moon = Foreground:addState('Moon')

function Foreground:initialize(player, camera)
    self.player = player
    self.camera = camera
    self.clouds = Clouds:new(0.03, 3, 3, self.player, self.camera)
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
        self.camera:pop()
        love.graphics.print('HEIGHT: ' .. math.floor(self.player:getHeight()), 10, Screen.targetH - 20)
        self.camera:push()
    end

    -- if self.player:getHeight() > WORLD.cloudHeight - 400 and self.player:getHeight() < WORLD.cloudHeight + 400 then
    self.camera:pop()
    love.graphics.draw(sprites.cloudLayer, 0, self.player:getHeight() - WORLD.cloudHeight - 400, 0, 1, 1, 0, 64)
    love.graphics.draw(sprites.cloudLayer, 0, self.player:getHeight() - WORLD.cloudHeight - 100, 0, 1, 1, 0, 64)
    love.graphics.setColor(203, 219, 252)
    love.graphics.rectangle('fill', 0, self.player:getHeight() - WORLD.cloudHeight - 400, Screen.targetW, 300)
    love.graphics.setColor(255, 255, 255)
    self.camera:push()
    -- end
end

--============================================================================== FOREGROUND.EARTH
function Foreground.Earth:enteredState() end

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
function Foreground.Atmosphere:enteredState() end

function Foreground.Atmosphere:update(dt)
    Foreground.update(self, dt)
end

function Foreground.Atmosphere:draw()
    Foreground.draw(self)
end

--============================================================================== FOREGROUND.SPACE
function Foreground.Space:enteredState() end

function Foreground.Space:update(dt)
    Foreground.update(self, dt)
end

function Foreground.Space:draw()
    Foreground.draw(self)
end

--============================================================================== FOREGROUND.MOON
function Foreground.Moon:enteredState()
    self.player:prepareLanding()
    self.moon = Moon:new(self.player)
    self.boosts.boostsTimer.clear()
end

function Foreground.Moon:update(dt)
    Foreground.update(self, dt)
    self.moon:update(dt)
end

function Foreground.Moon:draw()
    Foreground.draw(self)
    self.moon:draw()
end

return Foreground
