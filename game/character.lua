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

    self.addX = 0
    self.addY = 0

    if char == 'bf' then
        self:loadImage(paths.atlas("characters/BOYFRIEND"))

        self:addByPrefix("idle", "BF idle dance", nil, false)
    end

    return self
end

function Character:draw() sprite.draw(self, self.addX, self.addY) end

function Character:playAnim(anim, forced)
    if self.offsets[anim] ~= nil then
        local offset = self.offsets[anim]
        self.addX = offset[1]
        self.addY = offset[2]
    else
        self.addX = 0
        self.addY = 0
    end
    sprite.playAnim(self, anim, forced)
end

function Character:addOffset(anim, x, y) self.offsets[anim] = {x, y} end

function Character:dance() self:playAnim("idle", true) end

return Character
