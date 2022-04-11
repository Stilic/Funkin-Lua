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

local vocals

local bf

local playerStrums
local opponentStrums

local function generateStaticArrows(player)
    for i = 1, 4 do
        local leData = i - 1

        local strum = strumnote:new(leData, player,
                                    42 + note.swagWidth * leData + 50 +
                                        (lovesize.getWidth() / 2) * player, 50)

        if player == 1 then
            opponentStrums[i] = strum
        else
            playerStrums[i] = strum
        end
    end
end

local function endSong()
    resetBGMusic()
    switchState(mainmenu)
end

function state.load()
    bf = character:new("bf", 700, 250)
    _c.add(bf)

    playerStrums = {}
    opponentStrums = {}

    generateStaticArrows(0)
    generateStaticArrows(1)

    _c.add(playerStrums)
    _c.add(opponentStrums)

    loadBGMusic(paths.inst(state.SONG.song), playstate.SONG.bpm)
    BGMusic:setLooping(false)

    vocals = love.audio.newSource(paths.voices(state.SONG.song), "stream")
    _c.add(vocals)
    vocals:play()
end

function state.draw()
    bf:draw()
    utils.callGroup(playerStrums, "draw")
    utils.callGroup(opponentStrums, "draw")
end

function state.update(dt)
    bf:update(dt)
    utils.callGroup(playerStrums, "update", dt)
    utils.callGroup(opponentStrums, "update", dt)

    if input:pressed "back" then endSong() end

    if input:pressed "left" then bf:playAnim("singLEFT", true) end
    if input:pressed "right" then bf:playAnim("singRIGHT", true) end
    if input:pressed "up" then bf:playAnim("singUP", true) end
    if input:pressed "down" then bf:playAnim("singDOWN", true) end

    -- if input:pressed "left" then susNote:playAnim("confirm", true) end
    -- if input:released "left" then susNote:playAnim("static", true) end
end

function state.songEnd()
    endSong()
end

function state.beatHit(n) if n % 2 == 0 then bf:dance() end end

return state
