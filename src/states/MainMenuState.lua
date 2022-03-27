local mainmenu = {}

local menuBG

local menuItems = {}
local options = {
    "story_mode", "freeplay",
    --[[i kept the donate button just because i might add a link to my paypal or something idk
	but i think i really shouldn't try to profit from a fnf engine even if its optional
	let's just keep it like this unless we talk bout this, ight?
]]
    "donate", "options"
}

local curSelected = 1

function mainmenu.load()
    menuBG = paths.getImage("menuBG")
    add(menuBG)

    for i = 1, #options do
        local spr = sprite.new(paths.atlas("mainmenu/menu_" .. options[i]),
                               love.graphics.getWidth() / 4, 50 + (i - 1) * 155)
        spr:addAnim("idle", options[i] .. " basic")
        spr:addAnim("selected", options[i] .. " white")

        table.insert(menuItems, spr)
    end

    add(menuItems)

    mainmenu.changeSelection(0)
end

function mainmenu.changeSelection(change)
    curSelected = curSelected + change

    if curSelected > #options then curSelected = 1 end
    if curSelected < 1 then curSelected = #options end

    for k, s in pairs(menuItems) do
        if k == curSelected then
            s:playAnim("selected")
        else
            s:playAnim("idle")
        end
    end
end

function mainmenu.update(dt) utils.callGroup(menuItems, "update", dt) end

function mainmenu.draw()
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1)
    utils.callGroup(menuItems, "draw")
end

function mainmenu.keypressed(key, scancode, isrepeat)
    if not isrepeat then
        if key == "up" then
            utils.playSound(scrollSnd)
            mainmenu.changeSelection(-1)
        elseif key == "down" then
            utils.playSound(scrollSnd)
            mainmenu.changeSelection(1)
        elseif key == "escape" then
            utils.playSound(cancelSnd)
            menuItems = {}
            switchState(titlestate)
        end
    end
end

return mainmenu
