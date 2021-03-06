local Particles = {}

local sprites = {
    circle = love.graphics.newImage('res/images/particle_circle.png'),
    circleBig = love.graphics.newImage('res/images/particle_circle_big.png'),
    bar = love.graphics.newImage('res/images/particle_bar.png')
}

local emitters = {}
local buffers = {}

function Particles.initialize()
    emitters.cloud = love.graphics.newParticleSystem(sprites.circle)
    emitters.cloud:setParticleLifetime(0.3, 2)
    emitters.cloud:setSpread(math.pi / 2)
    emitters.cloud:setLinearAcceleration(0, 200)
    emitters.cloud:setSpeed(50, 200)
    emitters.cloud:setColors(255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0)
    emitters.cloud:setSizes(1, 0.2)

    emitters.fire = love.graphics.newParticleSystem(sprites.circle)
    emitters.fire:setParticleLifetime(0, 0.3)
    emitters.fire:setSpread(math.pi / 16)
    emitters.fire:setColors(255, 255, 0, 255, 255, 182, 0, 255, 255, 73, 73, 255, 255, 73, 73, 0)
    emitters.fire:setSizes(1.5, 0)

    emitters.spark = love.graphics.newParticleSystem(sprites.bar)
    emitters.spark:setParticleLifetime(0, 0.3)
    emitters.spark:setSpread(math.pi * 2)
    emitters.spark:setSpeed(0, 200)
    emitters.spark:setColors(255, 255, 0, 255, 255, 255, 0, 0)
    emitters.spark:setRelativeRotation(true)

    emitters.moon = love.graphics.newParticleSystem(sprites.circleBig)
    emitters.moon:setParticleLifetime(0, 3)
    emitters.moon:setDirection(math.pi * 5 / 4)
    emitters.moon:setSpread(math.pi)
    emitters.moon:setSpeed(0, 400)
    emitters.moon:setColors(255, 255, 255, 255, 255, 255, 255, 0)
    emitters.moon:setSizes(1, 0)

    emitters.dust = love.graphics.newParticleSystem(sprites.circleBig)
    emitters.dust:setParticleLifetime(0, 3)
    emitters.dust:setDirection(-math.pi / 2)
    emitters.dust:setSpread(math.pi)
    emitters.dust:setSpeed(0, 200)
    emitters.dust:setColors(172, 138, 101, 255, 172, 138, 101, 0)
    emitters.dust:setSizes(0.5, 0)
end

function Particles.get(name)
    return emitters[name]
end

function Particles.emit(name, x, y, num)
    local emitter = emitters[name]
    if not emitter then return end

    if buffers[name] then
        buffers[name] = buffers[name] + num
    else
        buffers[name] = num
    end

    emitter:setPosition(x, y)
    while buffers[name] >= 1 do
        buffers[name] = buffers[name] - 1
        emitter:emit(1)
    end
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
