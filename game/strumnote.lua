local StrumNote = {}
StrumNote.__index = StrumNote
setmetatable(StrumNote, {__index = sprite})

function StrumNote:new(data, player, x, y)
    self =
        setmetatable(sprite.new(self, paths.atlas("NOTE_assets"), x, y), self)

    self.noteData = data
    self.player = player
    self.direction = 90

    local direction = utils.noteDirections[data + 1]
    self:addByPrefix("static", "arrow" .. string.upper(direction))
    self:addByPrefix("pressed", direction .. " press", 24, false)
    self:addByPrefix("confirm", direction .. " confirm", 24, false)

    if data > 0 and data < 4 then
        local ox = -2
        local oy = -2

        if data == 1 then
            oy = -4
        end

        self:addOffset("pressed", 5 + ox, 5 + oy)
        self:addOffset("confirm", ox, oy)
    end

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
