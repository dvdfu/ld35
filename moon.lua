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
    self.body = HC.circle()
end

function Moon:update(dt)
end

function Moon:draw()
    love.graphics.draw(sprites.moon, self.pos:unpack())
end

return Moon
