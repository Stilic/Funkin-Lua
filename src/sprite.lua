local Sprite = {
    x = 0,
    y = 0,
    angle = 0,

    paused = false,
    destroyed = false,

    gfx = nil,
    xmlData = {},
    animations = {},
    offsets = {},
    firstQuad = nil,
    firstOffset = nil,
    curAnim = {
        name = "",
        quads = {},
        offsets = {},
        length = 0,
        height = 0,
        width = 0,
        framerate = 24,
        loop = false,
        finished = false
    },
    curFrame = 1,
    lastFrame = 1
}
Sprite.__index = Sprite

local function new(path, x, y)
    local self = {x = x, y = y}
    setmetatable(self, Sprite)
    self:loadImage(path)
    return self
end

function Sprite.loadImage(self, path)
    self.gfx = paths.getImage(path)
    self.xmlData = utils.parseAtlas(paths.readXml("images/" .. path))
end

function Sprite.update(self, dt)
    if not self.destroyed then
        if not self.paused then
            self.curFrame = self.curFrame + 10 * (dt * 1.75)
            if self.curFrame >= self.curAnim.length then
                self.curFrame = 1
            end
        else
            self.curFrame = self.lastFrame
        end
    end
end

function Sprite.draw(self, sx, sy)
    if not self.destroyed then
        local spriteNum = math.floor(self.curFrame)
        if not self.paused then
            spriteNum = spriteNum + 1
            self.lastFrame = spriteNum
        else
            spriteNum = self.lastFrame
        end

        local quad = self.curAnim.quads[spriteNum]
        if quad == nil then quad = self.firstQuad end

        local offset = self.offsets[spriteNum]
        if offset == nil then offset = self.firstOffset end

        love.graphics.draw(self.gfx, quad, self.x, self.y, self.angle, sx, sy,
                           offset[0], offset[1])

        if not self.paused and spriteNum >= self.curAnim.length then
            self.curAnim.finished = true
        end
    end
end

function Sprite.addAnim(self, name, prefix, indices, framerate, loop)
    if not self.destroyed then
        if indices == nil then indices = {}; end
        if framerate == nil then framerate = 24 end
        if loop == nil then loop = true end

        for i = 1, #self.xmlData do
            local data = self.xmlData[i]

            if string.match(data["@name"], prefix) then
                local quads = {}
                local offsets = {}
                local length = 0

                for f = 1, #self.xmlData do
                    local data = self.xmlData[f]

                    if string.starts(data["@name"], prefix) then
                        if table.length(indices) == 0 or
                            table.has_value(indices, f) then
                            local x = data["@x"]
                            local y = data["@y"]

                            local width = data["@width"]
                            local height = data["@height"]

                            if data["@frameWidth"] ~= nil then
                                width = data["@frameWidth"]
                            end
                            if data["@frameHeight"] ~= nil then
                                height = data["@frameHeight"]
                                y = y + 2
                            end

                            local quad =
                                love.graphics.newQuad(x, y, width, height,
                                                      self.gfx)

                            if self.firstQuad == nil then
                                self.firstQuad = quad
                            end

                            table.insert(quads, quad)

                            local offset = {0, 0}

                            if data["@frameX"] ~= nil then
                                offset[0] = data["@frameX"]
                            end
                            if data["@frameY"] ~= nil then
                                offset[1] = data["@frameY"]
                            end

                            if self.firstOffset == nil then
                                self.firstOffset = offset
                            end

                            table.insert(offsets, offset)

                            length = length + 1
                        end
                    end
                end

                self.animations[name] = {
                    name = name,
                    quads = quads,
                    offsets = offsets,
                    length = length,
                    framerate = framerate,
                    _duration = length / framerate / 1.25,
                    loop = loop
                }

                break
            end
        end
    end
end

function Sprite.removeAnim(self, name)
    if self.animations[name] ~= nil then
        if self.curAnim.name == name then self:stop() end

        self.animations[name] = nil
        return true
    end

    return false
end

function Sprite.playAnim(self, anim, forced)
    if forced == nil then forced = false end

    if not self.destroyed and not self.paused and self.animations[anim] ~= nil then
        if not forced and anim == self.curAnim.name then return end

        self.curAnim = self.animations[anim]
        self.curAnim.finished = false
        self.curFrame = 1
        self.lastFrame = 1
    end
end

function Sprite.getCurrentAnim(self) return self.curAnim end

function Sprite.pause(self) self.paused = true end

function Sprite.play(self) self.paused = false end

function Sprite.stop(self) self.curAnim = nil end

function Sprite.destroy(self)
    if not self.destroyed then
        self:stop()
        self.curFrame = 1
        self.lastFrame = 1
        self.gfx:release()

        for a = 1, #self.animations do
            for q = 1, #self.animations[a].quads do
                self.animations[a].quads[q]:release()
            end
        end
        self.animations = {}
        self.firstQuad = nil
        self.firstOffset = nil
        self.xmlData = nil

        self.destroyed = true

        collectgarbage("collect")

        return true
    end

    return false
end

return {
    new = new, -- constructor
    __object = Sprite -- object table/metatable
}
