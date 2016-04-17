require('global')
local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Anim8 = require('modules/anim8/anim8')
local Vector = require('modules/hump/vector')
local Boost = require('boost')
local Player = require('player')
local Background = require('background')
local Foreground = require('foreground')
local Camera = require('modules/hump/camera')

Particles = require('particles')

--============================================================================== GAME
local Game = Class('Game')
Game:include(Stateful)
Game.Title = Game:addState('Title')
Game.Play = Game:addState('Play')
Game.End = Game:addState('End')

function Game:initialize()
    Particles.initialize()

    self.player = Player:new(0, 0)
    self.camera = Camera(0, 0)
    self.foreground = Foreground:new(self.player, self.camera)
    self.background = Background:new(self.player, self.foreground, self.camera)

    self:gotoState('Title')
end

function Game:update(dt)
    self.background:update(dt)
    self.player:update(dt)
    self.foreground:update(dt)
end

function Game:draw()
    self.camera:attach()

    self.background:draw()
    self.player:draw()
    self.foreground:draw()

    self.camera:detach()
end

--============================================================================== GAME.TITLE
local title, titleToPitcher, pitching, pitchToBatter, pitcherToPlay = 0, 1, 2, 3
function Game.Title:enteredState()
    local grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 6, Player.SIZE)
    self.ballImage = love.graphics.newImage('res/images/baseball.png')
    self.ballStill = Anim8.newAnimation(grid:getFrames('1-6', 1), Player.Ball.animationTime)

    -- TODO: Add the pitcher image
    -- grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 6, Player.SIZE)
    -- self.pitcherImage = love.graphics.newImage('res/images/baseball.png')
    -- self.pitcherAnimation = Anim8.newAnimation(grid:getFrames('1-6', 1), Player.Ball.animationTime)

    self.groundHeight = self.player.absolutePos.y + 80

    self.gameLogo = love.graphics.newImage("res/images/logo.png")
    self.gameTitleScreenOffset = Screen.targetH * 2
    self.gameLogoHeight = self.player.absolutePos.y - self.gameTitleScreenOffset + 40
    self.camera:lookAt(self.player.absolutePos.x + Screen.targetW / 2, -self.gameTitleScreenOffset + Screen.targetH)

    self.cameraTimer = nil
    self.cameraMoveState = title
end

function Game.Title:update(dt)
    Game.update(self, dt)
    -- Debug('INTRO HEIGHTS', self.gameLogoHeight .. ' | ' .. self.ballY .. ' -> ' .. self.player.absolutePos.y .. ', step = ' .. self.ballYStep)

    if Input.pressed('return') and self.cameraMoveState == title then
        self.cameraMoveState = titleToPitcher
        self.cameraTimer = Timer.new()
        self.cameraTimer.after(0.01,
            function(func)
                x, y = self.camera:cameraCoords(self.player.absolutePos:unpack())

                if y > Screen.targetH / 2 then
                    self.camera:move(0, dt * 200)

                    if y < Screen.targetH / 2 then
                        self.camera:lookAt(self.player.absolutePos.x + Screen.targetW / 2, self.player.absolutePos.y + Screen.targetH / 2)
                        self.cameraMoveState = pitchToBatter
                    else
                        self.cameraTimer.after(0.01, func)
                    end
                else
                    self.cameraMoveState = pitching
                end
            end)
    elseif self.cameraMoveState == pitching then
        self.cameraMoveState = pitchToBatter
        self.player.vel = Vector(-10, 0)
        self.player.intro = false
        self.cameraTimer.after(2,
            function()
                self.player.vel = Vector(10, -10)
                self.cameraTimer.after(0.01,
                    function(func)
                        x, y = self.camera:cameraCoords(0, self.groundHeight)

                        if (y < Screen.targetH) then
                            self.groundHeight = self.groundHeight - self.player.vel.y
                            self.cameraTimer.after(0.01, func)
                        else
                            self.cameraMoveState = pitcherToPlay
                        end
                    end)
            end)
    elseif self.cameraMoveState == pitcherToPlay then
        self:gotoState('Play')
    end

    if self.cameraTimer then
        self.cameraTimer.update(dt)
    end
end

function Game.Title:draw()
    Game.draw(self)

    self.camera:attach()

    if (self.player.intro) then
        love.graphics.draw(self.gameLogo, self.player.absolutePos.x - self.gameLogo:getWidth() / 2, self.gameLogoHeight)

        love.graphics.printf("UP and DOWN to control angle", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 40, Screen.targetW, 'center')
        love.graphics.printf("SPACE to transform", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 60, Screen.targetW, 'center')
        love.graphics.printf("Press ENTER to START!", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 80, Screen.targetW, 'center')

        self.ballStill:draw(self.ballImage, self.player.absolutePos.x, self.player.absolutePos.y, self.player.vel:angleTo(), 1, 1, Player.SIZE / 2, Player.SIZE / 2)
    end

    love.graphics.setColor(172, 138, 101)
    love.graphics.rectangle('fill', -Screen.targetW / 2, self.groundHeight, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)

    self.camera:detach()
end

--============================================================================== GAME.PLAY
function Game.Play:enteredState()
    Debug('GAME.PLAY', 'Play enteredState.')
    self.player.userHasControl = true
    self.boosts = {}
end

function Game.Play:update(dt)
    Game.update(self, dt)

    for k, boost in pairs(self.boosts) do
        if boost.dead then
            table.remove(self.boosts, k)
        else
            boost:update(dt)
        end
    end
end

function Game.Play:draw()
    Game.draw(self)

    self.camera:attach()
    for _, boost in pairs(self.boosts) do
        boost:draw()
    end
    self.camera:detach()
end

return Game
