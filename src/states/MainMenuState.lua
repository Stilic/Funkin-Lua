local mainmenu = {}

local menuItems = { }

local options = {"story_mode", "freeplay", "donate", "options"}
local curSelected = 1

local function changeSelection(change)
    curSelected = curSelected + change

    if curSelected > #options then curSelected = 1 end
    if curSelected < 1 then curSelected = #options end

end

function mainmenu.load()
    menuBG = paths.getImage("menuBG")
    _c.add(menuBG)
    for i = 1, #options do
        spr = sprite.new(paths.atlas("mainmenu/menu_" .. options[i]),
                                        love.graphics.getWidth() / 4, 50 + (i - 1) * 155)
        spr:addAnim("idle", options[i] .. " basic")
        spr:addAnim("idle", options[i] .. " white")
    end
    spr:playAnim("idle")
    changeSelection(0)
end

function mainmenu.update(dt) 
    spr:update(dt)
end

function mainmenu.draw()
    love.graphics.draw(menuBG, 0, 0, 0, 1.1, 1.1) 
    spr:draw()
end

function mainmenu.keypressed(key, scancode, isrepeat)
    if not isrepeat then
        if key == "up" then
            utils.playSound(scrollSnd)
            changeSelection(-1)
        elseif key == "down" then
            utils.playSound(scrollSnd)
            changeSelection(1)
        elseif key == "escape" then
            utils.playSound(cancelSnd)
            switchState(titlestate)
        end
    end
end

return mainmenu
