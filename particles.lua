local Particles = {}

local sprites = {
    circle = love.graphics.newImage('res/images/particle_circle.png')
}

local emitters = {}

function Particles.initialize()
    emitters.cloud = love.graphics.newParticleSystem(sprites.circle)
    emitters.cloud:setParticleLifetime(0, 0.5)
    emitters.cloud:setDirection(-math.pi / 2)
    emitters.cloud:setSpread(math.pi / 2)
    emitters.cloud:setLinearAcceleration(0, 200)
    emitters.cloud:setSpeed(50, 200)
    emitters.cloud:setSizes(1, 0.3)

    emitters.fire = love.graphics.newParticleSystem(sprites.circle)
    emitters.fire:setParticleLifetime(0.1, 0.5)
    emitters.fire:setDirection(-math.pi/2)
    emitters.fire:setSpread(math.pi/16)
    emitters.fire:setAreaSpread('normal', 1, 1)
    emitters.fire:setSpeed(50, 300)
    emitters.fire:setColors(255, 255, 0, 255, 255, 182, 0, 255, 255, 73, 73, 255, 146, 36, 36, 255, 10, 10, 10, 255)
    emitters.fire:setSizes(1, 0.1)
end

function Particles.get(name)
    return emitters[name]
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
