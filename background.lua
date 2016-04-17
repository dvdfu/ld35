local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Star = require('star')

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

function Background:draw()
    love.graphics.setColor(self.nextRGB.r, self.nextRGB.g, self.nextRGB.b, 255)
    love.graphics.rectangle('fill', 0, 0, Screen.targetW, Screen.targetH)
    love.graphics.setColor(self.RGB.r, self.RGB.g, self.RGB.b, self.alpha)
    love.graphics.rectangle('fill', 0, 0, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)
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
end

function Background.Cloud:update(dt)
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
end

--============================================================================== BACKGROUND.ATMOSPHERE
function Background.Atmosphere:enteredState()
    Debug('BACKGROUND', 'Atmosphere enteredState.')
    self.RGB = atmosphereRGB
    self.nextRGB = spaceRGB
end

function Background.Atmosphere:update(dt)
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
end

--============================================================================== BACKGROUND.SPACE
function Background.Space:enteredState()
    Debug('BACKGROUND', 'Space enteredState.')
    self.RGB = spaceRGB
    self.stars = {}
    Timer.after(0.1,
        function(func)
            self:generateStar() self:generateStar() self:generateStar()
            self:generateStar() self:generateStar() self:generateStar()
            Timer.after(self.player.vel:len() < 5 and 2 or 0.1, func)
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
    Timer.update(dt)
end

function Background.Space:draw()
    Background.draw(self)
    for k, star in pairs(self.stars) do
        star:draw()
    end
    if (DEBUG) then
        love.graphics.print('STARS: ' .. #self.stars, 150, Screen.targetH - 20)
    end
end

function Background.Space:generateStar()
    local unitVector = self.player.vel:normalized()
    local x = math.random(1, Screen.targetW) + unitVector.x * Screen.targetW
    local y = math.random(1, Screen.targetH) + unitVector.y * Screen.targetH
    table.insert(self.stars, Star:new(x, y, self.player))
end

return Background
