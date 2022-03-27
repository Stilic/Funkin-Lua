local LoveGroup = {sprites = {}, length = 0}
LoveGroup.__index = LoveGroup

local function new() return setmetatable({}, LoveGroup) end

function LoveGroup.add(self, spr)
    spr.ID = self.length
    self.sprites[self.length] = spr
    self.length = self.length + 1
end

function LoveGroup.remove(self, spr)
    for k, s in pairs(self.sprites) do
        if spr == s then utils.clearSprite(s) end
    end
end

function LoveGroup.get(self, id) return self.sprites[id] end

function LoveGroup.clear(self)
    for k, s in pairs(self.sprites) do
        utils.clearSprite(s)
        _c.remove(s)

        self.sprites[k] = nil
    end

    self.sprites = {}
    collectgarbage("collect")
end

function LoveGroup.beatHit(self, n)
    for k, s in pairs(self.sprites) do
        if s.beatHit ~= nil then s:beatHit(n) end
    end
end

function LoveGroup.update(self, dt)
    for k, s in pairs(self.sprites) do
        if s.update ~= nil then s:update(dt) end
    end
end

function LoveGroup.draw(self)
    for k, s in pairs(self.sprites) do if s.draw ~= nil then s:draw() end end
end

function LoveGroup.keypressed(self, key, scancode, isrepeat)
    for k, s in pairs(self.sprites) do
        if s.keypressed ~= nil then s:keypressed(key, scancode, isrepeat) end
    end
end

return {
    new = new, -- constructor
    __object = LoveGroup -- object table/metatable
}
