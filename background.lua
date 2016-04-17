local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Cloud = require('cloud')
local Stars = require('stars')

--============================================================================== LOCAL
local earthRGB = RGB(140, 210, 230)
local cloudRGB = RGB(120, 170, 200)
local atmosphereRGB = RGB(90, 110, 150)
local spaceRGB = RGB(0, 0, 0)

local earthHeight = 1000
local cloudHeight = 2000
local atmosphereHeight = 3000

local transitionStepTime = 0.01
local transitionStepValue = 5

local clouds = {}

--============================================================================== BACKGROUND
local Background = Class('Background')
Background:include(Stateful)
Background.Earth = Background:addState('Earth')
Background.Cloud = Background:addState('Cloud')
Background.Atmosphere = Background:addState('Atmosphere')
Background.Space = Background:addState('Space')
Background.Transition = Background:addState('Transition')

function Background:initialize(player)
    self.player = player
    self.alpha = 255
    self.RGB = earthRGB
    self.nextRGB = cloudRGB
    self.transitionTimer = nil
    self:gotoState('Earth')
end

function Background:update(dt)
    for k, cloud in pairs(clouds) do
        if cloud.dead then
            table.remove(clouds, k)
        else
            cloud:update(dt)
        end
    end
end

function Background:draw()
    love.graphics.setColor(self.nextRGB.r, self.nextRGB.g, self.nextRGB.b, 255)
    love.graphics.rectangle('fill', 0, 0, Screen.targetW, Screen.targetH)
    love.graphics.setColor(self.RGB.r, self.RGB.g, self.RGB.b, self.alpha)
    love.graphics.rectangle('fill', 0, 0, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)

    for k, cloud in pairs(clouds) do
        cloud:draw()
    end

    Particles.update('cloud', 1 / 60)
    Particles.draw('cloud')

    if (DEBUG) then
        love.graphics.print('HEIGHT: ' .. math.floor(self.player.pos.y), 10, Screen.targetH - 20)
    end
end

function Background:changeAlpha()
    self.alpha = self.alpha - transitionStepValue
end

--============================================================================== BACKGROUND.EARTH
function Background.Earth:enteredState()
    Debug('BACKGROUND', 'Earth enteredState.')
    self.RGB = earthRGB
    self.nextRGB = cloudRGB
end

function Background.Earth:update(dt)
    Background.update(self, dt)
    if (self.player.pos.y > earthHeight and not self.transitionTimer) then
        self.transitionTimer = Timer.new()
        self.transitionTimer.every(transitionStepTime, function() self:changeAlpha() end)
    elseif (self.player.pos.y > earthHeight and self.alpha < 0) then
        Timer.cancel(self.transitionTimer)
        self.alpha = 255
        self.transitionTimer = nil
        self:gotoState('Cloud')
    elseif (self.transitionTimer) then
        self.transitionTimer.update(dt)
    end
end

function Background.Earth:draw()
    Background.draw(self)
end

--============================================================================== BACKGROUND.CLOUD
function Background.Cloud:enteredState()
    Debug('BACKGROUND', 'Cloud enteredState.')
    self.RGB = cloudRGB
    self.nextRGB = atmosphereRGB
    self.stars = Stars:new(self.player)
end

function Background.Cloud:update(dt)
    Background.update(self, dt)
    self.stars:update(dt)

    if math.random() < 0.1 then
        table.insert(clouds, Cloud:new(Screen.targetW + 120, math.random() * Screen.targetH, self.player))
    end
    if (self.player.pos.y > cloudHeight and not self.transitionTimer) then
        self.transitionTimer = Timer.new()
        self.transitionTimer.every(transitionStepTime, function() self:changeAlpha() end)
    elseif (self.player.pos.y > cloudHeight and self.alpha < 0) then
        Timer.cancel(self.transitionTimer)
        self.alpha = 255
        self.transitionTimer = nil
        self:gotoState('Atmosphere')
    elseif (self.transitionTimer) then
        self.transitionTimer.update(dt)
    end
end

function Background.Cloud:draw()
    Background.draw(self)
    love.graphics.setColor(255, 255, 255, 64)
    self.stars:draw()
    love.graphics.setColor(255, 255, 255, 255)
end

--============================================================================== BACKGROUND.ATMOSPHERE
function Background.Atmosphere:enteredState()
    Debug('BACKGROUND', 'Atmosphere enteredState.')
    self.RGB = atmosphereRGB
    self.nextRGB = spaceRGB
end

function Background.Atmosphere:update(dt)
    Background.update(self, dt)
    self.stars:update(dt)
    if (self.player.pos.y > atmosphereHeight and not self.transitionTimer) then
        self.transitionTimer = Timer.new()
        self.transitionTimer.every(transitionStepTime, function() self:changeAlpha() end)
    elseif (self.player.pos.y > atmosphereHeight and self.alpha < 0) then
        Timer.cancel(self.transitionTimer)
        self.alpha = 255
        self.transitionTimer = nil
        self:gotoState('Space')
    elseif (self.transitionTimer) then
        self.transitionTimer.update(dt)
    end
end

function Background.Atmosphere:draw()
    Background.draw(self)
    love.graphics.setColor(255, 255, 255, 128)
    self.stars:draw()
    love.graphics.setColor(255, 255, 255, 255)
end

--============================================================================== BACKGROUND.SPACE
function Background.Space:enteredState()
    Debug('BACKGROUND', 'Space enteredState.')
    self.RGB = spaceRGB
end

function Background.Space:update(dt)
    Background.update(self, dt)
    self.stars:update(dt)
end

function Background.Space:draw()
    Background.draw(self)
    self.stars:draw()
end

return Background
