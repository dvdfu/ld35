local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
local Vector = require('modules/hump/vector')

local Ground = Class('Ground')

local animations = {}
local sprites = {
    pitcher = love.graphics.newImage('res/images/pitcher.png'),
    batter = love.graphics.newImage('res/images/batter.png')
}

--============================================================================== Ground
function Ground:initialize(player, camera)
    self.player = player
    self.camera = camera
    self.body = HC.polygon(0, 0, Screen.targetW, 0, Screen.targetW, Screen.targetH, 0, Screen.targetH)
    self.pos = Vector(0, 0)
    self.impacted = false

    local grid = Anim8.newGrid(160, 128, 160 * 6, 128)
    animations.pitcher = Anim8.newAnimation(grid:getFrames('1-6', 1), 0.1, 'pauseAtEnd')
    animations.pitcher:pauseAtStart()

    local grid = Anim8.newGrid(160, 128, 160 * 4, 128)
    animations.batter = Anim8.newAnimation(grid:getFrames('1-4', 1), 0.1, 'pauseAtEnd')
    animations.batter:pauseAtStart()
end

function Ground:update(dt)
    if self.player.state ~= self.player.STATE.DEAD then
        local collides, dx, dy = self.body:collidesWith(self.player.body)
        if not self.player.intro and collides then
            self.player:halt()
            self.camera:shake(25, 0.3, {})
            self.player.pos = self.player.pos - Vector(dx, dy)
            Particles.emit('dust', self.player.pos.x, self.player.pos.y, 40)
        end
    end
    Particles.update('dust', dt)
end

function Ground:draw()
    x, y = self.camera:toWorldCoordinates(0, 0)
    y = INTRO.groundHeight
    self.body:moveTo(x + Screen.targetW / 2, y + Screen.targetH / 2)

    Particles.draw('dust')
    love.graphics.setColor(172, 138, 101)
    love.graphics.rectangle('fill', x, y, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)

    animations.pitcher:update(1 / 60)
    animations.pitcher:draw(sprites.pitcher, 0, INTRO.groundHeight - 128)

    animations.batter:update(1 / 60)
    animations.batter:draw(sprites.batter, -500, INTRO.groundHeight - 128, 0, 1, 1, 100)
end

function Ground:startBatter()
    animations.batter:resume()
end

function Ground:startPitcher()
    animations.pitcher:resume()
end

return Ground
