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
    },
    strumX = 42
}

local generatedMusic

local vocals

-- local bf

local notes
local fakeNote

local playerStrums
local opponentStrums

local function generateStaticArrows(player)
    for i = 1, 4 do
        local leData = i - 1

        local strum = strumnote:new(leData, player, state.strumX, 50)
        strum:postAddedToGroup()

        if player == 1 then
            playerStrums[i] = strum
        else
            opponentStrums[i] = strum
        end
    end
end

local function sortByShit(a, b) return a.strumTime < b.strumTime end

local function generateSong()
    if state.SONG.needsVoices then
        vocals = love.audio.newSource(paths.voices(state.SONG.song), "stream")
        _c.add(vocals)
    else
        vocals = nil
    end

    notes = {}

    local songData = state.SONG.notes

    local offset = lovesize:getWidth() / 2
    local size = 0.7

    for i, section in ipairs(songData) do
        for b, songNotes in ipairs(section.sectionNotes) do
            local daStrumTime = songNotes[1]
            local daNoteData = math.floor(songNotes[2] % 4) + 1
            local x = state.strumX + 50 + note.swagWidth * (daNoteData % 4)

            local gottaHitNote = section.mustHitSection
            if songNotes[2] > 3 then gottaHitNote = not gottaHitNote end
            if gottaHitNote then x = x + offset end

            local oldNote
            if #notes > 0 then oldNote = notes[#notes] end

            local swagNote = {
                x = x,
                y = 0,
                sizeX = size,
                sizeY = size,
                strumTime = daStrumTime,
                noteData = daNoteData,
                mustPress = gottaHitNote,
                prevNote = oldNote,
                isSustainNote = false,
                sustainLength = songNotes[3]
            }
            -- print("made note: time is " .. daStrumTime .. ", data is " ..
            --           daNoteData, ", should press: " .. ("yes" or "no" and gottaHitNote))

            -- yeah period is same as stepCrochet
            table.insert(notes, swagNote)

            local floorSus = math.floor(swagNote.sustainLength / BGMusic.period)
            if floorSus > 0 then
                for susNote = 0, floorSus do
                    oldNote = notes[#notes]

                    local sustainNote = {
                        x = x,
                        y = 0,
                        sizeX = size,
                        sizeY = size,
                        strumTime = daStrumTime + BGMusic.period * susNote +
                            BGMusic.period / utils.round(state.SONG.speed, 2),
                        noteData = daNoteData,
                        mustPress = gottaHitNote,
                        prevNote = oldNote,
                        isSustainNote = true,
                        isHoldEnd = susNote == floorSus
                    }
                    -- print("made sus note " .. susNote .. ": time is " .. sustainNote.strumTime ..
                    --           ", data is " .. daNoteData,
                    --       ", should press: "  .. ("yes" or "no" and gottaHitNote))

                    table.insert(notes, sustainNote)
                end
            end
        end
    end
    table.sort(notes, sortByShit)

    generatedMusic = true
end

local function playVocals() if vocals ~= nil then vocals:play() end end

local function pauseVocals() if vocals ~= nil then vocals:pause() end end

local function endSong()
    pauseVocals()
    switchState(mainmenu)
    resetBGMusic()
end

local function startSong()
    loadBGMusic(paths.inst(state.SONG.song), playstate.SONG.bpm)
    BGMusic:setLooping(false)

    playVocals()
end

function state.load()
    -- bf = character:new("bf", 700, 250)
    -- _c.add(bf)

    generatedMusic = false

    playerStrums = {}
    opponentStrums = {}

    generateStaticArrows(0)
    generateStaticArrows(1)

    _c.add(playerStrums)
    _c.add(opponentStrums)

    fakeNote = note:new()

    generateSong()
    startSong()
end

function state.songEnd() endSong() end

function state.draw()
    -- bf:draw()

    utils.callGroup(playerStrums, "draw")
    utils.callGroup(opponentStrums, "draw")

    love.graphics.push()
    love.graphics.translate(0, -BGMusic:getTime() * 1000 *
                                (0.45 * utils.round(state.SONG.speed, 2)))
    for n, daNote in ipairs(notes) do
        fakeNote:loadNote(daNote)
        fakeNote:draw()
    end
    love.graphics.pop()
end

function state.update(dt)
    -- bf:update(dt)

    utils.callGroup(playerStrums, "update", dt)
    utils.callGroup(opponentStrums, "update", dt)

    local musicTime = BGMusic:getTime()

    if generatedMusic then
        local height = lovesize:getHeight()

        for n, daNote in ipairs(notes) do
            if -daNote.y > height then
                daNote.active = false
                daNote.visible = false
            else
                daNote.active = true
                daNote.visible = true
            end

            daNote.y = 50 - (musicTime - daNote.strumTime) *
                           (0.45 * utils.round(state.SONG.speed, 2))

            -- if daNote.y < -height then
            --     table.remove(notes, n)
            --     daNote:destroy()
            -- end
        end
    end

    utils.callGroup(notes, "update", dt)

    if input:pressed "back" then endSong() end

    -- if input:pressed "left" then bf:playAnim("singLEFT", true) end
    -- if input:pressed "right" then bf:playAnim("singRIGHT", true) end
    -- if input:pressed "up" then bf:playAnim("singUP", true) end
    -- if input:pressed "down" then bf:playAnim("singDOWN", true) end

    if input:pressed "accept" then
        if BGMusic.playing then
            pauseBGMusic()
            pauseVocals()
        else
            playBGMusic()
            playVocals()
        end
    end

    for i = 1, #playerStrums do
        if input:pressed(utils.noteDirections[i]) then
            playerStrums[i]:playAnim("confirm", true)
        end
        if input:released(utils.noteDirections[i]) then
            playerStrums[i]:playAnim("static", true)
        end
    end
end

-- function state.beatHit(n) if n % 2 == 0 then bf:dance() end end

return state
