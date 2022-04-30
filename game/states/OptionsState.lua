local state = {}

local menuBG
local funniText

function state.load()
    menuBG = paths.getImage("menuDesat")
    _c.add(menuBG)

    funniText = alphabet("cool swag", true)
end

local addX = 15
local addY = 15

function state.update(dt)
    funniText:update(dt)

    if input:pressed "back" then
        utils.playSound(cancelSnd)
        switchState(mainmenu)
    end
    if input:pressed "accept" then
        funniText:changeText("yeah\nbitch")
    end
    if input:down "up" then
        funniText.x = funniText.x + 1
    end
end

function state.draw()
    love.graphics.setColor(234 / 255, 113 / 255, 253 / 255)
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1)
    love.graphics.setColor(1, 1, 1)
    funniText:draw(addX, addY)
end

return state
