local Particles = {}

local sprites = {
    circle = love.graphics.newImage('res/images/particle_circle.png'),
    bar = love.graphics.newImage('res/images/particle_bar.png')
}

local emitters = {}

function Particles.initialize()
    emitters.cloud = love.graphics.newParticleSystem(sprites.circle)
    emitters.cloud:setParticleLifetime(0.3, 1)
    emitters.cloud:setSpread(math.pi / 16)
    emitters.cloud:setLinearAcceleration(0, 200)
    emitters.cloud:setSpeed(50, 200)
    emitters.cloud:setColors(255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0)
    emitters.cloud:setSizes(1, 0.5)

    emitters.fire = love.graphics.newParticleSystem(sprites.circle)
    emitters.fire:setParticleLifetime(0.2, 0.5)
    emitters.fire:setDirection(-math.pi / 2)
    emitters.fire:setSpread(math.pi / 16)
    emitters.fire:setSpeed(50, 400)
    emitters.fire:setColors(255, 255, 0, 255, 255, 182, 0, 255, 255, 73, 73, 255, 255, 73, 73, 0)
    emitters.fire:setSizes(1.3, 0.1)

    emitters.spark = love.graphics.newParticleSystem(sprites.bar)
    emitters.spark:setParticleLifetime(0, 0.3)
    emitters.spark:setSpread(math.pi * 2)
    emitters.spark:setSpeed(0, 200)
    emitters.spark:setColors(255, 255, 0, 255, 255, 255, 0, 0)
    emitters.spark:setRelativeRotation(true)
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
