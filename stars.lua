local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Star = require('star')

local Stars = Class('Stars')

function Stars:initialize(player, camera)
    self.player = player
    self.camera = camera
    self.stars = {}
    self.starsTimer = Timer.new()
    self.starsTimer.every(0.1,
        function()
            self:generateStar() self:generateStar() self:generateStar()
        end)
    -- Timer.after(0.1,
    --     function(func)
    --         self:generateStar() self:generateStar() self:generateStar()
    --         self:generateStar() self:generateStar() self:generateStar()
    --         Timer.after(self.player.vel:len() < 5 and 2 or 0.1, func)
    --     end)
end

function Stars:update(dt)
    self.starsTimer.update(dt)
    for k, star in pairs(self.stars) do
        if star.pos.x >= 2 * Screen.targetW + self.player.pos.x or star.pos.x <= -2 * Screen.targetW + self.player.pos.x or star.pos.y >= 2 * Screen.targetH + self.player.pos.y or star.pos.y <= -2 * Screen.targetH + self.player.pos.y then
            table.remove(self.stars, k)
        else
            star:update(dt)
        end
    end
end

function Stars:draw()
    for _, star in pairs(self.stars) do
        star:draw()
    end

    if (DEBUG) then
        self.camera:detach()
        love.graphics.print('STARS: ' .. #self.stars, 10, Screen.targetH - 50)
        self.camera:attach()
    end
end

function Stars:generateStar()
    local unitVector = self.player.vel:normalized()
    local x = math.random(1, Screen.targetW) + unitVector.x * Screen.targetW
    local y = math.random(1, Screen.targetH) + unitVector.y * Screen.targetH
    table.insert(self.stars, Star:new(x + self.player.pos.x - Screen.targetW / 2, y + self.player.pos.y - Screen.targetH / 2, self.player))
end

return Stars
