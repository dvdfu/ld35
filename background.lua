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

local sprites = {
    earth = love.graphics.newImage('res/images/earth.png'),
    earthClouds = love.graphics.newImage('res/images/earth_clouds.png'),
    cloudLayerBack = love.graphics.newImage('res/images/cloud_layer_back.png')
}
--============================================================================== BACKGROUND
local Background = Class('Background')
Background:include(Stateful)

Background.Earth = Background:addState('Earth')
Background.Earth.lowerHeight = 0
Background.Earth.upperHeight = WORLD.earthHeight

Background.Cloud = Background:addState('Cloud')
Background.Cloud.lowerHeight = WORLD.earthHeight
Background.Cloud.upperHeight = WORLD.cloudHeight

Background.Atmosphere = Background:addState('Atmosphere')
Background.Atmosphere.lowerHeight = WORLD.cloudHeight
Background.Atmosphere.upperHeight = WORLD.atmosphereHeight

Background.Space = Background:addState('Space')
Background.Space.lowerHeight = WORLD.atmosphereHeight
Background.Space.upperHeight = WORLD.spaceHeight

Background.Moon = Background:addState('Moon')

function Background:initialize(player, foreground, camera)
    self.player = player
    self.foreground = foreground
    self.camera = camera
    self.RGB = earthRGB
    self.nextRGB = cloudRGB
    self.clouds = Clouds:new(0.075, 1, 2, self.player, self.camera)

    self.backgroundShader = love.graphics.newShader[[
        extern vec3 currentRGB;
        extern vec3 nextRGB;
        extern number h;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords);
            pixel.rgb = nextRGB + (currentRGB - nextRGB) * h;
            return pixel;
        }
    ]]

    self:gotoState('Earth')
end

function Background:update(dt)
    self.clouds:updateMovement(dt)
end

function Background:draw()
    -- love.graphics.setColor(self.nextRGB.r, self.nextRGB.g, self.nextRGB.b, 255)
    self.backgroundShader:sendColor('currentRGB', {self.RGB.r, self.RGB.g, self.RGB.b, self.RGB.a})
    self.backgroundShader:sendColor('nextRGB', {self.nextRGB.r, self.nextRGB.g, self.nextRGB.b, self.nextRGB.a})

    if self.upperHeight then
        -- Debug(math.abs((math.abs(self.player.pos.y) - self.lowerHeight) / (self.upperHeight - self.lowerHeight)), '')
        self.backgroundShader:send('h', 1 - math.abs((math.abs(self.player.pos.y) - self.lowerHeight) / (self.upperHeight - self.lowerHeight)))
    else
        self.backgroundShader:send('h', 0.0)
    end

    love.graphics.setShader(self.backgroundShader)
        love.graphics.rectangle('fill', self.camera.x - Screen.targetW / 2, self.camera.y - Screen.targetH / 2, Screen.targetW, Screen.targetH)
    love.graphics.setShader()

    self.clouds:draw()

    if (DEBUG) then
        self.camera:pop()
        love.graphics.print('CLOUDS: ' .. #self.clouds.clouds, 10, Screen.targetH - 70)
        self.camera:push()
    end
end

function Background:drawCloudLayer()
    self.camera:pop()
    local x, y = (self.player.pos.x * -1) % Screen.targetW, self.player:getHeight()
    love.graphics.draw(sprites.cloudLayerBack, x, y - WORLD.cloudHeight + 160 - 64, 0, 1, 1, 0, 64)
    love.graphics.draw(sprites.cloudLayerBack, x, y - WORLD.cloudHeight + 320 + 64, 0, 1, 1, 0, 64)
    love.graphics.draw(sprites.cloudLayerBack, x - Screen.targetW, y - WORLD.cloudHeight + 160 - 64, 0, 1, 1, 0, 64)
    love.graphics.draw(sprites.cloudLayerBack, x - Screen.targetW, y - WORLD.cloudHeight + 320 + 64, 0, 1, 1, 0, 64)
    self.camera:push()
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

    if (self.player:getHeight() > self.upperHeight) then
        self.foreground:gotoState('Cloud')
        self:gotoState('Cloud')
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
    self.clouds:updateCreation(dt)

    if (self.player:getHeight() > self.upperHeight) then
        self.foreground:gotoState('Atmosphere')
        self:gotoState('Atmosphere')
    elseif (self.player:getHeight() < self.lowerHeight) then
        self.foreground:gotoState('Earth')
        self:gotoState('Earth')
    end
end

function Background.Cloud:draw()
    Background.draw(self)
    self:drawCloudLayer()
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

    if (math.random(0, 10) == 0) then
        self.stars:update(dt)
    end

    if (self.player:getHeight() > self.upperHeight) then
        self.foreground:gotoState('Space')
        self:gotoState('Space')
    elseif (self.player:getHeight() < self.lowerHeight) then
        self.foreground:gotoState('Cloud')
        self:gotoState('Cloud')
    end
end

function Background.Atmosphere:draw()
    Background.draw(self)
    love.graphics.setColor(255, 255, 255, 128)
    self.stars:draw()
    love.graphics.setColor(255, 255, 255, 255)

    self:drawEarth()
    self:drawCloudLayer()
end

--============================================================================== BACKGROUND.SPACE
function Background.Space:enteredState()
    Debug('BACKGROUND', 'Space enteredState.')
    self.RGB = spaceRGB
end

function Background.Space:update(dt)
    Background.update(self, dt)
    self.stars:update(dt)

    if (self.player:getHeight() > self.upperHeight) then
        self.foreground:gotoState('Moon')
        self:gotoState('Moon')
    elseif (self.player:getHeight() < self.lowerHeight) then
        self.foreground:gotoState('Atmosphere')
        self:gotoState('Atmosphere')
    end
end

function Background.Space:draw()
    Background.draw(self)
    self.stars:draw()
    self:drawEarth()
    self:drawCloudLayer()
end

--============================================================================== BACKGROUND.MOON
function Background.Moon:enteredState()
    Debug('BACKGROUND', 'Moon enteredState.')
    self.RGB = spaceRGB
end

function Background.Moon:update(dt)
    Background.update(self, dt)
    self.stars:update(dt)
end

function Background.Moon:draw()
    Background.draw(self)
    self.stars:draw()
    self:drawEarth()

    self.camera:pop()
    love.graphics.draw(sprites.earth, 0, Screen.targetH + (self.player:getHeight() - WORLD.cloudHeight) / 15, 0, 1, 1, 0, 96)
    love.graphics.draw(sprites.earthClouds, 0, Screen.targetH + (self.player:getHeight() - WORLD.cloudHeight) / 12, 0, 1, 1, 0, 100)
    self.camera:push()
end

return Background
