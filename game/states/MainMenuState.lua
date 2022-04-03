local MainMenuState = {}

local menuBG

local options = {"story_mode", "freeplay", "donate", "options"}
local menuItems

local curSelected = 1

local confirmed
local confirmTick
local shouldDrawMenu

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

    confirmed = false
    shouldDrawMenu = true

    menuBG = paths.getImage("menuBG")
    _c.add(menuBG)

    for i = 1, #options do
        local item = sprite(paths.atlas("mainmenu/menu_" .. options[i]),
                            lovesize.getWidth() / 2, 115 + (i - 1) * 165)
        item:addByPrefix("idle", options[i] .. " basic")
        item:addByPrefix("selected", options[i] .. " white")
        item.centerOffsets = true
        menuItems[i] = item
    end
    _c.add(menuItems)

    changeSelection(0)
end

function MainMenuState.update(dt)
    utils.callGroup(menuItems, "update", dt)

    if not confirmed then
        if input:pressed "up" then
            utils.playSound(scrollSnd)
            changeSelection(-1)
        end
        if input:pressed "down" then
            utils.playSound(scrollSnd)
            changeSelection(1)
        end
        if input:pressed "accept" then
            utils.playSound(confirmSnd)
            if curSelected == 3 then
                love.system.openURL("https://ninja-muffin24.itch.io/funkin")
            else
                confirmed = true

                if confirmTick == nil then
                    confirmTick = tick.recur(function()
                        if not isTransitioning then
                            shouldDrawMenu = not shouldDrawMenu
                        else
                            shouldDrawMenu = false
                        end
                    end, .075)
                end

                if curSelected == 4 then
                    tick.delay(function()
                        switchState(optionsmenu)
                    end, 1)
                end
            end
        end
        if input:pressed "back" then
            utils.playSound(cancelSnd)
            switchState(titlescreen)
        end
    end
end

function MainMenuState.draw()
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("v" .. _GAME_VERSION, 5, lovesize.getHeight() - 20)
    love.graphics.setColor(255, 255, 255)

    if not confirmed then utils.callGroup(menuItems, "draw") end
    if confirmed and shouldDrawMenu then menuItems[curSelected]:draw() end
end

return MainMenuState
