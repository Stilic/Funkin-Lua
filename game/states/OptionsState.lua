local OptionsSubState = {}

optionsList = {
    ghostTapping = true,
    middleScroll = false,
    scrollType = "up"
}

function OptionsSubState.load()
    menuBG = paths.getImage("menuDesat")
    _c.add(menuBG)
end

function OptionsSubState.draw()
    love.graphics.setColor(234 / 255, 113 / 255, 253 / 255)
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1)
    love.graphics.setColor(1, 1, 1)
end

function OptionsSubState.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        utils.playSound(cancelSnd)
        switchState(mainmenu)
    end
end

return OptionsSubState
