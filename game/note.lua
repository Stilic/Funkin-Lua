local Note = {swagWidth = 160 * 0.7}
Note.__index = Note
setmetatable(Note, {__index = sprite})

function Note:new(strumTime, noteData, prevNote, isSustainNote)
    self =
        setmetatable(sprite.new(self, paths.atlas("NOTE_assets"), x, y), self)

    self.strumTime = strumTime
    self.noteData = noteData + 1
    self.prevNote = prevNote or nil
    self.isSustainNote = isSustainNote or nil

    self.mustPress = false

    self.sustainLength = 0
    self.isHoldEnd = false

    self.x = self.x + playstate.strumX + 50 + note.swagWidth * (noteData % 4)

    self.sizeX = 0.7
    self.sizeY = 0.7

    local color = utils.noteColors[self.noteData]
    self:addByPrefix("greenScroll", "green0")
    self:addByPrefix("redScroll", "red0")
    self:addByPrefix("blueScroll", "blue0")
    self:addByPrefix("purpleScroll", "purple0")

    self:playAnim(color .. "Scroll")

    if self.isSustainNote and self.prevNote ~= nil then
        self:addByPrefix("purpleholdend", "green hold end")
        self:addByPrefix("greenholdend", "green hold end")
        self:addByPrefix("redholdend", "red hold end")
        self:addByPrefix("blueholdend", "blue hold end")

        self:addByPrefix("purplehold", "green hold piece")
        self:addByPrefix("greenhold", "green hold piece")
        self:addByPrefix("redhold", "red hold piece")
        self:addByPrefix("bluehold", "blue hold piece")

        self:playAnim(color .. "holdend")

        self.x = self.x + self.width / 4.25
        self.isHoldEnd = true

        if self.prevNote.isSustainNote then
            self.prevNote.isHoldEnd = false

            color = utils.noteColors[self.prevNote.noteData]
            self.prevNote:playAnim(color .. "hold")

            self.prevNote.sizeY = self.prevNote.sizeY *
                                      (BGMusic.period / 1000 * 1.5) +
                                      playstate.SONG.speed
        end
    end

    return self
end

return Note
