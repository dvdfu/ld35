local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
local Vector = require('modules/hump/vector')

local Moon = Class('Moon')

local sprites = {
    moon = love.graphics.newImage('res/images/moon.png'),
    impact = love.graphics.newImage('res/images/impact.png')
}

--============================================================================== MOON
function Moon:initialize(player, camera)
    self.pos = player.pos + (player.vel:normalized() * 500 - Vector(512, 512))
    self.player = player
    self.camera = camera
    self.body = HC.polygon(0, 0, 512, 0, 512, 512)
    self.sx = 1 / self.camera.scaleX
    self.sy = 1 / self.camera.scaleY
    self.body:scale(self.sx, self.sy)
    self.body:moveTo(self.pos.x + 341 * self.sx, self.pos.y + 170 * self.sy)
    self.impacted = false
    self.impactTimer = 0
end

function Moon:update(dt)
    if self.player.state ~= self.player.STATE.DEAD then
        local collides, dx, dy = self.body:collidesWith(self.player.body)
        if collides then
            if not self.impacted then
                self.impacted = true
                self.impactTimer = 20
                self.player:halt()
                self.player.pos = self.player.pos - Vector(dx, dy)
                self.camera:shake(100, 0.3, {})
                Particles.emit('moon', self.player.pos.x, self.player.pos.y, 40)
            end
        end
    end
end

function Moon:draw()
    Particles.update('moon', 1 / 60)
    Particles.draw('moon')
    love.graphics.draw(sprites.moon, self.pos.x, self.pos.y, 0, self.sx, self.sy)

    if self.impactTimer > 0 then
        love.graphics.setColor(255, 255, 255, self.impactTimer * 255 / 20)
        love.graphics.draw(sprites.impact, self.player.pos.x, self.player.pos.y, 0, 1 + self.impactTimer / 20, 1 + self.impactTimer / 20, 116, 8)
        love.graphics.setColor(255, 255, 255, 255)
        self.impactTimer = self.impactTimer - 1
    end

    if DEBUG then
        self.body:draw('line')
    end
end

return Moon
