local StrumNote = {}
StrumNote.__index = StrumNote
setmetatable(StrumNote, {__index = sprite})

function StrumNote:new(data, player, x, y)
    self =
        setmetatable(sprite.new(self, paths.atlas("NOTE_assets"), x, y), self)

    self.noteData = data
    self.player = player

    local direction = utils.noteDirections[data + 1]
    self:addByPrefix("static", "arrow" .. string.upper(direction))
    self:addByPrefix("pressed", direction .. " press", 24, false)
    self:addByPrefix("confirm", direction .. " confirm", 24, false)

    self.centerOffsets = true

    self.sizeX = 0.7
    self.sizeY = 0.7

    return self
end

function StrumNote:postAddedToGroup()
    self:playAnim("static")
    self.x =
        self.x + note.swagWidth * self.noteData + 50 + lovesize:getWidth() / 2 *
            self.player
end

function StrumNote:draw() sprite.draw(self, self.width / 4, self.height / 4) end

return StrumNote
