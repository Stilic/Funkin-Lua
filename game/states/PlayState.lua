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
            playerStrums[i] = strum
        else
            opponentStrums[i] = strum
        end
    end
end

local function generateSong()
    loadBGMusic(paths.inst(state.SONG.song), playstate.SONG.bpm)
    BGMusic:setLooping(false)

    vocals = love.audio.newSource(paths.voices(state.SONG.song), "stream")
    vocals:play()
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

    generateSong()
    _c.add(vocals)
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

    for i = 1, #playerStrums do
        if input:pressed(note.directions[i]) then
            playerStrums[i]:playAnim("confirm", true)
        end
        if input:released(note.directions[i]) then
            playerStrums[i]:playAnim("static", true)
        end
    end
end

function state.songEnd() endSong() end

function state.beatHit(n) if n % 2 == 0 then bf:dance() end end

return state
