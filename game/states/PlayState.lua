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

local songPosition = 0
local safeZoneOffset = 10 / 60 * 1000

local notes
local fakeNote

local playerStrums
local opponentStrums

local healthBar

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

local function sortByShit(a, b) return a.strumTime > b.strumTime end

local function generateSong()
    if state.SONG.needsVoices then
        vocals = love.audio.newSource(paths.voices(state.SONG.song), "stream")
        _c.add(vocals)
    else
        vocals = nil
    end

    notes = {}

    local songData = state.SONG.notes
    local roundedSpeed = utils.round(state.SONG.speed, 2)
    local leSpeed = 0.45 * roundedSpeed

    local offset = lovesize:getWidth() / 2
    local size = 0.7
    local update = function(self, dt)
        if self.mustPress then
            self.canBeHit = self.strumTime > songPosition - safeZoneOffset and
                self.strumTime < songPosition + safeZoneOffset *
                self.earlyHitMult

            if self.strumTime < songPosition - safeZoneOffset and
                not self.wasGoodHit then self.tooLate = true end
        else
            self.canBeHit = false

            if self.strumTime < songPosition + safeZoneOffset *
                self.earlyHitMult and
                ((self.isSustainNote and self.prevNote.wasGoodHit) or
                    self.strumTime <= songPosition) then
                self.wasGoodHit = true
            end
        end
    end

    for i, section in ipairs(songData) do
        for b, songNotes in ipairs(section.sectionNotes) do
            local daStrumTime = songNotes[1]
            local daNoteData = math.floor(songNotes[2] % 4)
            local x = state.strumX + 50 + note.swagWidth * (daNoteData % 4)

            local gottaHitNote = section.mustHitSection
            if songNotes[2] > 3 then gottaHitNote = not gottaHitNote end
            if gottaHitNote then x = x + offset end

            local oldNote
            if #notes > 0 then oldNote = notes[#notes] end

            local swagNote = {
                x = x,
                y = 50 + daStrumTime * leSpeed,
                distance = 0,

                sizeX = size,
                sizeY = size,

                strumTime = daStrumTime,
                noteData = daNoteData,
                mustPress = gottaHitNote,

                prevNote = oldNote,
                isSustainNote = false,
                sustainLength = songNotes[3],

                earlyHitMult = 1,
                wasGoodHit = false,
                tooLate = false,

                copyX = true,
                copyY = true,
                copyAngle = true,
                copyAlpha = true,

                multAlpha = 1,

                update = update
            }
            -- print("made note: time is " .. daStrumTime .. ", data is " ..
            --           daNoteData, ", should press: " .. ("yes" or "no" and gottaHitNote))

            -- yeah period is same as stepCrochet
            table.insert(notes, swagNote)

            local floorSus = math.floor(swagNote.sustainLength / BGMusic.period)
            if floorSus > 0 then
                for susNote = 0, floorSus do
                    oldNote = notes[#notes]
                    local susTime = daStrumTime + BGMusic.period * susNote +
                        BGMusic.period / roundedSpeed

                    local sustainNote = {
                        x = x,
                        y = 50 + susTime * leSpeed,
                        distance = 0,

                        sizeX = size,
                        sizeY = size,

                        strumTime = susTime,
                        noteData = daNoteData,
                        mustPress = gottaHitNote,

                        prevNote = oldNote,
                        isSustainNote = true,
                        isHoldEnd = susNote == floorSus,

                        earlyHitMult = 0.5,
                        wasGoodHit = false,
                        tooLate = false,

                        copyX = true,
                        copyY = true,
                        copyAngle = true,
                        copyAlpha = true,

                        multAlpha = 0.6,

                        update = update
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
    resetBGMusic()
    switchState(mainmenu)
end

local function startSong()
    loadBGMusic(paths.inst(state.SONG.song), playstate.SONG.bpm)
    BGMusic:setLooping(false)

    playVocals()
end

function state.load()
    -- bf = character:new("bf", 700, 250)

    BGMusic:pause()
    BGMusic:setTime(0)
    songPosition = 0

    generatedMusic = false

    playerStrums = {}
    opponentStrums = {}

    generateStaticArrows(0)
    generateStaticArrows(1)

    healthBar = paths.getImage("healthBar")
    _c.add(healthBar)

    fakeNote = note:new()

    generateSong()
    tick.delay(startSong, 2)
end

function state.songEnd() endSong() end

function state.update(dt)
    -- bf:update(dt)

    utils.callGroup(playerStrums, "update", dt)
    utils.callGroup(opponentStrums, "update", dt)

    if not isTransitioning and not trans.out then
        songPosition = BGMusic:getTime() * 1000
    end

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
            playerStrums[i]:playAnim("pressed", true)
        end
        if input:released(utils.noteDirections[i]) then
            playerStrums[i]:playAnim("static", true)
        end
    end
end

local function drawNote(daNote)
    fakeNote:loadNote(daNote)

    local strum
    if daNote.mustPress then
        strum = playerStrums[daNote.noteData + 1]
    else
        strum = opponentStrums[daNote.noteData + 1]
    end

    daNote.distance = -0.45 * (songPosition - daNote.strumTime) *
        state.SONG.speed

    if daNote.copyAngle then
        fakeNote.angle = strum.direction - 90 + strum.angle
    end
    if daNote.copyAlpha then fakeNote.alpha = strum.alpha * daNote.multAlpha end

    local angleDir = strum.direction * math.pi / 180
    if daNote.copyX then
        fakeNote.x = strum.x + math.cos(angleDir) * daNote.distance
        if daNote.isSustainNote then
            fakeNote.x = fakeNote.x + fakeNote.width / 4.25
        end
    end
    if daNote.copyY then
        fakeNote.y = strum.y + math.sin(angleDir) * daNote.distance
        if daNote.isSustainNote then
            fakeNote.y = fakeNote.y + fakeNote.height / 2
        end
    end

    if not utils.offscreen(fakeNote) then fakeNote:draw() end
end

function state.draw()
    -- bf:draw()

    utils.callGroup(playerStrums, "draw")
    utils.callGroup(opponentStrums, "draw")

    if generatedMusic then
        for n, daNote in ipairs(notes) do
            drawNote(daNote)
        end
    end

    love.graphics.draw(healthBar, lovesize.getWidth() / 2 - healthBar:getWidth() / 2, 650)
end

return state
