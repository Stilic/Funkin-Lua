local mainmenu = {}

local options = {"story_mode", "freeplay", "donate", "options"}
local curSelected = 1

local function changeSelection(change)
    curSelected = curSelected + change

    if curSelected > #options then
        curSelected = 1
    end
    if curSelected < 1 then
        curSelected = #options
    end

    for i = 1, #menuItems do
        if i == curSelected then
            menuItems[i]:playAnim("selected", true)
        else
            menuItems[i]:playAnim("idle", true)
        end
    end
end

function mainmenu.load()
    menuItems = {}

    menuBG = paths.getImage("menuBG")
    _c.add(menuBG)

    for i = 1, #options do
        menuItems[i] = sprite(paths.atlas("mainmenu/menu_" .. options[i]), 25 + i * 100, 50 + (i - 1) * 155)
        menuItems[i]:addAnim("idle", options[i] .. " basic", nil, 12)
        menuItems[i]:addAnim("selected", options[i] .. " white", nil, 12)
    end
    _c.add(menuItems)

    changeSelection(0)
end

function mainmenu.update(dt)
    utils.callGroup(menuItems, "update", dt)
end

function mainmenu.draw()
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1)
    utils.callGroup(menuItems, "draw")
end

function mainmenu.keypressed(key, scancode, isrepeat)
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
            end
        elseif key == "escape" then
            utils.playSound(cancelSnd)
            switchState(titlestate)
        end
    end
end

return mainmenu
