local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
local Vector = require('modules/hump/vector')

local Moon = Class('Moon')

local sprites = {
    moon = love.graphics.newImage('res/images/moon.png'),
    impact = love.graphics.newImage('res/images/impact.png')
}

--============================================================================== MOON
function Moon:initialize(x, y, player)
    self.pos = Vector(x, y)
    self.player = player
    self.body = HC.polygon(0, 0, 512, 0, 512, 512)
    self.impactTimer = 0
end

function Moon:update(dt)
    self.pos = self.pos - self.player.vel
    self.body:moveTo(self.pos.x + 341, self.pos.y + 170)

    local collides, dx, dy = self.body:collidesWith(self.player.body)
    if collides then
        if self.player.userHasControl then
            self.impactTimer = 20
            self.player:halt()
            self.player.pos = self.player.pos - Vector(dx, dy)
            Particles.emit('dust', self.player.absolutePos.x, self.player.absolutePos.y, 40)
        end
    end
end

function Moon:draw()
    -- self.body:draw('line')

    Particles.update('dust', 1 / 60)
    Particles.draw('dust')
    love.graphics.draw(sprites.moon, self.pos:unpack())

    if self.impactTimer > 0 then
        love.graphics.setColor(255, 255, 255, self.impactTimer * 255 / 20)
        love.graphics.draw(sprites.impact, self.player.absolutePos.x, self.player.absolutePos.y, 0, 1 + self.impactTimer / 20, 1 + self.impactTimer / 20, 116, 8)
        love.graphics.setColor(255, 255, 255, 255)
        self.impactTimer = self.impactTimer - 1
    end
end

return Moon
