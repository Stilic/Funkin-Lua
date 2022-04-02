local OptionsState = {}

local menuBG
local funniText

function OptionsState.load()
    menuBG = paths.getImage("menuDesat")
    _c.add(menuBG)

    funniText = alphabet("cool swag", true)
    _c.add(funniText)
end

local addX = 15
local addY = 15

function OptionsState.draw()
    love.graphics.setColor(234 / 255, 113 / 255, 253 / 255)
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1)
    love.graphics.setColor(1, 1, 1)
    funniText:draw(addX, addY)
end

function OptionsState.update(dt) funniText:update(dt) end

function OptionsState.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        utils.playSound(cancelSnd)
        switchState(mainmenu)
    elseif key == "return" then
        funniText:changeText("yeah\nbitch")
    elseif key == "up" then
        funniText.x = funniText.x + 1
    end
end

return OptionsState
