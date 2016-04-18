local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
local Vector = require('modules/hump/vector')

local Boost = Class('Boost')
Boost:include(Stateful)

local sprites = {
    boost = love.graphics.newImage('res/images/boost.png')
}

function Boost:initialize(x, y, player)
    self.pos = Vector(x, y)
    self.player = player
    self.body = HC.circle(x, y, 24)
    self.dead = false
end

function Boost:update(dt)
    self.pos = self.pos - self.player.vel / 2
    self.body:moveTo(self.pos:unpack())

    local collides, _, _ = self.body:collidesWith(self.player.body)
    if collides then
        --collision logic
        self.player:boost()
        self.dead = true
    end
end

function Boost:draw()
    love.graphics.draw(sprites.boost, self.pos.x, self.pos.y, 0, 1, 1, 32, 32)
    -- self.body:draw('line')
end

return Boost
