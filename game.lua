require('global')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Player = require('player')
local Background = require('background')

Particles = require('particles')

local Game = Class('Game')
Game:include(Stateful)
Game.Title = Game:addState('Title')
Game.Play = Game:addState('Play')
Game.End = Game:addState('End')

--============================================================================== LOCAL VARIABLES
local playerHeight = 0

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
    self.background = Background:new(self.player )
end

function Game.Play:update(dt)
    Game.update(self, dt)

    local unitVector = self.player.vel:normalized()

    self.player:update(dt)
    playerHeight = playerHeight - self.player.vel.y

    self.background:update(dt)
end

function Game.Play:draw()
    love.graphics.setColor(80, 100, 120)
    love.graphics.rectangle('fill', 0, 0, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)

    self.player:draw()
    self.background:draw()
end

return Game
