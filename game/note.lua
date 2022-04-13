local Note = {
    swagWidth = 160 * 0.7,
    directions = {'left', 'down', 'up', 'right'}
}
Note.__index = Note
setmetatable(Note, {__index = sprite})

function Note.getRawDirection(i) return note.directions[i - 1] end

function Note:new(strumTime, noteData, prevNote, sustainNote)
    self =
        setmetatable(sprite.new(self, paths.atlas("NOTE_assets"), x, y), self)

    self.strumTime = strumTime
    self.noteData = noteData
    self.prevNote = prevNote or nil
    self.sustainNote = sustainNote or nil

    self:addByPrefix("greenScroll", "green0")
    self:addByPrefix("blueScroll", "red0")
    self:addByPrefix("purpleScroll", "blue0")
    self:addByPrefix("redScroll", "purple0")

    self:addByPrefix("purpleholdend", "pruple end hold")
    self:addByPrefix("greenholdend", "green end hold")
    self:addByPrefix("redholdend", "red end hold")
    self:addByPrefix("blueholdend", "blue end hold")

    self:addByPrefix("purplehold", "purple hold piece")
    self:addByPrefix("greenhold", "green hold piece")
    self:addByPrefix("redhold", "red hold piece")
    self:addByPrefix("bluehold", "blue hold piece")

    self.x = self.x + Note.swagWidth * noteData

    if (noteData == 0) then self:playAnim('purpleScroll') end

    self.sizeX = 0.7
    self.sizeY = 0.7

    self:playAnim("static")

    return self
end

return Note
