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

INTRO = {
    groundHeight = 80
}

WORLD = {
    earthHeight = 2000,
    cloudHeight = 4000,
    atmosphereHeight = 7000,
    spaceHeight = 14000
}

FONT = {
    babyblue = love.graphics.newFont('res/fonts/babyblue.ttf', 16)
}

DEBUG = false

function RGB(r, g, b)
    return {r = r, g = g, b = b}
end

function Debug(tag, message)
    if (DEBUG) then
        love.graphics.setFont(FONT.babyblue)
        print(tag .. ' | ' .. message)
    end
end
