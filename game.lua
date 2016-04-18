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
local Camera = require('Camera')

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
    self.camera = Camera.new(0, 0, Screen.targetW, Screen.targetH)
    self.camTarget = Vector(0, 0)

    local scale = 1.0
    for i = 1, 2 do
        scale = scale - 0.1
        self.camera:addLayer(i .. '', scale)
    end

    self.foreground = Foreground:new(self.player, self.camera)
    self.background = Background:new(self.player, self.foreground, self.camera)

    self:gotoState('Title')
end

function Game:update(dt)
    self.background:update(dt)
    self.player:update(dt)
    self.camera:update(dt)
    self.foreground:update(dt)

    local d = self.camTarget - Vector(self.camera.x, self.camera.y)
    self.camera:move(d.x / 4, d.y / 4)
end

function Game:draw()
    self.camera:push()

    self.background:draw()
    self.player:draw()
    self.foreground:draw()

    self.camera:pop()
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

    self.gameLogo = love.graphics.newImage("res/images/logo.png")
    self.gameTitleScreenOffset = Screen.targetH * 2
    self.gameLogoHeight = -self.gameTitleScreenOffset + 40
    self.camTarget = Vector(0, -self.gameTitleScreenOffset + Screen.targetH / 2)

    self.cameraTimer = nil
    self.cameraMoveState = title
end

function Game.Title:update(dt)
    Game.update(self, dt)

    if Input.pressed('return') and self.cameraMoveState == title then
        self.cameraMoveState = titleToPitcher
        self.cameraTimer = Timer.new()
        self.cameraTimer.after(0.01,
            function(func)
                x, y = self.camera:toScreenCoordinates(0, 0)

                if y > Screen.targetH / 2 then
                    self.camTarget = Vector(0, dt * 200)

                    if y < Screen.targetH / 2 then
                        self.camTarget = Vector(Screen.targetW / 2, Screen.targetH / 2)
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
        self.player.vel = Vector(-Player.Ball.speed, 0)
        self.player.intro = false
        self.cameraTimer.after(2, function()
            self.player.vel = Vector(10, -10)
        end)
    elseif self.cameraMoveState == pitchToBatter then
        self.camTarget = Vector(self.player.pos.x, self.player.pos.y)

        _, y = self.camera:toScreenCoordinates(0, INTRO.groundHeight)
        if (y >= Screen.targetH) then
            self.cameraMoveState = pitcherToPlay
        end
    elseif self.cameraMoveState == pitcherToPlay then
        self:gotoState('Play')
    end

    if self.cameraTimer then
        self.cameraTimer.update(dt)
    end
end

function Game.Title:draw()
    Game.draw(self)

    self.camera:push()

    if (self.player.intro) then
        love.graphics.draw(self.gameLogo, -self.gameLogo:getWidth() / 2, self.gameLogoHeight)

        love.graphics.printf("UP and DOWN to control angle", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 40, Screen.targetW, 'center')
        love.graphics.printf("SPACE to transform", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 60, Screen.targetW, 'center')
        love.graphics.printf("Press ENTER to START!", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 80, Screen.targetW, 'center')

        self.ballStill:draw(self.ballImage, 0, 0, self.player.vel:angleTo(), 1, 1, Player.SIZE / 2, Player.SIZE / 2)
    end

    self.camera:pop()
end

--============================================================================== GAME.PLAY
function Game.Play:enteredState()
    Debug('GAME.PLAY', 'Play enteredState.')
    self.player.userCanTurn = true
    self.player:boost()
end

function Game.Play:update(dt)
    Game.update(self, dt)
    self.camTarget = Vector(self.player.pos.x, self.player.pos.y)
end

function Game.Play:draw()
    Game.draw(self)
end

return Game
