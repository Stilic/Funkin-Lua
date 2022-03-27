local titlestate = {}

local mainmenu = require "states.MainMenuState"

function titlestate.load()
    gf = sprite.new(paths.atlas("gfDanceTitle"), 512, 40)
    gf.danceLeft = false
    gf:addAnim("danceLeft", "gfDance",
               {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}, 24, false)
    gf:addAnim("danceRight", "gfDance",
               {15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29}, 24,
               false)
    _c.add(gf)

    logo = sprite.new(paths.atlas("logoBumpin"), -150, -100)
    logo:addAnim("bump", "logo bumpin instance ", nil, 24, false)
    _c.add(logo)

    titleText = sprite.new(paths.atlas("titleEnter"), 100, 576)
    titleText:addAnim("idle", "Press Enter to Begin")
    titleText:addAnim("press", "ENTER PRESSED")
    titleText:playAnim("idle")
    _c.add(titleText)
end

function titlestate.update(dt)
    gf:update(dt)
    logo:update(dt)
    titleText:update(dt)
end

function titlestate.draw()
    gf:draw()
    logo:draw()
    titleText:draw()
end

function titlestate.beatHit()
    logo:playAnim("bump", true)

    gf.danceLeft = not gf.danceLeft
    if gf.danceLeft then
        gf:playAnim("danceRight")
    else
        gf:playAnim("danceLeft")
    end
end

function titlestate.keypressed(key, scancode, isrepeat)
    if not isrepeat and key == "return" then
        utils.playSound(confirmSnd)
        switchState(mainmenu)
    end
end

return titlestate
