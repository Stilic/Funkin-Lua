io.stdout:setvbuf("no")

-- lazy to do a util btw
function string:starts(Start)
    return string.sub(self, 1, string.len(Start)) == Start
end
function table:has_value(val)
    for index, value in ipairs(self) do if value == val then return true end end
    return false
end
function table:length()
    local count = 0
    for _ in pairs(self) do count = count + 1 end
    return count
end

-- global variables (to all of the code)
paths = require "paths"
utils = require "utils"
sprite = require "sprite"
lovegroup = require "lovegroup"
_c = require "cache"

-- lib shit
local lovesize = require "lib.lovesize"
local lovebpm = require "lib.lovebpm"
-- json = require "lib.dkjson"
require "lib.tesound"

-- sound shit
scrollSnd = love.sound.newSoundData(paths.sound("scrollMenu"))
confirmSnd = love.sound.newSoundData(paths.sound("confirmMenu"))
cancelSnd = love.sound.newSoundData(paths.sound("cancelMenu"))

-- state shit
titlestate = require "states.TitleState"
local curState = titlestate

function switchState(newState)
    _c.clear()
    curState = newState
    curState.load()
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
    curState.load()
    BGMusic = lovebpm.newTrack():load(paths.music("freakyMenu")):setBPM(102)
                  :setLooping(true):on("beat", love.beatHit)
    playBGMusic()
end

function love.resize(width, height) lovesize.resize(width, height) end

function love.beatHit(n)
    if curState.beatHit ~= nil then
        ---@diagnostic disable-next-line: redundant-parameter
        curState.beatHit(n)
    end
end

function love.update(dt)
    if curState.update ~= nil then curState.update(dt) end
    BGMusic:update()
    TEsound.cleanup()
end

function love.draw()
    lovesize.begin()
    if curState.draw ~= nil then curState.draw() end
    lovesize.finish()
end

function love.keypressed(key, scancode, isrepeat)
    if curState.keypressed ~= nil then
        curState.keypressed(key, scancode, isrepeat)
    end
end
