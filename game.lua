local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
Particles = require('particles')

local Game = Class('Game')
Game:include(Stateful)
Game.Title = Game:addState('Title')
Game.Play = Game:addState('Play')
Game.End = Game:addState('End')

local function debug(tag, message)
    print(tag .. ' | ' .. message)
end

function Game:initialize()
    debug('GAME', 'Game initialize.')
    Particles.initialize()
    self:gotoState('Title')
end

function Game.Title:enteredState()
    debug('GAME.TITLE', 'Title enteredState.')
end

function Game.Title:draw()
    love.graphics.print('GAME.TITLE | Title draw.', 100, 100)
    Particles.draw('cloud')
end

function Game.Title:update(dt)
    Particles.emit('cloud', 160, 160, 5)
    Particles.update('cloud', dt)
end

return Game
