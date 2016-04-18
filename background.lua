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

local sprites = {
    earth = love.graphics.newImage('res/images/earth.png'),
    earthClouds = love.graphics.newImage('res/images/earth_clouds.png')
}

--============================================================================== BACKGROUND
local Background = Class('Background')
Background:include(Stateful)
Background.Earth = Background:addState('Earth')
Background.Cloud = Background:addState('Cloud')
Background.Atmosphere = Background:addState('Atmosphere')
Background.Space = Background:addState('Space')
Background.Moon = Background:addState('Moon')
Background.Transition = Background:addState('Transition')

function Background:initialize(player, foreground, camera)
    self.player = player
    self.foreground = foreground
    self.camera = camera
    self.alpha = 255
    self.RGB = earthRGB
    self.nextRGB = cloudRGB
    self.transitionTimer = nil
    self.clouds = Clouds:new(0.075, 1, 2, self.player, self.camera)
    self:gotoState('Earth')
end

function Background:update(dt)
    self.clouds:updateMovement(dt)
end

function Background:draw()
    love.graphics.setColor(self.nextRGB.r, self.nextRGB.g, self.nextRGB.b, 255)
    love.graphics.rectangle('fill', self.camera.x - Screen.targetW / 2, self.camera.y - Screen.targetH / 2, Screen.targetW, Screen.targetH)
    love.graphics.setColor(self.RGB.r, self.RGB.g, self.RGB.b, self.alpha)
    love.graphics.rectangle('fill', self.camera.x - Screen.targetW / 2, self.camera.y - Screen.targetH / 2, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)

    self.clouds:draw()

    if (DEBUG) then
        self.camera:pop()
        love.graphics.print('CLOUDS: ' .. #self.clouds.clouds, 10, Screen.targetH - 70)
        self.camera:push()
    end
end

function Background:changeAlpha()
    self.alpha = self.alpha - transitionStepValue
end

function Background:drawEarth()
    self.camera:pop()
    love.graphics.draw(sprites.earth, 0, Screen.targetH + (self.player:getHeight() - WORLD.cloudHeight) / 22, 0, 1, 1, 0, 128)
    love.graphics.setColor(0, 20, 40, 80)
    love.graphics.draw(sprites.earthClouds, 0, Screen.targetH + (self.player:getHeight() - WORLD.cloudHeight) / 18 + 6, 0, 1, 1, 0, 144)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(sprites.earthClouds, 0, Screen.targetH + (self.player:getHeight() - WORLD.cloudHeight) / 18, 0, 1, 1, 0, 144)
    self.camera:push()
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
        self.transitionTimer.clear()
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
    self.stars = Stars:new(self.player, self.camera)
end

function Background.Cloud:update(dt)
    Background.update(self, dt)
    self.stars:update(dt)
    self.clouds:updateCreation(dt)

    if (self.player:getHeight() > WORLD.cloudHeight and not self.transitionTimer) then
        self.transitionTimer = Timer.new()
        self.transitionTimer.every(transitionStepTime, function() self:changeAlpha() end)
    elseif (self.player:getHeight() > WORLD.cloudHeight and self.alpha < 0) then
        self.transitionTimer.clear()
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
    love.graphics.setColor(255, 255, 255, 64)
    self.stars:draw()
    love.graphics.setColor(255, 255, 255, 255)
end

--============================================================================== BACKGROUND.ATMOSPHERE
function Background.Atmosphere:enteredState()
    Debug('BACKGROUND', 'Atmosphere enteredState.')
    self.RGB = atmosphereRGB
    self.nextRGB = spaceRGB
    self.earthTimer = 0
end

function Background.Atmosphere:update(dt)
    Background.update(self, dt)
    self.earthTimer = self.earthTimer + dt

    self.stars:update(dt)
    if (self.player:getHeight() > WORLD.atmosphereHeight and not self.transitionTimer) then
        self.transitionTimer = Timer.new()
        self.transitionTimer.every(transitionStepTime, function() self:changeAlpha() end)
    elseif (self.player:getHeight() > WORLD.atmosphereHeight and self.alpha < 0) then
        self.transitionTimer.clear()
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
    love.graphics.setColor(255, 255, 255, 128)
    self.stars:draw()
    love.graphics.setColor(255, 255, 255, 255)

    self:drawEarth()
end

--============================================================================== BACKGROUND.SPACE
function Background.Space:enteredState()
    Debug('BACKGROUND', 'Space enteredState.')
    self.RGB = spaceRGB
end

function Background.Space:update(dt)
    Background.update(self, dt)
    self.stars:update(dt)

    if self.player:getHeight() > WORLD.spaceHeight and not self.transitionTimer then
            self.transitionTimer = Timer.new()
            self.transitionTimer.every(transitionStepTime, function() self:changeAlpha() end)
    elseif self.player:getHeight() > WORLD.spaceHeight and self.alpha < 0 then
        self.transitionTimer.clear()
        self.alpha = 255
        self.transitionTimer = nil
        self.foreground:gotoState('Moon')
        self:gotoState('Moon')
    elseif self.transitionTimer then
        self.transitionTimer.update(dt)
    end
end

function Background.Space:draw()
    Background.draw(self)
    self.stars:draw()
    self:drawEarth()
end

--============================================================================== BACKGROUND.MOON
function Background.Moon:enteredState()
    Debug('BACKGROUND', 'Moon enteredState.')
    self.RGB = spaceRGB
    self.stars.starsTimer.clear()
end

function Background.Moon:update(dt)
    Background.update(self, dt)
    self.stars:update(dt)
end

function Background.Moon:draw()
    Background.draw(self)
    self.stars:draw()

    self.camera:pop()
    love.graphics.draw(sprites.earth, 0, Screen.targetH + (self.player:getHeight() - WORLD.cloudHeight) / 15, 0, 1, 1, 0, 96)
    love.graphics.draw(sprites.earthClouds, 0, Screen.targetH + (self.player:getHeight() - WORLD.cloudHeight) / 12, 0, 1, 1, 0, 100)
    self.camera:push()
end

return Background
