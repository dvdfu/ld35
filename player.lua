local Anim8 = require('modules/anim8/anim8')
local Class = require('modules/middleclass/middleclass')
local HC = require('modules/HC')
local Stateful = require('modules/stateful/stateful')
local Vector = require('modules/hump/vector')

local animations = {}
local sprites = {
    ball = love.graphics.newImage('res/images/baseball.png'),
    ballShadow = love.graphics.newImage('res/images/baseball_shadow.png'),
    bird = love.graphics.newImage('res/images/bird.png'),
    birdToBall = love.graphics.newImage('res/images/bird_transform.png'),
    fireTrail = love.graphics.newImage('res/images/fire_trail.png')
}

--============================================================================== PLAYER
local Player = Class('Player')
Player:include(Stateful)
Player.Ball = Player:addState('Ball')
Player.Bird = Player:addState('Bird')
Player.BirdToBall = Player:addState('BirdToBall')
Player.BallToBird = Player:addState('BallToBird')

Player.SIZE = 16

Player.ballAngularSpeed = 0.03
Player.ballMinimumSpeed = 4

Player.birdFallSpeedX = 3
Player.birdFallSpeedY = 3
Player.birdFlappySpeedX = 3
Player.birdFlappySpeedY = -4
Player.birdFlappyDecayRateX = 0.1
Player.birdFlappyDecayRateY = 0.15

Player.Ball.animationTime = 0.05
Player.Bird.animationTime = 0.1
Player.BirdToBall.animationTime = 0.1
Player.BallToBird.animationTime = Player.BirdToBall.animationTime

Player.STATE = { BIRD = 0, BALL = 1, DEAD = 2 }

function Player:initialize(x, y)
    self.pos = Vector(0, 0)
    self.vel = Vector(x, y)
    self.body = HC.circle(self.pos.x, self.pos.y, 8)
    self.intro = true
    self.userCanTurn = false
    self.userCanTransform = true
    self.fallSpeed = 1

    local grid = nil
    grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 6, Player.SIZE)
    animations.ball = Anim8.newAnimation(grid:getFrames('1-6', 1), Player.Ball.animationTime)

    grid = Anim8.newGrid(24, 24, 24 * 4, 24)
    animations.bird = Anim8.newAnimation(grid:getFrames('1-4', 1), Player.Bird.animationTime, 'pauseAtEnd')

    grid = Anim8.newGrid(24, 24, 24 * 6, 24)
    animations.birdToBall = Anim8.newAnimation(grid:getFrames('1-6', 1), Player.BirdToBall.animationTime, function()
            self.state = Player.STATE.BALL
            self:gotoState('Ball')
        end)

    animations.ballToBird = Anim8.newAnimation(grid:getFrames('6-1', 1), Player.BallToBird.animationTime, function()
            self.state = Player.STATE.BIRD
            self:gotoState('Bird')
        end)

    grid = Anim8.newGrid(80, 24, 80 * 3, 24)
    animations.fireTrail = Anim8.newAnimation(grid:getFrames('1-3', 1), 0.05)

    self.state = Player.STATE.BALL
    self:gotoState('Ball')
end

function Player:update(dt)
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
    self.body:moveTo(self.pos:unpack())
end

function Player:draw()
    if not self.intro then
        Particles.update('fire', 1 / 60)
        love.graphics.push()
        love.graphics.translate(self.pos:unpack())
        Particles.draw('fire')
        love.graphics.pop()

        if DEBUG then
            r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(255, 0, 0, 255)
            love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.vel.x * 5, self.pos.y + self.vel.y * 5)
            love.graphics.setColor(r, g, b, a)
        end
    end
end

function Player:boost()
    self.vel = Vector(20,-20)

    SFX.sweep:play()

    if self.state == Player.STATE.BIRD then
        self:gotoState('BirdToBall')
    else
        self:gotoState('Ball')
    end
end

function Player:gotoSpeed()
    if self.state == Player.STATE.BALL then
        local tolerance = 3
        local rate = 0.0075

        if math.abs(self.vel:len() - Player.ballMinimumSpeed) <= tolerance then
            self:gotoState('BallToBird')
        end

        if self.vel:len() < Player.ballMinimumSpeed then
            self.vel = self.vel * (1 + rate)
        elseif self.vel:len() > Player.ballMinimumSpeed then
            self.vel = self.vel * (1 - rate)
        end
    elseif self.state == Player.STATE.BIRD then
        if self.vel.y < Player.birdFallSpeedY then
            self.vel.y = self.vel.y + Player.birdFlappyDecayRateY
        elseif self.vel.y > Player.birdFallSpeedY then
            self.vel.y = self.vel.y - Player.birdFlappyDecayRateY
        end
        if self.vel.x < Player.birdFallSpeedX then
            self.vel.x = self.vel.x + Player.birdFlappyDecayRateX
        elseif self.vel.x > Player.birdFallSpeedX then
            self.vel.x = self.vel.x - Player.birdFlappyDecayRateX
        end
    end
