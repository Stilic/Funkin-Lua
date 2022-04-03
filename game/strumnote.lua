local StrumNote = {}
StrumNote.__index = StrumNote

setmetatable(StrumNote, {
    __index = sprite,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:new(...)
        return self
    end
})

function StrumNote:new(data, player, x, y)
    if char == nil then char = "bf" end

    sprite.new(self, paths.atlas("NOTE_assets"), x, y)

    self.noteData = data
    self.player = player

    self:addByPrefix('green', 'arrowUP')
    self:addByPrefix('blue', 'arrowDOWN')
    self:addByPrefix('purple', 'arrowLEFT')
    self:addByPrefix('red', 'arrowRIGHT')

    if data == 0 then
        self:addByPrefix('static', 'arrowLEFT')
        self:addByPrefix('pressed', 'left press', 24, false)
        self:addByPrefix('confirm', 'left confirm', 24, false)
    elseif data == 1 then
        self:addByPrefix('static', 'arrowDOWN')
        self:addByPrefix('pressed', 'down press', 24, false)
        self:addByPrefix('confirm', 'down confirm', 24, false)
    elseif data == 2 then
        self:addByPrefix('static', 'arrowUP')
        self:addByPrefix('pressed', 'up press', 24, false)
        self:addByPrefix('confirm', 'up confirm', 24, false)
    elseif data == 3 then
        self:addByPrefix('static', 'arrowRIGHT')
        self:addByPrefix('pressed', 'right press', 24, false)
        self:addByPrefix('confirm', 'right confirm', 24, false)
    end

    self.centerOffsets = true

    self.sizeX = 0.7
    self.sizeY = 0.7

    self:playAnim("static")

    return self
end

function StrumNote:draw()
    sprite.draw(self, self.width / 4, self.height / 4)
end

-- function StrumNote:playAnim(anim, forced)
--     if self.offsets[anim] ~= nil then
--         local offset = self.offsets[anim]
--         self.offsetX = offset[1]
--         self.offsetY = offset[2]
--     else
--         self.offsetX = 0
--         self.offsetY = 0
--     end
--     sprite.playAnim(self, anim, forced)
-- end

return StrumNote
