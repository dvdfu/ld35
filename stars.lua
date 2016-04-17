local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')
local Star = require('star')

local Stars = Class('Stars')

function Stars:initialize(player)
    self.player = player
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
        if star.pos.x >= 2 * Screen.targetW or star.pos.x <= -2 * Screen.targetW or star.pos.y >= 2 * Screen.targetH or star.pos.y <= -2 * Screen.targetH then
            table.remove(self.stars, k)
        else
            star:update(dt)
        end
    end
end

function Stars:draw()
    for k, star in pairs(self.stars) do
        star:draw()
    end

    if (DEBUG) then
        love.graphics.print('STARS: ' .. #self.stars, 150, Screen.targetH - 20)
    end
end

function Stars:generateStar()
    local unitVector = self.player.vel:normalized()
    local x = math.random(1, Screen.targetW) + unitVector.x * Screen.targetW
    local y = math.random(1, Screen.targetH) + unitVector.y * Screen.targetH
    table.insert(self.stars, Star:new(x, y, self.player))
end

return Stars
