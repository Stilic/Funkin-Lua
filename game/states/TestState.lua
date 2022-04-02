local TestState = {}

local bf

function TestState.load()
    bf = sprite(paths.atlas("characters/BOYFRIEND"), 700, 250)
    bf:addByPrefix("idle", "BF idle dance")
    bf:playAnim("idle")
    _c.add(bf)
end

function TestState.draw() bf:draw() end

function TestState.update(dt) bf:update(dt) end

function TestState.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        utils.playSound(cancelSnd)
        switchState(mainmenu)
    end
end

return TestState
