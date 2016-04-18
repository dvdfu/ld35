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

--============================================================================== GAME
local Game = Class('Game')
Game:include(Stateful)
Game.Title = Game:addState('Title')
Game.Play = Game:addState('Play')
Game.End = Game:addState('End')

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

        love.graphics.setFont(FONT.babyblue)
        love.graphics.printf("UP and DOWN to control angle", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 40, Screen.targetW, 'center')
        love.graphics.printf("SPACE to transform", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 60, Screen.targetW, 'center')
        love.graphics.printf("Press ENTER to START!", -Screen.targetW / 2, self.gameLogoHeight + self.gameLogo:getHeight() + 80, Screen.targetW, 'center')
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
end

function Game.End:update(dt)
    Game.update(self, dt)
    if Input.pressed('return') then
        self:startup()
        self:gotoState('Title')
    end
end

function Game.End:draw()
    Game.draw(self)
    love.graphics.setFont(FONT.babyblue)
    love.graphics.printf("GAME OVER", 0, Screen.targetH / 2 + 70, Screen.targetW, 'center')
    love.graphics.printf("Press ENTER to play again!", 0, Screen.targetH / 2 + 90, Screen.targetW, 'center')
end

return Game
