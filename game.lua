require('global')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')

local Game = Class('Game')
Game:include(Stateful)
Game.Title = Game:addState('Title')
Game.Play = Game:addState('Play')
Game.End = Game:addState('End')

--==============================================================================
-- LOCAL FUNCTIONS
--==============================================================================
local function debug(tag, message)
    print(tag .. ' | ' .. message)
end

--==============================================================================
-- GAME
--==============================================================================
function Game:initialize()
    debug('GAME', 'Game initialize.')
    self:gotoState('Title')
end

function Game:update(dt)
    debug('GAME', 'Game update.')
end

--==============================================================================
-- GAME.TITLE
--==============================================================================
function Game.Title:enteredState()
    debug('GAME.TITLE', 'Title enteredState.')
end

function Game.Title:draw()
    debug('GAME.TITLE', 'Title draw.')
    love.graphics.print('GAME TITLE GOES HERE', Screen.targetW/2-80, Screen.targetH/2-10)
end

function Game.Title:update(dt)
    debug('GAME.TITLE', 'Title update.')
    Game.update(self, dt)
    if love.keyboard.isDown('return') then
        self:gotoState('Play')
    end
end

--==============================================================================
-- GAME.PLAY
--==============================================================================
function Game.Play:enteredState()
    debug('GAME.PLAY', 'Play enteredState.')
end

function Game.Play:draw()
    debug('GAME.PLAY', 'Play draw.')
    love.graphics.print('GAME PLAY', Screen.targetW/2-40, Screen.targetH/2-10)
end

function Game.Play:update(dt)
    debug('GAME.PLAY', 'Play update.')
    Game.update(self, dt)
end

return Game
