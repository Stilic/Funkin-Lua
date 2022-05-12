io.stdout:setvbuf("no")

_GAME_VERSION = "1.0.0 git"
options = { ghostTapping = true, middleScroll = false, downScroll = false }

local function drawScreenOverlay()
    love.graphics.print("FPS: " .. love.timer.getFPS() .. "\nTex MEM: " ..
        math.floor(
            love.graphics.getStats().texturememory / 1048576) ..
        " MB", 7, 7)
end

utils = require "util.utils"
paths = require "util.paths"
_c = require "util.cache"

sprite = require "game.sprite"
alphabet = require "game.alphabet"
character = require "game.character"

song = require "game.song"
note = require "game.note"
strumnote = require "game.strumnote"

lovesize = require "lib.lovesize"
lovebpm = require "lib.lovebpm"
baton = require "lib.baton"
tick = require "lib.tick"
tween = require "lib.tween"
json = require "lib.dkjson"
require "lib.tesound"

input = baton.new({
    controls = {
        left = { "key:left", "key:a", "axis:leftx-", "button:dpleft" },
        right = { "key:right", "key:d", "axis:leftx+", "button:dpright" },
        up = { "key:up", "key:w", "axis:lefty-", "button:dpup" },
        down = { "key:down", "key:s", "axis:lefty+", "button:dpdown" },
        action = { "key:space", "button:x" },
        accept = { "key:return", "button:start", "button:a" },
        back = { "key:escape", "key:backspace", "button:b" }
    },
    joystick = love.joystick.getJoysticks()[1]
})

trans = {
    tween = nil,
    onComplete = nil,
    y = 0,
    time = 1,
    out = false,
    skipNextTransIn = true,
    skipNextTransOut = true
}
isTransitioning = false
local gradient

local function startTransition(out)
    isTransitioning = true

    local y = lovesize.getHeight()
    trans.y = -lovesize.getHeight() * 10
    if out then
        trans.skipNextTransOut = true
        gradient = utils.gradientMesh("vertical", { 0, 0, 0, 1 }, { 0, 0, 0, 0 })
    else
        trans.skipNextTransIn = true
        gradient = utils.gradientMesh("vertical", { 0, 0, 0, 0 }, { 0, 0, 0, 1 })
        trans.y = trans.y / 2
        y = y / 2
    end

    trans.out = out

    trans.tween = tween.new(trans.time, trans, { y = y })
end

function screenFlash(duration, r, g, b)
    if duration == nil then duration = 0.6 end
    if r == nil then r = 255 end
    if g == nil then g = 255 end
    if b == nil then b = 255 end

    flash.alpha = 1
    flash.color = { r, g, b }
    flash.tween = tween.new(duration, flash, { alpha = 0 })
end

-- function dump(o)
--     if type(o) == 'table' then
--         local s = '{ '
--         for k, v in pairs(o) do
--             if type(k) ~= 'number' then k = '"' .. k .. '"' end
--             s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
--         end
--         return s .. '} '
--     else
--         return tostring(o)
--     end
-- end

-- states loaded here
titlescreen = require "game.states.TitleState"
mainmenu = require "game.states.MainMenuState"
optionsmenu = require "game.states.OptionsState"
playstate = require "game.states.PlayState"

local curState = titlescreen

local function callState(func, ...)
    if curState[func] ~= nil then curState[func](...) end
end

function switchState(state, transition)
    assert(state ~= nil, "The state is nil!")

    if transition == nil then transition = true end

    trans.onComplete = function()
        callState('exit')

        -- love.graphics.setColor(0, 0, 0)
        -- love.graphics.rectangle("fill", 0, 0, lovesize:getDimensions())
        -- love.graphics.setColor(255, 255, 255)
        drawScreenOverlay()
        love.graphics.present()

        flash.alpha = 0
        flash.tween = nil

        _c.clear()

        curState = state
        callState("load")

        if trans.skipNextTransIn and state ~= titlescreen then
            startTransition(false)
        end
    end

    if transition and trans.skipNextTransOut then
        startTransition(true)
    else
        trans.onComplete()
    end

    collectgarbage()
end

function resetState() switchState(curState) end

-- music shit
local defaultMusic = paths.music("freakyMenu")

function playBGMusic()
    BGMusic:play()
    BGMusic.playing = true
end

function pauseBGMusic()
    BGMusic:pause()
    BGMusic.playing = false
end

function resetBGMusic()
    loadBGMusic(defaultMusic)
    BGMusic:setLooping(true)
end

function loadBGMusic(music, bpm)
    if bpm == nil then bpm = 102 end
    pauseBGMusic()
    BGMusic:load(music):setBPM(bpm)
    playBGMusic()
end

function love.load()
    lovesize.set(1280, 720)
    love.keyboard.setKeyRepeat(true)

    flash = { alpha = 0, color = { 255, 255, 255 } }

    vcrFont = love.graphics.newFont(paths.font("vcr.ttf"), 14, "light")
    love.graphics.setFont(vcrFont)

    scrollSnd = love.sound.newSoundData(paths.sound("scrollMenu"))
    confirmSnd = love.sound.newSoundData(paths.sound("confirmMenu"))
    cancelSnd = love.sound.newSoundData(paths.sound("cancelMenu"))

    callState("load")

    BGMusic = lovebpm.newTrack():load(defaultMusic):setVolume(0.7):setBPM(102)
        :setLooping(true):on("beat", love.beatHit)
        :on("end", love.songEnd):on("loop", love.songEnd)
    playBGMusic()
end

function love.update(dt)
    dt = math.min(dt, 1 / 30)

    input:update()
    tick.update(dt)

    BGMusic:update()
    TEsound.cleanup()

    callState("update", dt)

    if trans.tween ~= nil and trans.tween:update(dt) then
        trans.tween = nil
        isTransitioning = false
        if trans.onComplete ~= nil then
            trans.onComplete()
            trans.onComplete = nil
        end
    end

    if flash.tween ~= nil then flash.tween:update(dt) end
end

function love.draw()
    lovesize.begin()

    callState("draw")

    if isTransitioning then
        local leWidth = lovesize.getWidth()
        local leHeight
        if trans.out then
            leHeight = lovesize.getHeight() * 8.5
        else
            leHeight = lovesize.getHeight() * 5
        end
        love.graphics.draw(gradient, 0, trans.y, 0, leWidth, leHeight)
        love.graphics.setColor(0, 0, 0)
        if trans.out then trans.y = trans.y - leHeight * 2 end
        love.graphics
            .rectangle("fill", 0, trans.y + leHeight, leWidth, leHeight)
        love.graphics.setColor(255, 255, 255)

    end
    if flash.alpha > 0 then
        love.graphics.setColor(flash.color[1], flash.color[2], flash.color[3],
            flash.alpha)
        love.graphics.rectangle("fill", 0, 0, lovesize.getDimensions())
        love.graphics.setColor(255, 255, 255)
    end

    lovesize.finish()

    drawScreenOverlay()
end

function love.resize(width, height) lovesize.resize(width, height) end

function love.keypressed(key, scancode, isrepeat)
    if not isTransitioning then
        callState("keypressed", key, scancode, isrepeat)
    end
end

-- custom callbacks
function love.songEnd() callState("songEnd") end

function love.beatHit(n) callState("beatHit", n) end
