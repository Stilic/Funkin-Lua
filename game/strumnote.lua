local StrumNote = {}
setmetatable(StrumNote, {__index = sprite})

function StrumNote:new(data, player, x, y)
    local o = sprite.new(self, paths.atlas("NOTE_assets"), x, y)

    o.noteData = data
    o.player = player

    o:addByPrefix('green', 'arrowUP')
    o:addByPrefix('blue', 'arrowDOWN')
    o:addByPrefix('purple', 'arrowLEFT')
    o:addByPrefix('red', 'arrowRIGHT')

    if data == 0 then
        o:addByPrefix('static', 'arrowLEFT')
        o:addByPrefix('pressed', 'left press', 24, false)
        o:addByPrefix('confirm', 'left confirm', 24, false)
    elseif data == 1 then
        o:addByPrefix('static', 'arrowDOWN')
        o:addByPrefix('pressed', 'down press', 24, false)
        o:addByPrefix('confirm', 'down confirm', 24, false)
    elseif data == 2 then
        o:addByPrefix('static', 'arrowUP')
        o:addByPrefix('pressed', 'up press', 24, false)
        o:addByPrefix('confirm', 'up confirm', 24, false)
    elseif data == 3 then
        o:addByPrefix('static', 'arrowRIGHT')
        o:addByPrefix('pressed', 'right press', 24, false)
        o:addByPrefix('confirm', 'right confirm', 24, false)
    end

    o.centerOffsets = true

    o.sizeX = 0.7
    o.sizeY = 0.7

    o:playAnim("static")

    return o
end

function StrumNote:draw() sprite.draw(self, self.width / 4, self.height / 4) end

return StrumNote
