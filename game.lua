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

    self.player = Player:new(0,0)
    self.foreground = Foreground:new(self.player)
    self.background = Background:new(self.player, self.foreground)

    self:gotoState('Title')
end

function Game:update(dt)
    self.background:update(dt)
    self.player:update(dt)
    self.foreground:update(dt)
end

function Game:draw()
    self.background:draw()
    self.player:draw()
    self.foreground:draw()
end

--============================================================================== GAME.TITLE
local title, titleToPitcher, pitchToBatter, pitcherToPlay = 0, 1, 2, 3
function Game.Title:enteredState()
    Debug('GAME.TITLE', 'Title enteredState.')
    local grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 6, Player.SIZE)
    self.ballImage = love.graphics.newImage('res/images/baseball.png')
    self.ballStill = Anim8.newAnimation(grid:getFrames('1-6', 1), Player.Ball.animationTime)
    self.ballY = Screen.targetH + 200
    self.ballYStep = (self.player.absolutePos.y - self.ballY)/100

    -- TODO: Add the pitcher image
    -- grid = Anim8.newGrid(Player.SIZE, Player.SIZE, Player.SIZE * 6, Player.SIZE)
    -- self.pitcherImage = love.graphics.newImage('res/images/baseball.png')
    -- self.pitcherAnimation = Anim8.newAnimation(grid:getFrames('1-6', 1), Player.Ball.animationTime)

    self.groundHeight = self.ballY + 80

    self.gameLogo = love.graphics.newImage("res/images/logo.png")
    self.gameLogoHeight = Screen.targetH / 2 - self.gameLogo:getHeight()/2 - 40

    self.cameraTimer = nil
    self.cameraMoveState = title
end

function Game.Title:update(dt)
    Game.update(self, dt)
    Debug('INTRO HEIGHTS', self.gameLogoHeight .. ' | ' .. self.ballY .. ' -> ' .. self.player.absolutePos.y .. ', step = ' .. self.ballYStep)

    if Input.pressed('return') and self.cameraMoveState == title then
        self.cameraMoveState = titleToPitcher
        Debug('ENTER PRESSED', '')
        self.cameraTimer = Timer.new()
        self.cameraTimer.after(0.01,
            function(func)
                if (self.ballY > self.player.absolutePos.y) then
                    -- Debug('INTRO HEIGHTS', self.gameLogoHeight .. ', ' .. self.ballY)
                    self.ballY = self.ballY + self.ballYStep
                    self.gameLogoHeight = self.gameLogoHeight + self.ballYStep
                    self.groundHeight = self.groundHeight + self.ballYStep
                    self.cameraTimer.after(0.01, func)
                end
            end)
    elseif self.cameraMoveState == titleToPitcher and self.ballY <= self.player.absolutePos.y then
        self.cameraMoveState = pitchToBatter
        -- self.player.vel = Vector(10, -10)
        self.player.vel = Vector(-10, 0)
        self.player.intro = false
        self.cameraTimer.after(2,
            function()
                self.player.vel = Vector(10, -10)
                self.cameraTimer.after(0.01,
                    function(func)
                        if (self.groundHeight < Screen.targetH) then
                            self.groundHeight = self.groundHeight - self.player.vel.y
                            self.cameraTimer.after(0.01, func)
                        else
                            self.cameraTimer = nil
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
    if (self.player.intro) then
        love.graphics.draw(self.gameLogo, Screen.targetW / 2 - self.gameLogo:getWidth()/2, self.gameLogoHeight)
        love.graphics.printf("UP and DOWN to control angle", 0, self.gameLogoHeight + 120, Screen.targetW, 'center')
        love.graphics.printf("SPACE to transform", 0, self.gameLogoHeight + 140, Screen.targetW, 'center')
        love.graphics.printf("Press ENTER to START!", 0, self.gameLogoHeight + 180, Screen.targetW, 'center')
        self.ballStill:draw(self.ballImage, self.player.absolutePos.x, self.ballY, self.player.vel:angleTo(), 1, 1, Player.SIZE / 2, Player.SIZE / 2)
    end
    love.graphics.setColor(172, 138, 101)
    love.graphics.rectangle('fill', 0, self.groundHeight, Screen.targetW, Screen.targetH)
    love.graphics.setColor(255, 255, 255)
    -- love.graphics.print('GAME TITLE GOES HERE', Screen.targetW / 2 - 80, Screen.targetH / 2 - 10)
end

--============================================================================== GAME.PLAY
function Game.Play:enteredState()
    Debug('GAME.PLAY', 'Play enteredState.')
    self.player.userCanTurn = true
end

function Game.Play:update(dt)
    Game.update(self, dt)
end

function Game.Play:draw()
    Game.draw(self)
end

return Game
