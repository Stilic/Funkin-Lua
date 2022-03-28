io.stdout:setvbuf("no")

-- lib shit
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

-- load shit
local fadeTween
local fade = {y = 0, time = 1.5}
local fadeCallback
local isLoading = false

local function gradientMesh(dir, ...)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = select("#", ...)
    if colorLen < 2 then error("color list is less than two", 2) end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {
                x, 1, x, 1, color[1], color[2], color[3], color[4] or 1
            }
            meshData[#meshData + 1] = {
                x, 0, x, 0, color[1], color[2], color[3], color[4] or 1
            }
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {
                1, y, 1, y, color[1], color[2], color[3], color[4] or 1
            }
            meshData[#meshData + 1] = {
                0, y, 0, y, color[1], color[2], color[3], color[4] or 1
            }
        end
    end

    -- Resulting Mesh has 1x1 image size
    return love.graphics.newMesh(meshData, "strip", "static")
end

local gradient

-- state shit
titlestate = require "states.TitleState"

local curState = titlestate

local function callState(func, ...)
    if curState[func] ~= nil then curState[func](...) end
end

function switchState(state, transition)
    if transition == nil then transition = true end
    fadeCallback = function()
        _c.clear()
        curState = state
        isLoading = false
        callState("load")
    end

    if transition then
        isLoading = true
        fade.y = -love.graphics.getHeight() * 13
        fadeTween = tween.new(fade.time, fade, {y = 0}, "outQuad")
    else
        fadeCallback()
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

    gradient = gradientMesh("vertical", {0, 0, 0, 1}, {0, 0, 0, 0.1})

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

    tick.update(dt)

    if fadeTween ~= nil then
        if fadeTween:update(dt) then
            love.graphics.clear()
            love.graphics.present()
            fadeCallback()
            fadeCallback = nil
            fadeTween = nil
        end
    end

    BGMusic:update()
    TEsound.cleanup()
end

function love.draw()
    lovesize.begin()
    callState("draw")
    lovesize.finish()

    if isLoading then
        love.graphics.draw(gradient, 0, fade.y, 0, love.graphics.getWidth(),
                           love.graphics.getHeight() * 12)
    end
end

function love.keypressed(key, scancode, isrepeat)
    callState("keypressed", key, scancode, isrepeat)
end
