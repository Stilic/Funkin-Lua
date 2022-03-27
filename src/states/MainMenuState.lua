local mainmenu = {}

local menuItems = lovegroup.new()

local options = {
    "story_mode", "freeplay",
    --[[i kept the donate button just because i might add a link to my paypal or something idk
	but i think i really shouldn't try to profit from a fnf engine even if its optional
	let's just keep it like this unless we talk bout this, ight?
]]
    "donate", "options"
}

local curSelected = 0

function mainmenu.load()
    menuBG = paths.getImage("menuBG")
    _c.add(menuBG)

    -- for i = 1, #options do
    --     local spr = sprite.new("mainmenu/menu_" .. options[i],
    --                            love.graphics.getWidth() / 4, 50 + (i - 1) * 155)
    --     spr:addAnim("idle", options[i] .. " basic")
    --     spr:addAnim("selected", options[i] .. " white")
    --     menuItems:add(spr)
    -- end

    -- storymode = sprite.new(paths.image())
    _c.add(menuItems)

    mainmenu.changeSelection(0)
end

function mainmenu.changeSelection(change)
    curSelected = curSelected + change

    if curSelected >= menuItems.length then curSelected = 0 end
    if curSelected < 0 then curSelected = menuItems.length - 1 end

    for k, s in pairs(menuItems.sprites) do
        if k == curSelected then
            s:playAnim("selected")
        else
            s:playAnim("idle")
        end
    end
end

function mainmenu.update(dt) menuItems:update(dt) end

function mainmenu.draw()
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1)
    menuItems:draw()
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
            menuItems:clear()
            utils.playSound(cancelSnd)
            switchState(titlestate)
        end
    end
end

return mainmenu
