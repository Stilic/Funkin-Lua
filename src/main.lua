io.stdout:setvbuf("no")

paths = require "paths"
utils = require "utils"
sprite = require "sprite"
_c = require "cache"

local lovesize = require "lib.lovesize"
local lovebpm = require "lib.lovebpm"
tick = require "lib.tick"
tween = require "lib.tween"
-- json = require "lib.dkjson"
require "lib.tesound"

local function drawScreenOverlay()
    love.graphics.print("FPS: " .. love.timer.getFPS() .. "\nMemory: " ..
                            math.floor(collectgarbage("count") * 0.1024) ..
                            " MB", 7, 7)
end

-- transition shit
local transTween
local trans = {y = 0, time = 0.8}
local transCallback
local isTransitioning = false

local gradient

local function startTransition(out)
    local tweenData
    if out then
        gradient = utils.gradientMesh("vertical", {0, 0, 0, 1}, {0, 0, 0, 0})
        trans.y = -love.graphics.getHeight() * 14
        tweenData = {y = 0}
    else
        gradient = utils.gradientMesh("vertical", {0, 0, 0, 0}, {0, 0, 0, 1})
        trans.y = -love.graphics.getHeight() * 12
        tweenData = {y = love.graphics.getHeight() * 2}
    end

    isTransitioning = true

    transTween = tween.new(trans.time, trans, tweenData)
end

function screenFlash(duration, r, g, b)
    if duration == nil then duration = 0.6 end
    if r == nil then r = 255 end
    if g == nil then g = 255 end
    if b == nil then b = 255 end

    flash.alpha = 1
    flash.color = {r, g, b}
    flash.tween = tween.new(duration, flash, {alpha = 0})
end

-- state shit
titlestate = require "states.TitleState"
local curState = titlestate

local function callState(func, ...)
    if curState[func] ~= nil then curState[func](...) end
end

function switchState(state, transition)
    if transition == nil then transition = true end
    transCallback = function()
        love.graphics.clear()
        drawScreenOverlay()
        love.graphics.present()

        startTransition(false)

        flash.alpha = 0
        flash.tween = nil

        _c.clear()

        curState = state
        callState("load")

        if transTween ~= nil then transTween:reset() end
        if flash.tween ~= nil then flash.tween:reset() end

        collectgarbage("collect")
    end

    if transition then
        startTransition(true)
    else
        transCallback()
    end
end

function resetState() switchState(curState) end

function playBGMusic()
    BGMusic:play()
    BGMusic.playing = true
end

function pauseBGMusic()
    BGMusic:pause()
    BGMusic.playing = false
end

function love.load()
    lovesize.set(1280, 720)
    love.keyboard.setKeyRepeat(true)

    flash = {alpha = 0, color = {255, 255, 255}}

    vcrFont = love.graphics.newFont(paths.font("vcr.ttf"), 14, "light")
    love.graphics.setFont(vcrFont)

    scrollSnd = love.sound.newSoundData(paths.sound("scrollMenu"))
    confirmSnd = love.sound.newSoundData(paths.sound("confirmMenu"))
    cancelSnd = love.sound.newSoundData(paths.sound("cancelMenu"))

    callState("load")

    BGMusic = lovebpm.newTrack():load(paths.music("freakyMenu")):setVolume(0.7)
                  :setBPM(102):setLooping(true):on("beat", love.beatHit)
    playBGMusic()

    collectgarbage("collect")
end

function love.resize(width, height) lovesize.resize(width, height) end

function love.beatHit(n) callState("beatHit", n) end

function love.update(dt)
    callState("update", dt)

    BGMusic:update()
    tick.update(dt)
    TEsound.cleanup()

    if transTween ~= nil and transTween:update(dt) then
        transTween = nil
        isTransitioning = false
        if transCallback ~= nil then
            transCallback()
            transCallback = nil
        end
    end

    if flash.tween ~= nil then flash.tween:update(dt) end
end

function love.draw()
    lovesize.begin()

    callState("draw")

    if isTransitioning then
        love.graphics.draw(gradient, 0, trans.y, 0, love.graphics.getWidth(),
                           love.graphics.getHeight() * 13)
    end
    if flash.alpha > 0 then
        love.graphics.setColor(flash.color[1], flash.color[2], flash.color[3],
                               flash.alpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
        love.graphics.setColor(255, 255, 255)
    end

    lovesize.finish()

    drawScreenOverlay()
end

function love.keypressed(key, scancode, isrepeat)
    if not isTransitioning then
        callState("keypressed", key, scancode, isrepeat)
    end
end
