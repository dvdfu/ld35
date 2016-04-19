local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
local Vector = require('modules/hump/vector')

local Boost = Class('Boost')

local animations = {}
local sprites = {
    boost = love.graphics.newImage('res/images/boost.png'),
    feather = love.graphics.newImage('res/images/feather.png')
}
local grid = Anim8.newGrid(128, 64, 128 * 8, 64)
animations.feather = Anim8.newAnimation(grid:getFrames('1-8', 1), 0.2)

function Boost:initialize(x, y, player, camera)
    self.pos = Vector(x, y)
    self.player = player
    self.camera = camera
    self.body = HC.rectangle(x, y, 60, 24) -- HC.circle(x, y, 24)
    self.dead = false
end

function Boost:update(dt)
    self.pos = self.pos + Vector(0, 1)
    self.body:moveTo(self.pos:unpack())

    local collides, _, _ = self.body:collidesWith(self.player.body)
    if collides then
        --collision logic
        -- self.camera:shake(10, 0.5, {})
        self.player:boost()
        self.dead = true
    end
end

function Boost:draw()
    animations.feather:draw(sprites.feather, self.pos.x, self.pos.y, 0, 1, 1, 64, 48)
    if DEBUG then
        self.body:draw('line')
    end
end

function Boost:updateFeatherAnimation()
    animations.feather:update(1 / 60)
end

return Boost
