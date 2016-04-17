local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Vector = require('modules/hump/vector')

local Player = Class('Player')
Player:include(Stateful)
Player.SIZE = 16
Player.Ball = Player:addState('Ball')
Player.Bird = Player:addState('Bird')

local sprites = {
    ball = love.graphics.newImage('res/images/baseball.png'),
    ballShadow = love.graphics.newImage('res/images/baseball_shadow.png'),
    bird = love.graphics.newImage('res/images/bird.png'),
    fireTrail = love.graphics.newImage('res/images/fire_trail.png')
}

local animations = {}

local properties = {
    ball = {
        speed = 10
    },

    bird = {
        speed = 2
    }
}

--============================================================================== PLAYER
function Player:initialize(x, y)
    self.pos = Vector(x, y)
    self.vel = Vector(10, 0)

    local grid = nil
    grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 6, Player.SIZE)
    animations.ball = Anim8.newAnimation(grid:getFrames('1-6', 1), 0.05)

    grid = Anim8.newGrid(24, 24, 24 * 4, 24)
    animations.bird = Anim8.newAnimation(grid:getFrames('1-4', 1), 0.05)

    grid = Anim8.newGrid(80, 24, 80 * 3, 24)
    animations.fireTrail = Anim8.newAnimation(grid:getFrames('1-3', 1), 0.05)

    self:gotoState('Ball')
end

function Player:update(dt)
    if Input.isDown('up') then
        self.vel:rotateInplace(-0.02)
    elseif Input.isDown('down') then
        self.vel:rotateInplace(0.02)
    end
end

function Player:draw()
    Particles.update('fire', 1 / 60)
    Particles.draw('fire')
    -- r, g, b, a = love.graphics.getColor()
    -- love.graphics.setColor(255, 0, 0, 255)
    -- love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.vel.x * 5, self.pos.y + self.vel.y * 5)
    -- love.graphics.setColor(r, g, b, a)
end

--============================================================================== PLAYER.BALL
function Player.Ball:enteredState()
    Particles.get('fire'):reset()
end

function Player.Ball:update(dt)
    Player.update(self, dt)

    if self.vel:len() < properties.ball.speed then
        self.vel = self.vel * 1.1
    elseif self.vel:len() > properties.ball.speed then
        self.vel = self.vel:normalized() * properties.ball.speed
    end

    Particles.get('fire'):setDirection(self.vel:angleTo(Vector(-1, 0)))
    Particles.emit('fire', self.pos.x, self.pos.y, 4)

    if Input.pressed('space') then
        self:gotoState('Bird')
    end
end

function Player.Ball:draw()
    Player.draw(self)

    -- animations.fireTrail:update(1 / 60)
    -- animations.fireTrail:draw(sprites.fireTrail, self.pos.x, self.pos.y, self.vel:angleTo(), 1, 1, 68, 12)

    animations.ball:update(1 / 60)
    animations.ball:draw(sprites.ball, self.pos.x, self.pos.y, self.vel:angleTo(), 1, 1, Player.SIZE / 2, Player.SIZE / 2)

    love.graphics.setBlendMode('multiply')
    love.graphics.draw(sprites.ballShadow, self.pos.x, self.pos.y, 0, 1, 1, Player.SIZE / 2, Player.SIZE / 2)
    love.graphics.setBlendMode('alpha')
end

--============================================================================== PLAYER.BIRD
function Player.Bird:enteredState()

end

function Player.Bird:update(dt)
    Player.update(self, dt)

    if self.vel:len() > properties.bird.speed then
        self.vel = self.vel * 0.9
    elseif self.vel:len() < properties.bird.speed then
        self.vel = self.vel:normalized() * properties.bird.speed
    end

    if Input.pressed('space') then
        self:gotoState('Ball')
    end
end

function Player.Bird:draw()
    Player.draw(self)

    animations.bird:update(1 / 60)
    animations.bird:draw(sprites.bird, self.pos.x, self.pos.y, self.vel:angleTo(), 1, 1, 12, 12)
end

return Player
