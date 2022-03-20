io.stdout:setvbuf("no")

-- lazy to do a util btw
function string:starts(Start)
    return string.sub(self, 1, string.len(Start)) == Start
end
function table:has_value(val)
    for index, value in ipairs(self) do
        if value == val then
            return true
        end
    end
    return false
end
function table:length()
    local count = 0
    for _ in pairs(self) do
        count = count + 1
    end
    return count
end

paths = require "src.paths"
utils = require "src.utils"
sprite = require "src.sprite"

lovebpm = require "libs.lovebpm"
xml = require("libs.xmlSimple").newParser()
-- json = require "libs.dkjson"

-- state shit
curState = require "src.states.TitleState"
_s = require "libs.lovelist"

function switchState(newState)
    _s.clear()
    curState = newState
    love.load()
end

-- cache assets
confirmSnd = paths.getSound("confirmMenu")

function love.load()
    love.keyboard.setKeyRepeat(true)

    if curState.load ~= null then
        curState.load()
    end
end

function love.update(dt)
    if curState.update ~= null then
        dt = math.min(dt, 1 / 30)
        curState.update(dt)
    end
end

function love.draw()
    if curState.draw ~= nil then
        curState.draw()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if curState.keypressed ~= nil then
        curState.keypressed(key, scancode, isrepeat)
    end
end
