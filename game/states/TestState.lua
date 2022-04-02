local TestState = {}

local bf

function TestState.load()
    bf = character("bf", 700, 250)
    _c.add(bf)
end

function TestState.draw() bf:draw() end

function TestState.update(dt) bf:update(dt) end

function TestState.beatHit(n) if n % 2 == 0 then bf:dance() end end

function TestState.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        utils.playSound(cancelSnd)
        switchState(mainmenu)
    end
end

return TestState
