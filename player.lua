local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Vector = require('modules/hump/vector')

local Player = Class('Player')
Player:include(Stateful)
Player.SIZE = 16
Player.Ball = Player:addState('Ball')
Player.Ball = Player:addState('Bird')

local sprites = {
    ball = love.graphics.newImage('res/images/baseball.png'),
    bird = love.graphics.newImage('res/images/bird.png'),
    fireTrail = love.graphics.newImage('res/images/fire_trail.png')
}

local animations = {}

--============================================================================== PLAYER
function Player:initialize(x, y)
    self.pos = Vector(x, y)
    self.vel = Vector(10, 0)

    local grid = nil
    grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 6, Player.SIZE)
    animations.ball = Anim8.newAnimation(grid:getFrames('1-6', 1), 0.05)

    grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 4, Player.SIZE)
    animations.bird = Anim8.newAnimation(grid:getFrames('1-4', 1), 0.05)

    grid = Anim8.newGrid(80, 24, 80 * 3, 24)
    animations.fireTrail = Anim8.newAnimation(grid:getFrames('1-3', 1), 0.1)

    self.sprite = sprites.bird
    self:gotoState('Ball')
end

function Player:update(dt)
    self.vel.y = self.vel.y + dt * 0

    Particles.get('fire'):setDirection(self.vel:angleTo(Vector(-1, 0)))
    Particles.emit('fire', self.pos.x, self.pos.y, 4)
end

function Player:draw()
    Particles.update('fire', 1 / 60)
	Particles.draw('fire')

	animations.fireTrail:update(1 / 60)
	animations.fireTrail:draw(sprites.fireTrail, self.pos.x, self.pos.y, self.vel:angleTo(), 1, 1, 68, 12)

	animations.ball:update(1 / 60)
    animations.ball:draw(sprites.ball, self.pos.x, self.pos.y, self.vel:angleTo(), 1, 1, Player.SIZE / 2, Player.SIZE / 2)

    -- r, g, b, a = love.graphics.getColor()
    -- love.graphics.setColor(255, 0, 0, 255)
    -- love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.vel.x * 5, self.pos.y + self.vel.y * 5)
    -- love.graphics.setColor(r, g, b, a)
end

--============================================================================== PLAYER.BALL

return Player
