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

Song = {
    melody = love.audio.newSource('res/sound/music_melody.mp3'),
    backing = love.audio.newSource('res/sound/music_backing.mp3'),
    space = love.audio.newSource('res/sound/music_space.mp3'),
    title = love.audio.newSource('res/sound/music_title.mp3'),
    ending = love.audio.newSource('res/sound/music_end.mp3')
}

SFX = {
    sweep = love.audio.newSource('res/sound/sweep.mp3'),
    bat = love.audio.newSource('res/sound/bat.wav'),
    crashLanding = love.audio.newSource('res/sound/crash_landing.wav'),
    flap = love.audio.newSource('res/sound/flap.wav')
}

local sprites = {
    endingMoon = love.graphics.newImage('res/images/ending_moon.png'),
    endingFly = love.graphics.newImage('res/images/ending_fly.png'),
    endingBird = love.graphics.newImage('res/images/ending_bird.png'),
    endingDebris = love.graphics.newImage('res/images/ending_debris.png'),
    endingBubble = love.graphics.newImage('res/images/ending_bubble.png'),
    endingSpace = love.graphics.newImage('res/images/ending_space.png')
}

--============================================================================== GAME
local Game = Class('Game')
Game:include(Stateful)
Game.Title = Game:addState('Title')
Game.Play = Game:addState('Play')
Game.End = Game:addState('End')
Game.Cutscene = Game:addState('Cutscene')

function Game:startup()
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
end

function Game:initialize()
    Particles.initialize()

    self:startup()
    self:gotoState('Title')
end

function Game:update(dt)
    self.background:update(dt)
    self.player:update(dt)
    self.camera:zoomTo(math.max(self.player.pos.y / WORLD.spaceHeight + 1, 0.52118472042539))
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

    self.gameLogo = love.graphics.newImage("res/images/logo.png")
    local gameTitleScreenOffset = Screen.targetH * 1.5
    self.gameLogoHeight = -gameTitleScreenOffset + 40
    self.camTarget = Vector(0, -gameTitleScreenOffset + Screen.targetH / 2)
    self.camera:moveTo(self.camTarget.x, self.camTarget.y)

    self.titleTimer = 0
    self.cameraTimer = nil
    self.cameraMoveState = title

    Song.title:setLooping(true)
    Song.title:play()
    Song.melody:stop()
    Song.backing:stop()
    Song.space:stop()
    Song.ending:stop()
end

function Game.Title:update(dt)
    Game.update(self, dt)
    self.titleTimer = self.titleTimer + dt

    if self.cameraMoveState == title and Input.pressed('return') then
        Song.title:stop()
        self.cameraMoveState = titleToPitcher
        self.cameraTimer = Timer.new()
        self.camTarget = Vector(0, 0)
        self.cameraTimer.after(1, function(func)
                self.foreground.ground:startPitcher()
                self.cameraTimer.after(0.5, function()
                    self.cameraMoveState = pitching
                end)
            end)
    elseif self.cameraMoveState == pitching then
        self.cameraMoveState = pitchToBatter
        self.player.vel = Vector(-20, 0)
        self.player.intro = false
        self.cameraTimer.after(0.3, function()
            self.foreground.ground:startBatter()
        end)
        self.cameraTimer.after(0.5, function()
            self.player.vel = Vector(40, -40)
        end)
    elseif self.cameraMoveState == pitchToBatter then
        self.camTarget = Vector(self.player.pos.x, self.player.pos.y)

        local _, y = self.camera:toScreenCoordinates(0, INTRO.groundHeight)
        if (y >= Screen.targetH) then
            self.cameraMoveState = pitcherToPlay
        end
    elseif self.cameraMoveState == pitcherToPlay then
        SFX.bat:play()
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
        love.graphics.draw(self.gameLogo, -self.gameLogo:getWidth() / 2, self.gameLogoHeight + 4 * math.sin(self.titleTimer * 4))

        love.graphics.setFont(FONT.redalert)
        love.graphics.setColor(63, 63, 116)
        love.graphics.printf("As a bird, press UP to flag your wings", -Screen.targetW / 2,           self.gameLogoHeight + self.gameLogo:getHeight() + 30, Screen.targetW, 'center')
        love.graphics.printf("Collect feathers to transform!", -Screen.targetW / 2,                   self.gameLogoHeight + self.gameLogo:getHeight() + 43, Screen.targetW, 'center')
        love.graphics.printf("As a ball, use UP and DOWN to control your angle", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 56, Screen.targetW, 'center')
        love.graphics.printf("Press ENTER to START!", -Screen.targetW / 2,                            self.gameLogoHeight + self.gameLogo:getHeight() + 92, Screen.targetW, 'center')
        love.graphics.setColor(255, 255, 255)
    end

    self.camera:pop()