end

function Player:getHeight()
    return -self.pos.y
end

function Player:prepareLanding()
    self.userCanTurn = false
    self.userCanTransform = false
    self.vel = Vector(20, -20)
    self:gotoState('Ball')
end

function Player:halt()
    self.state = Player.STATE.DEAD
    self.vel = Vector(0, 0)
    self:gotoState('Ball')
end


--============================================================================== PLAYER.BALL
function Player.Ball:enteredState()
    Particles.get('fire'):reset()
end

function Player.Ball:update(dt)
    if Input.isDown('up') and self.userCanTurn then
        if self.vel:angleTo() > -math.pi / 2 then
            self.vel:rotateInplace(-Player.ballAngularSpeed)
        end
    elseif Input.isDown('down') and self.userCanTurn then
        if self.vel:angleTo() < math.pi / 2 then
            self.vel:rotateInplace(Player.ballAngularSpeed)
        end
    end
    Player.update(self, dt)
    Player.gotoSpeed(self)

    if self.userCanTurn then
        local fire = Particles.get('fire')
        fire:setDirection(self.vel:angleTo(Vector(-1, 0)))
        fire:setSpeed(self.vel:len() * 8, self.vel:len() * 40)
        Particles.emit('fire', 0, 0, self.vel:len() / 3)
    end

    if DEBUG and Input.pressed('t') then
        self:gotoState('BallToBird')
    end
end

function Player.Ball:draw()
    if not self.intro then
        Player.draw(self)

        animations.ball:update(self.vel:len() / 1000)
        animations.ball:draw(sprites.ball, self.pos.x, self.pos.y, self.vel:angleTo(), 1, 1, Player.SIZE / 2, Player.SIZE / 2)

        love.graphics.setBlendMode('multiply')
        love.graphics.draw(sprites.ballShadow, self.pos.x, self.pos.y, 0, 1, 1, Player.SIZE / 2, Player.SIZE / 2)
        love.graphics.setBlendMode('alpha')
    end
end

--============================================================================== PLAYER.BIRD
function Player.Bird:enteredState()

end

function Player.Bird:update(dt)
    Player.update(self, dt)
    Player.gotoSpeed(self)

    if self.userCanTransform and Input.pressed('up') then
        self.vel = Vector(Player.birdFlappySpeedX, Player.birdFlappySpeedY)
        animations.bird:pauseAtStart()
        animations.bird:resume()
        SFX.flap:play()
    end

    if DEBUG and Input.pressed('t') then
        self:boost()
    end
end

function Player.Bird:draw()
    if not self.intro then
        Player.draw(self)

        animations.bird:update(1 / 60)
        animations.bird:draw(sprites.bird, self.pos.x, self.pos.y, 0, 1, 1, 12, 12)
    end
end

function Player.Bird:prepareLanding()
    Player.prepareLanding(self)
    self:gotoState('BirdToBall')
end

--============================================================================== PLAYER.BIRDUP
function Player.BirdToBall:update(dt)
    Player.update(self, dt)
    Player.gotoSpeed(self)
    animations.birdToBall:update(dt)
    if Input.isDown('up') and self.userCanTurn then
        if self.vel:angleTo() > -math.pi / 2 then
            self.vel:rotateInplace(-Player.ballAngularSpeed)
        end
    elseif Input.isDown('down') and self.userCanTurn then
        if self.vel:angleTo() < math.pi / 2 then
            self.vel:rotateInplace(Player.ballAngularSpeed)
        end
    end
end

function Player.BirdToBall:draw()
    if not self.intro then
        Player.draw(self)
        animations.birdToBall:draw(sprites.birdToBall, self.pos.x, self.pos.y, 0, 1, 1, 12, 12)
    end
end

--============================================================================== PLAYER.BIRDDOWN
function Player.BallToBird:update(dt)
    Player.update(self, dt)
    Player.gotoSpeed(self)
    animations.ballToBird:update(dt)
end

function Player.BallToBird:draw()
    if not self.intro then
        Player.draw(self)
        animations.ballToBird:draw(sprites.birdToBall, self.pos.x, self.pos.y, 0, 1, 1, 12, 12)
    end
end

function Player.BallToBird:prepareLanding()
    Player.prepareLanding(self)
    self:gotoState('Ball')
end

return Player
