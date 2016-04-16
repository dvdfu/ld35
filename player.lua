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
    spinning = love.graphics.newImage('res/images/baseball.png')
}

--============================================================================== PLAYER
function Player:initialize(x, y)
    self.pos = Vector(x, y)
    self.vel = Vector(10, -10)

    local grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 6, Player.SIZE)
    self.animation = Anim8.newAnimation(grid:getFrames('1-6', 1), 0.05)
    self.sprite = sprites.spinning

    self:gotoState('Ball')
end

function Player:update(dt)
	self.vel.y = self.vel.y + 9.8 * dt
    self.animation:update(dt)
end

function Player:draw()
    self.animation:draw(self.sprite, self.pos.x, self.pos.y, 0, 1, 1, Player.SIZE / 2, Player.SIZE / 2)
end

--============================================================================== PLAYER.BALL

return Player
