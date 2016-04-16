require('global')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
Particles = require('particles')

local Game = Class('Game')
Game:include(Stateful)
Game.Title = Game:addState('Title')
Game.Play = Game:addState('Play')
Game.End = Game:addState('End')

--============================================================================== LOCAL FUNCTIONS
local Player = require('player')

--============================================================================== GAME
function Game:initialize()
    Debug('GAME', 'Game initialize.')

    Particles.initialize()
    self.player = Player:new(Screen.targetW / 2, Screen.targetH / 2)

    self:gotoState('Title')
end

function Game:update(dt)
    Debug('GAME', 'Game update.')
end

--============================================================================== GAME.TITLE
function Game.Title:enteredState()
    Debug('GAME.TITLE', 'Title enteredState.')
end

function Game.Title:update(dt)
    Debug('GAME.TITLE', 'Title update.')

    Game.update(self, dt)

    if love.keyboard.isDown('return') then
        self:gotoState('Play')
    end
end

function Game.Title:draw()
    love.graphics.print('GAME TITLE GOES HERE', Screen.targetW / 2 - 80, Screen.targetH / 2 - 10)
end

--============================================================================== GAME.PLAY
function Game.Play:enteredState()
    Debug('GAME.PLAY', 'Play enteredState.')
end

function Game.Play:update(dt)
    Debug('GAME.PLAY', 'Play update.')

    Game.update(self, dt)
    self.player:update(dt)
end

function Game.Play:draw()
    Debug('GAME.PLAY', 'Play draw.')

    self.player:draw()
end

return Game
