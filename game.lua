require('global')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Boost = require('boost')
local Player = require('player')
local Background = require('background')

Particles = require('particles')

--============================================================================== GAME
local Game = Class('Game')
Game:include(Stateful)
Game.Title = Game:addState('Title')
Game.Play = Game:addState('Play')
Game.End = Game:addState('End')

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
    self.player = Player:new()
    self.background = Background:new(self.player)
    self.boosts = {}
end

function Game.Play:update(dt)
    Game.update(self, dt)

    local unitVector = self.player.vel:normalized()

    self.background:update(dt)
    self.player:update(dt)

    for k, boost in pairs(self.boosts) do
        if boost.dead then
            table.remove(self.boosts, k)
        else
            boost:update(dt)
        end
    end
end

function Game.Play:draw()
    self.background:draw()
    self.player:draw()
    for _, boost in pairs(self.boosts) do
        boost:draw()
    end
end

return Game