end

--============================================================================== GAME.PLAY
function Game.Play:enteredState()
    Debug('GAME.PLAY', 'Play enteredState.')
    self.player.userCanTurn = true
    self.player.vel = Vector(20,-20)
    self.player:boost()

    Song.melody:setLooping(true)
    Song.melody:play()
    Song.backing:setLooping(true)
    Song.backing:play()
    Song.backing:setVolume(0)
    Song.space:setLooping(true)
    Song.space:play()
    Song.space:setVolume(0)
end

function Game.Play:update(dt)
    Game.update(self, dt)
    self.camTarget = Vector(self.player.pos.x, self.player.pos.y)
    if (self.player.state == Player.STATE.DEAD) then
        self:gotoState('End')
    end
end

function Game.Play:draw()
    Game.draw(self)
end

--============================================================================== GAME.END
function Game.End:enteredState()
    Debug('GAME.END', 'End enteredState.')
    self.endTimer = Timer.new()
    self.endTimer.after(4, function()
        self:gotoState('Cutscene')
    end)
end

function Game.End:update(dt)
    Game.update(self, dt)
    self.endTimer.update(dt)
end

function Game.End:draw()
    Game.draw(self)
end

--============================================================================== GAME.CUTSCENE
function Game.Cutscene:enteredState()
    Debug('GAME.CUTSCENE', 'Cutscene enteredState.')
    self.cutsceneTimer = 0

    local grid = Anim8.newGrid(420, 280, 420 * 4, 280)
    self.flyAnimation = Anim8.newAnimation(grid:getFrames('1-4', 1), 0.3)
end

function Game.Cutscene:update(dt)
    self.cutsceneTimer = self.cutsceneTimer + dt
    self.flyAnimation:update(dt)
end

function Game.Cutscene:draw()
    if self.cutsceneTimer > 12 then
        love.graphics.draw(sprites.endingSpace)
        self.flyAnimation:draw(sprites.endingFly)

        love.graphics.setFont(FONT.redalert)
        love.graphics.setColor(63, 63, 116)
        love.graphics.print("Made by @dvdfu, Hamdan Javeed and Seikun Kambashi", 80, Screen.targetH / 2 + 60)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("Thank you for playing!", 80, Screen.targetH / 2 + 73)

    elseif self.cutsceneTimer > 8 then
        local a = self.cutsceneTimer - 8
        love.graphics.draw(sprites.endingBird)
        love.graphics.draw(sprites.endingDebris, Screen.targetW / 2, Screen.targetH / 2, 0, 1 + a / 32, 1 + a / 32, Screen.targetW / 2, Screen.targetH / 2)
    elseif self.cutsceneTimer > 4 then
        local a = (self.cutsceneTimer - 4) / 4

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', 0, 0, Screen.targetW, Screen.targetH)
        love.graphics.setColor(255, 255, 255, 255)

        love.graphics.draw(sprites.endingMoon, a * 6 * (math.random() - 0.5), a * 6 * (math.random() - 0.5))

        love.graphics.setBlendMode('add')
        love.graphics.setColor(200 * a, 230 * a, 255 * a, 255)
        love.graphics.rectangle('fill', 0, 0, Screen.targetW, Screen.targetH)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setBlendMode('alpha')
    else
        love.graphics.draw(sprites.endingMoon)
        if math.floor(self.cutsceneTimer * 4) % 4 > 0 then
            love.graphics.draw(sprites.endingBubble)
        end
    end
end

return Game
