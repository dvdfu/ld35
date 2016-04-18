local Class = require('modules/middleclass/middleclass')
local Stateful = require('modules/stateful/stateful')
local Timer = require('modules/hump/timer')

local Stars = Class('Stars')

function Stars:initialize(player, camera)
    self.player = player
    self.camera = camera

    self.starShader = love.graphics.newShader[[
        extern vec2 pos;
        extern vec2 vel;
        extern number scale;
        extern number lowHeight;
        extern number highHeight;

        number hash(number n) {
            return fract((1 + cos(n)) * 415.92653);
        }

        number hash2d(vec2 p) {
            float xHash = hash(p.x * 37.0);
            float yHash = hash(p.y * 57.0);
            return fract(xHash + yHash);
        }

        number isStar(vec2 sc, vec2 p) {
            vec2 res = vec2(15.0, 15.0);
            number star = hash2d((sc + floor(p)) / res);

            if (star >= 0.9997) {
                return star;
            } else {
                return 0.0;
            }
        }

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords);

            vec2 scaledPos = pos * scale;
            number star = isStar(screen_coords, scaledPos);
            for (number i = 0; i < length(vel) * scale; i += 0.2) {
                star += isStar(screen_coords, scaledPos + normalize(vel) * i);
            }

            number a = 0.0;
            if (star != 0.0) {
                a = (-pos.y - lowHeight)/(highHeight - lowHeight) * 0.8;
            }

            vec3 pix = pixel.rgb * star;
            return vec4(pix, a);
        }
    ]]

    self.starShader:send('lowHeight', WORLD.cloudHeight - 500)
    self.starShader:send('highHeight', WORLD.atmosphereHeight)
end

function Stars:update(dt)

end

function Stars:draw()
    self.starShader:send('pos', {self.player.pos.x, self.player.pos.y})
    self.starShader:send('vel', {self.player.vel.x, self.player.vel.y})
    self.starShader:send('scale', 1.0)
    self:drawStars()

    layer = self.camera:getLayer('1')
    self.starShader:send('scale', layer:getRelativeScale())
    self:drawStars()

    layer = self.camera:getLayer('2')
    self.starShader:send('scale', layer:getRelativeScale())
    self:drawStars()
end

function Stars:drawStars()
    love.graphics.setShader(self.starShader)
        love.graphics.rectangle('fill', self.camera.x - Screen.targetW / 2 / self.camera.scaleX, self.camera.y - Screen.targetH / 2 / self.camera.scaleY, Screen.targetW / self.camera.scaleX, Screen.targetH / self.camera.scaleY)
    love.graphics.setShader()
end

return Stars
