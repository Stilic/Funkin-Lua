io.stdout:setvbuf("no")

-- lazy to do a util btw
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
function table.has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

paths = require "src.paths"
utils = require "src.utils"
sprite = require "src.sprite"

local titlestate = require "src.states.titlestate"

lovebpm = require "libs.lovebpm"
xml = require("libs.xmlSimple").newParser()
-- json = require "libs.dkjson"

-- cache assets
confirmSnd = paths.getSound("confirmMenu")

function love.load()
    love.keyboard.setKeyRepeat(true)

    titlestate.load()
end

function love.update(dt)
    dt = math.min(dt, 1 / 30)
    titlestate.update(dt)
end

function love.draw()
    titlestate.draw()
end

function love.keypressed(key, scancode, isrepeat)
    titlestate.keypressed(key, scancode, isrepeat)
end
