io.stdout:setvbuf("no")

-- lib shit
paths = require "paths"
utils = require "utils"
sprite = require "sprite"

local lovesize = require "lib.lovesize"
local lovebpm = require "lib.lovebpm"
-- json = require "lib.dkjson"
require "lib.tesound"

-- state shit
titlestate = require "states.TitleState"

local curState = titlestate
local _o = {}

local function callState(func, ...)
    if curState[func] ~= nil then curState[func](...) end
end

function switchState(state)
    _o = {}
    curState = state
    callState("load")
end

function add(obj) table.insert(_o, obj) end

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

    -- sound shit
    scrollSnd = love.sound.newSoundData(paths.sound("scrollMenu"))
    confirmSnd = love.sound.newSoundData(paths.sound("confirmMenu"))
    cancelSnd = love.sound.newSoundData(paths.sound("cancelMenu"))

    callState("load")

    BGMusic = lovebpm.newTrack():load(paths.music("freakyMenu")):setVolume(0.7)
                  :setBPM(102):setLooping(true):on("beat", love.beatHit)
    playBGMusic()
end

function love.resize(width, height) lovesize.resize(width, height) end

function love.beatHit(n) callState("beatHit", n) end

function love.update(dt)
    callState("update", dt)

    BGMusic:update()
    TEsound.cleanup()
end

function love.draw()
    lovesize.begin()
    callState("draw")
    lovesize.finish()
end

function love.keypressed(key, scancode, isrepeat)
    callState("keypressed", key, scancode, isrepeat)
end
