local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Clouds = require('clouds')
local Stars = require('stars')

--============================================================================== LOCAL
local earthRGB = RGB(140, 210, 230)
local cloudRGB = RGB(120, 170, 200)
local atmosphereRGB = RGB(90, 110, 150)
local spaceRGB = RGB(0, 0, 0)

local transitionStepTime = 0.01
local transitionStepValue = 5

--============================================================================== BACKGROUND
local Background = Class('Background')
Background:include(Stateful)
Background.Earth = Background:addState('Earth')
Background.Cloud = Background:addState('Cloud')
Background.Atmosphere = Background:addState('Atmosphere')
Background.Space = Background:addState('Space')
Background.Transition = Background:addState('Transition')

function Background:initialize(player, foreground, camera)
    self.player = player
    self.foreground = foreground
    self.camera = camera
    self.alpha = 255
    self.RGB = earthRGB
    self.nextRGB = cloudRGB
    self.transitionTimer = nil
    self.clouds = Clouds:new(0.075, 1, 2, self.player)
    self:gotoState('Earth')
end

function Background:update(dt)
    self.clouds:updateMovement(dt)
end

function Background:draw()
    love.graphics.setColor(self.nextRGB.r, self.nextRGB.g, self.nextRGB.b, 255)
    love.graphics.rectangle('fill', self.camera.x - Screen.targetW, self.camera.y - Screen.targetH, Screen.targetW, Screen.targetH)
    love.graphics.setColor(self.RGB.r, self.RGB.g, self.RGB.b, self.alpha)
    love.graphics.rectangle('fill', self.camera.x - Screen.targetW, self.camera.y - Screen.targetH, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)

    self.clouds:draw()
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

    if (self.player:getHeight() > WORLD.earthHeight and not self.transitionTimer) then
        self.transitionTimer = Timer.new()
        self.transitionTimer.every(transitionStepTime, function() self:changeAlpha() end)
    elseif (self.player:getHeight() > WORLD.earthHeight and self.alpha < 0) then
        Timer.cancel(self.transitionTimer)
        self.alpha = 255
        self.transitionTimer = nil
        self.foreground:gotoState('Cloud')
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
end

function Background.Cloud:update(dt)
    Background.update(self, dt)

    self.clouds:updateCreation(dt)

    if (self.player:getHeight() > WORLD.cloudHeight and not self.transitionTimer) then
        self.transitionTimer = Timer.new()
        self.transitionTimer.every(transitionStepTime, function() self:changeAlpha() end)
    elseif (self.player:getHeight() > WORLD.cloudHeight and self.alpha < 0) then
        Timer.cancel(self.transitionTimer)
        self.alpha = 255
        self.transitionTimer = nil
        self.foreground:gotoState('Atmosphere')
        self:gotoState('Atmosphere')
    elseif (self.transitionTimer) then
        self.transitionTimer.update(dt)
    end
end

function Background.Cloud:draw()
    Background.draw(self)
end

--============================================================================== BACKGROUND.ATMOSPHERE
function Background.Atmosphere:enteredState()
    Debug('BACKGROUND', 'Atmosphere enteredState.')
    self.RGB = atmosphereRGB
    self.nextRGB = spaceRGB
end

function Background.Atmosphere:update(dt)
    Background.update(self, dt)
    if (self.player:getHeight() > WORLD.atmosphereHeight and not self.transitionTimer) then
        self.transitionTimer = Timer.new()
        self.transitionTimer.every(transitionStepTime, function() self:changeAlpha() end)
    elseif (self.player:getHeight() > WORLD.atmosphereHeight and self.alpha < 0) then
        Timer.cancel(self.transitionTimer)
        self.alpha = 255
        self.transitionTimer = nil
        self.foreground:gotoState('Space')
        self:gotoState('Space')
    elseif (self.transitionTimer) then
        self.transitionTimer.update(dt)
    end
end

function Background.Atmosphere:draw()
    Background.draw(self)
end

--============================================================================== BACKGROUND.SPACE
function Background.Space:enteredState()
    Debug('BACKGROUND', 'Space enteredState.')
    self.RGB = spaceRGB
    self.stars = Stars:new(self.player)
end

function Background.Space:update(dt)
    Background.update(self, dt)
    self.stars:update(dt)
    Timer.update(dt)
end

function Background.Space:draw()
    Background.draw(self)
    self.stars:draw()
end

return Background
