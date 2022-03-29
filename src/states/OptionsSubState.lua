local OptionsSubState = {}

-- da options list, no table cus idk if they work with true/false statements
ghostTapping = true
middleScroll = false
scrollType = up -- idk if this works lmao
-- end of da options list

function OptionsSubState.load()
	menuDesat = paths.getImage("menuDesat")
	_c.add(menuDesat)
end

function OptionsSubState.draw()
	    love.graphics.draw(menuDesat, 0, 0, 0, 1.1, 1.1)
end

function OptionsSubState.keypressed(key, scancode, isrepeat)
if key == "escape" then
            utils.playSound(cancelSnd)
            switchState(mainmenu)
        end
end

return OptionsSubState