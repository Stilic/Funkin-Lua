local titlestate = {}

local mainmenu = require "src.states.MainMenuState"

function titlestate.load()
    gf = utils.makeSprite("gfDanceTitle")
    gf.danceLeft = false
    gf:addAnim("danceLeft", "gfDance", {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}, 24, false)
    gf:addAnim("danceRight", "gfDance", {15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29}, 24, false)
    _s.add(gf)

    logo = utils.makeSprite("logoBumpin")
    logo:addAnim("bump", "logo bumpin instance ", nil, 24, false)
    _s.add(logo)

    titleText = utils.makeSprite("titleEnter")
    titleText:addAnim("idle", "Press Enter to Begin")
    titleText:addAnim("press", "ENTER PRESSED")
    titleText:playAnim("idle")
    _s.add(titleText)

    music = lovebpm.newTrack():load(paths.music('freakyMenu')):setBPM(102):setLooping(true):on("beat", function(n)
        logo:playAnim("bump", true)

        gf.danceLeft = not gf.danceLeft
        if gf.danceLeft then
            gf:playAnim("danceRight")
        else
            gf:playAnim("danceLeft")
        end

    end):play()
end

function titlestate.update(dt)
    gf:update(dt)
    logo:update(dt)
    titleText:update(dt)

    music:update()
end

function titlestate.draw()
    gf:draw(512, 40)
    logo:draw(-100, -50)
    titleText:draw(100, 576)
end

function titlestate.keypressed(key, scancode, isrepeat)
    if not isrepeat then
        if key == "return" then
            -- love.audio.play(confirmSnd)
            switchState(mainmenu)
        end
    end
end

return titlestate