require('global')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
Particles = require('particles')

local Game = Class('Game')
Game:include(Stateful)
Game.Title = Game:addState('Title')
Game.Play = Game:addState('Play')
Game.End = Game:addState('End')

--============================================================================== LOCAL FUNCTIONS
local Player = require('player')
local Star = require('star')

--============================================================================== GAME
function Game:initialize()
    Debug('GAME', 'Game initialize.')

    Particles.initialize()

    self:gotoState('Title')
end

function Game:update(dt) end

--============================================================================== GAME.TITLE
function Game.Title:enteredState()
    Debug('GAME.TITLE', 'Title enteredState.')
end

function Game.Title:update(dt)
    Game.update(self, dt)
    Debug('GAME.TITLE', 'Title update.')

    if Input.pressed('return') then
        self:gotoState('Play')
    end
end

function Game.Title:draw()
    love.graphics.print('GAME TITLE GOES HERE', Screen.targetW / 2 - 80, Screen.targetH / 2 - 10)
end

--============================================================================== GAME.PLAY
function Game.Play:enteredState()
    Debug('GAME.PLAY', 'Play enteredState.')
    self.player = Player:new(Screen.targetW / 2, Screen.targetH / 2)
    self.stars = {}
    self.starTimer = Timer.new()
    self.starTimer.every(0.1,
        function()
            self:generateStar()
            self:generateStar()
            self:generateStar()
        end)
end

function Game.Play:update(dt)
    Game.update(self, dt)
    Debug('GAME.PLAY', 'Play update.')

    local unitVector = self.player.vel:normalized()
    Debug('PLAYER', unitVector.x .. ', ' .. unitVector.y)

    self.player:update(dt)
    for k, star in pairs(self.stars) do
        if star.pos.x >= 2 * Screen.targetW or star.pos.x <= -2 * Screen.targetW or star.pos.y >= 2 * Screen.targetH or star.pos.y <= -2 * Screen.targetH then
            table.remove(self.stars, k)
        else
            star:update(dt)
        end
    end
    for k, star in pairs(self.stars) do
        Debug('STAR' .. k, star.pos.x .. ', ' .. star.pos.y)
    end
    self.starTimer.update(dt)
end

function Game.Play:draw()
    Debug('GAME.PLAY', 'Play draw.')

    love.graphics.setColor(80, 100, 120)
    love.graphics.rectangle('fill', 0, 0, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)
    for k, star in pairs(self.stars) do
        star:draw()
    end
    self.player:draw()
end

function Game.Play:generateStar()
    local unitVector = self.player.vel:normalized()
    local x = math.random(1, Screen.targetW) + unitVector.x * Screen.targetW
    local y = math.random(1, Screen.targetH) + unitVector.y * Screen.targetH
    local z = math.random(1, 3)
    table.insert(self.stars, Star:new(x, y, z, self.player))
end

return Game
