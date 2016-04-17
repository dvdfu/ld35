local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
local Vector = require('modules/hump/vector')

local Moon = Class('Moon')

local sprites = {
    moon = love.graphics.newImage('res/images/moon.png')
}

--============================================================================== MOON
function Moon:initialize(x, y, player)
    self.pos = Vector(x, y)
    self.player = player
    self.body = HC.polygon(0, 0, 512, 0, 512, 512)
end

function Moon:update(dt)
    self.pos = self.pos - self.player.vel
    self.body:moveTo(self.pos.x + 341, self.pos.y + 170)
end

function Moon:draw()
    love.graphics.draw(sprites.moon, self.pos:unpack())
    self.body:draw('line')
end

return Moon
