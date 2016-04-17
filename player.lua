local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
local Stateful = require('modules/stateful/stateful')
local Vector = require('modules/hump/vector')

local Player = Class('Player')
Player:include(Stateful)
Player.SIZE = 16
Player.Ball = Player:addState('Ball')
Player.Bird = Player:addState('Bird')
Player.BirdToBall = Player:addState('BirdToBall')
Player.BallToBird = Player:addState('BallToBird')

local sprites = {
    ball = love.graphics.newImage('res/images/baseball.png'),
    ballShadow = love.graphics.newImage('res/images/baseball_shadow.png'),
    bird = love.graphics.newImage('res/images/bird.png'),
    birdToBall = love.graphics.newImage('res/images/bird_transform.png'),
    fireTrail = love.graphics.newImage('res/images/fire_trail.png')
}

local animations = {}

Player.Ball.speed = 10
Player.Ball.animationTime = 0.05

Player.Bird.speed = 2
Player.Bird.animationTime = 0.1

Player.BirdToBall.speed = Player.Ball.speed
Player.BirdToBall.animationTime = 0.1

Player.BallToBird.speed = Player.Bird.speed
Player.BallToBird.animationTime = Player.BirdToBall.animationTime

--============================================================================== PLAYER
function Player:initialize(x, y)
    self.pos = Vector(x, y)
    self.vel = Vector(2, 0)
    self.body = HC.circle(x, y, 8)

    local grid = nil
    grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 6, Player.SIZE)
    animations.ball = Anim8.newAnimation(grid:getFrames('1-6', 1), Player.Ball.animationTime)

    grid = Anim8.newGrid(24, 24, 24 * 4, 24)
    animations.bird = Anim8.newAnimation(grid:getFrames('1-4', 1), Player.Bird.animationTime)

    grid = Anim8.newGrid(24, 24, 24 * 6, 24)
    animations.birdToBall = Anim8.newAnimation(grid:getFrames('1-6', 1), Player.BirdToBall.animationTime, function()
            self:gotoState('Ball')
        end)

    animations.ballToBird = Anim8.newAnimation(grid:getFrames('6-1', 1), Player.BallToBird.animationTime, function()
            self:gotoState('Bird')
        end)

    grid = Anim8.newGrid(80, 24, 80 * 3, 24)
    animations.fireTrail = Anim8.newAnimation(grid:getFrames('1-3', 1), 0.05)

    self:gotoState('Bird')
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

function Player:boost()
    self.vel = self.vel:normalized() * 50
end

function Player:gotoSpeed()
    local tolerance = 0.01
    local rate = 0.025

    if math.abs(self.vel:len() - self.speed) <= tolerance then
        self.vel = self.vel:normalized() * self.speed
    end

    if self.vel:len() < self.speed then
        self.vel = self.vel * (1 + rate)
    elseif self.vel:len() > self.speed then
        self.vel = self.vel * (1 - rate)
    end
end

--============================================================================== PLAYER.BALL
function Player.Ball:enteredState()
    Particles.get('fire'):reset()
end

function Player.Ball:update(dt)
    Player.update(self, dt)
    Player.gotoSpeed(self)

    local fire = Particles.get('fire')
    fire:setDirection(self.vel:angleTo(Vector(-1, 0)))
    fire:setSpeed(self.vel:len() * 8, self.vel:len() * 40)
    Particles.emit('fire', self.pos.x, self.pos.y, 4)

    if Input.pressed('space') then
        self:gotoState('BallToBird')
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
    Player.gotoSpeed(self)

    if Input.pressed('space') then
        self:gotoState('BirdToBall')
    end
end

function Player.Bird:draw()
    Player.draw(self)

    animations.bird:update(1 / 60)
    animations.bird:draw(sprites.bird, self.pos.x, self.pos.y, self.vel:angleTo(), 1, 1, 12, 12)
end

--============================================================================== PLAYER.BIRDUP
function Player.BirdToBall:update(dt)
    Player.update(self, dt)
    Player.gotoSpeed(self)
end

function Player.BirdToBall:draw()
    Player.draw(self)

    animations.birdToBall:update(1 / 60)
    animations.birdToBall:draw(sprites.birdToBall, self.pos.x, self.pos.y, self.vel:angleTo(), 1, 1, 12, 12)
end

--============================================================================== PLAYER.BIRDDOWN
function Player.BallToBird:update(dt)
    Player.update(self, dt)
    Player.gotoSpeed(self)
end

function Player.BallToBird:draw()
    Player.draw(self)

    animations.ballToBird:update(1 / 60)
    animations.ballToBird:draw(sprites.birdToBall, self.pos.x, self.pos.y, self.vel:angleTo(), 1, 1, 12, 12)
end

return Player
