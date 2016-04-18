Screen = {
    --target: optimal game resolution, constant for all screens
    targetW = 420,
    targetH = 280,
    --real: screen size returned by love.graphics
    realW = 420,
    realH = 280,
    --fake: real screen size scaled, fake >= target
    fakeW = 420,
    fakeH = 280,
    scale = 1,
    offsetX = 0,
    offsetY = 0
}

Screen.realW = love.graphics.getWidth()
Screen.realH = love.graphics.getHeight()
Screen.scale = math.min(Screen.realW / Screen.targetW, Screen.realH / Screen.targetH)
-- Screen.scale = math.floor(Screen.scale + 0.5)
Screen.fakeW = Screen.realW / Screen.scale
Screen.fakeH = Screen.realH / Screen.scale
Screen.offsetX = (Screen.realW / Screen.scale - Screen.targetW) / 2
Screen.offsetY = (Screen.realH / Screen.scale - Screen.targetH) / 2

WORLD = {
    earthHeight = 1000,
    cloudHeight = 2000,
    atmosphereHeight = 3000,
    spaceHeight = 4000
}

DEBUG = true

function RGB(r, g, b)
    return {r = r, g = g, b = b}
end

function Debug(tag, message)
    if (DEBUG) then
        print(tag .. ' | ' .. message)
    end
end
