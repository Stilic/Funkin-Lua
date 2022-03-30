local TitleState = {}

local danceLeft
local confirmed

function TitleState.load()
    danceLeft = false
    confirmed = false

    gf = sprite(paths.atlas("gfDanceTitle"), 512, 40)
    gf:addByIndices("danceLeft", "gfDance", {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}, 24, false)
    gf:addByIndices("danceRight", "gfDance", {15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29}, 24, false)
    _c.add(gf)

    logo = sprite(paths.atlas("logoBumpin"), -125, -85)
    logo:addByPrefix("bump", "logo bumpin instance ", nil, 24, false)
    _c.add(logo)

    titleText = sprite(paths.atlas("titleEnter"), 100, 576)
    titleText:addByPrefix("idle", "Press Enter to Begin")
    titleText:addByPrefix("press", "ENTER PRESSED")
    titleText:playAnim("idle")
    _c.add(titleText)

    screenFlash(2)
end

function TitleState.update(dt)
    gf:update(dt)
    logo:update(dt)
    titleText:update(dt)
end

function TitleState.draw()
    gf:draw()
    logo:draw()
    titleText:draw()
end

function TitleState.beatHit()
    logo:playAnim("bump", true)

    danceLeft = not danceLeft
    if danceLeft then
        gf:playAnim("danceRight")
    else
        gf:playAnim("danceLeft")
    end
end

function TitleState.keypressed(key, scancode, isrepeat)
    if not isrepeat and not confirmed and key == "return" then
        confirmed = true

        utils.playSound(confirmSnd)
        titleText:playAnim("press")
        screenFlash()

        tick.delay(function()
            switchState(mainmenu)
        end, 1)
    end
end

return TitleState
