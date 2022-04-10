local Character = {}
setmetatable(Character, {__index = sprite})

function Character:new(char, x, y)
    local o = sprite.new(self, nil, x, y)

    o.curCharacter = char or "bf"
    o.offsets = {}

    if o.curCharacter == "bf" then
        o:load(paths.atlas("characters/BOYFRIEND"))

        o:addByPrefix("idle", "BF idle dance", nil, false)
        o:addByPrefix("singUP", "BF NOTE UP0", nil, false)
        o:addByPrefix("singLEFT", "BF NOTE LEFT0", nil, false)
        o:addByPrefix("singRIGHT", "BF NOTE RIGHT0", nil, false)
        o:addByPrefix("singDOWN", "BF NOTE DOWN0", nil, false)

        o:addOffset("idle", -5)
        o:addOffset("singUP", -29, 27)
        o:addOffset("singRIGHT", -38, -7)
        o:addOffset("singLEFT", 12, -6)
        o:addOffset("singDOWN", -10, -50)
    end

    return o
end

function Character:playAnim(anim, forced)
    if self.offsets[anim] ~= nil then
        local offset = self.offsets[anim]
        self.offsetX = offset[1]
        self.offsetY = offset[2]
    else
        self.offsetX = 0
        self.offsetY = 0
    end
    sprite.playAnim(self, anim, forced)
end

function Character:addOffset(anim, x, y)
    if x == nil then x = 0 end
    if y == nil then y = 0 end
    self.offsets[anim] = {x, y}
end

function Character:dance() self:playAnim("idle", true) end

return Character
