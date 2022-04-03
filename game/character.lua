local Character = {}
Character.__index = Character

setmetatable(Character, {
    __index = sprite,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:new(...)
        return self
    end
})

function Character:new(char, x, y)
    if char == nil then char = "bf" end

    sprite.new(self, nil, x, y)

    self.offsets = {}

    if char == "bf" then
        self:load(paths.atlas("characters/BOYFRIEND"))

        self:addByPrefix("idle", "BF idle dance", nil, false)
        self:addByPrefix("singUP", "BF NOTE UP0", nil, false)
        self:addByPrefix("singLEFT", "BF NOTE LEFT0", nil, false)
        self:addByPrefix("singRIGHT", "BF NOTE RIGHT0", nil, false)
        self:addByPrefix("singDOWN", "BF NOTE DOWN0", nil, false)

        self:addOffset("idle", -5)
        self:addOffset("singUP", -29, 27)
        self:addOffset("singRIGHT", -38, -7)
        self:addOffset("singLEFT", 12, -6)
        self:addOffset("singDOWN", -10, -50)
    end

    return self
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
