local PlayState = {
    SONG = {
        song = "test",
        notes = {},
        bpm = 102,
        needsVoices = true,
        speed = 1,
        player1 = "bf",
        player2 = "bf",
        player3 = "gf",
        gfVersion = "gf"
    }
}

local bf
local susNote

function PlayState.load()
    bf = character("bf", 700, 250)
    _c.add(bf)

    susNote = strumnote(0, false)

    loadBGMusic(paths.inst(PlayState.SONG.song), playstate.SONG.bpm)
end

function PlayState.draw()
    bf:draw()
    susNote:draw()
end

function PlayState.update(dt)
    bf:update(dt)
    susNote:update(dt)

    if input:pressed "back" then
        resetBGMusic()
        switchState(mainmenu)
    end

    if input:pressed "left" then bf:playAnim("singLEFT", true) end
    if input:pressed "right" then bf:playAnim("singRIGHT", true) end
    if input:pressed "up" then bf:playAnim("singUP", true) end
    if input:pressed "down" then bf:playAnim("singDOWN", true) end

    if input:pressed "left" then susNote:playAnim("confirm", true) end
    if input:released "left" then susNote:playAnim("static", true) end
end

function PlayState.beatHit(n) if n % 2 == 0 then bf:dance() end end

return PlayState