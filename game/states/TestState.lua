local TestState = {}

local bf

function TestState.load()
    bf = character("bf", 700, 250)
    _c.add(bf)
end

function TestState.draw() bf:draw() end

function TestState.update(dt)
    bf:update(dt)

    if input:pressed "back" then
        utils.playSound(cancelSnd)
        switchState(mainmenu)
    end
    if input:pressed "left" then
        bf:playAnim("singLEFT", true)
    end
    if input:pressed "right" then
        bf:playAnim("singRIGHT", true)
    end
    if input:pressed "up" then
        bf:playAnim("singUP", true)
    end
    if input:pressed "down" then
        bf:playAnim("singDOWN", true)
    end
end

function TestState.beatHit(n) if n % 2 == 0 then bf:dance() end end

return TestState
