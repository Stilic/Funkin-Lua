local state = {
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

function state.load()
    bf = character:new("bf", 700, 250)
    _c.add(bf)

    susNote = strumnote:new(0, false)
    _c.add(susNote)

    loadBGMusic(paths.inst(state.SONG.song), playstate.SONG.bpm)
end

function state.draw()
    bf:draw()
    susNote:draw()
end

function state.update(dt)
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

function state.beatHit(n) if n % 2 == 0 then bf:dance() end end

return state
