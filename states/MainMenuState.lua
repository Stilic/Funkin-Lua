local MainMenuState = {}

local optionsmenu = require "states.OptionsState"

local options = {"story_mode", "freeplay", "donate", "options"}
local curSelected = 1

local function changeSelection(change)
    curSelected = curSelected + change

    if curSelected > #options then curSelected = 1 end
    if curSelected < 1 then curSelected = #options end

    for i = 1, #menuItems do
        if i == curSelected then
            menuItems[i]:playAnim("selected")
        else
            menuItems[i]:playAnim("idle")
        end
    end
end

function MainMenuState.load()
    menuItems = {}

    menuBG = paths.getImage("menuBG")
    _c.add(menuBG)

    for i = 1, #options do
        menuItems[i] = sprite(paths.atlas("mainmenu/menu_" .. options[i]),
                              lovesize.getWidth() / 2, 100 + (i - 1) * 155)
        menuItems[i]:addByPrefix("idle", options[i] .. " basic")
        menuItems[i]:addByPrefix("selected", options[i] .. " white")
        menuItems[i].centerOffsets = true
    end
    _c.add(menuItems)

    changeSelection(0)
end

function MainMenuState.update(dt) utils.callGroup(menuItems, "update", dt) end

function MainMenuState.draw()
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("v" .. _GAME_VERSION, 5, lovesize.getHeight() - 20)
    love.graphics.setColor(255, 255, 255)

    utils.callGroup(menuItems, "draw")
end

function MainMenuState.keypressed(key, scancode, isrepeat)
    if not isrepeat then
        if key == "up" then
            utils.playSound(scrollSnd)
            changeSelection(-1)
        elseif key == "down" then
            utils.playSound(scrollSnd)
            changeSelection(1)
        elseif key == "return" then
            utils.playSound(confirmSnd)
            if curSelected == 3 then
                love.system.openURL("https://ninja-muffin24.itch.io/funkin")
            elseif curSelected == 4 then
                tick.delay(function() switchState(optionsmenu) end, 1)
            end
        elseif key == "escape" then
            utils.playSound(cancelSnd)
            switchState(titlescreen)
        end
    end
end

return MainMenuState
