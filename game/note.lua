local Note = {swagWidth = 160 * 0.7}
Note.__index = Note
setmetatable(Note, {__index = sprite})

function Note:new()
    self = setmetatable(sprite.new(self, paths.atlas("NOTE_assets")), self)

    self:addByPrefix("greenScroll", "green0")
    self:addByPrefix("redScroll", "red0")
    self:addByPrefix("blueScroll", "blue0")
    self:addByPrefix("purpleScroll", "purple0")

    self:addByPrefix("purpleholdend", "pruple end hold")
    self:addByPrefix("greenholdend", "green hold end")
    self:addByPrefix("redholdend", "red hold end")
    self:addByPrefix("blueholdend", "blue hold end")

    self:addByPrefix("purplehold", "purple hold piece")
    self:addByPrefix("greenhold", "green hold piece")
    self:addByPrefix("redhold", "red hold piece")
    self:addByPrefix("bluehold", "blue hold piece")

    return self
end

function Note:loadNote(note)
    local color = utils.noteColors[note.noteData + 1]

    self.x, self.y = note.x, note.y
    self.sizeX, self.sizeY = note.sizeX, note.sizeY

    if note.isSustainNote then
        if note.isHoldEnd then
            self:playAnim(color .. "holdend")
        else
            color = utils.noteColors[note.prevNote.noteData + 1]
            self:playAnim(color .. "hold")

            self.sizeY = self.sizeY * BGMusic.period / 100 * 1.5 *
                             playstate.SONG.speed
        end
    else
        self:playAnim(color .. "Scroll")
    end
end

return Note
