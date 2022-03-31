local OptionsState = {}

-- local options = {ghostTapping = true, middleScroll = false, downScroll = false}

local menuBG
local funniText

function OptionsState.load()
    menuBG = paths.getImage("menuDesat")
    _c.add(menuBG)

    funniText = alphabet("so, you think I WILL LET YOU?!", true)
    _c.add(funniText)
end

function OptionsState.draw()
    love.graphics.setColor(234 / 255, 113 / 255, 253 / 255)
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1)
    love.graphics.setColor(1, 1, 1)
    funniText:draw()
end

function OptionsState.update(dt)
    funniText:update(dt)
end

function OptionsState.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        utils.playSound(cancelSnd)
        switchState(mainmenu)
    end
end

return OptionsState
