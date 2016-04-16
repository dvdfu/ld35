local Particles = {}

local sprites = {
    cloud = love.graphics.newImage('res/images/particle_cloud.png')
}

local emitters = {}

function Particles.initialize()
    emitters.cloud = love.graphics.newParticleSystem(sprites.cloud)
    emitters.cloud:setParticleLifetime(0, 0.5)
    emitters.cloud:setDirection(-math.pi / 2)
    emitters.cloud:setSpread(math.pi / 2)
    emitters.cloud:setLinearAcceleration(0, 200)
    emitters.cloud:setSpeed(50, 200)
    emitters.cloud:setSizes(1, 0.3)
end

function Particles.emit(name, x, y, num)
    local emitter = emitters[name]
    if not emitter then return end
    emitter:setPosition(x, y)
    emitter:emit(num)
end

function Particles.update(name, dt)
    local emitter = emitters[name]
    if not emitter then return end
    emitter:update(dt)
end

function Particles.draw(name)
    local emitter = emitters[name]
    if not emitter then return end
    love.graphics.draw(emitter)
end

return Particles
