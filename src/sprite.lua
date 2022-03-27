local xml = require("lib.xmlSimple").newParser()

local Sprite = {
    x = 0,
    y = 0,
    angle = 0,

    sizeX = 1,
    sizeY = 1,

    offsetX = 0,
    offsetY = 0,

    paused = false,
    destroyed = false,

    gfx = nil,
    xmlData = {},
    animations = {},
    firstFrame = nil,
    curAnim = {
        name = "",
        frames = {},
        length = 0,
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

local function tableHasValue(table, val)
    for index, value in ipairs(table) do if value == val then return true end end
    return false
end

function Sprite.loadImage(self, path)
    self.gfx = love.graphics.newImage(path .. ".png")

    local contents, size = love.filesystem.read(path .. ".xml")
    self.xmlData = xml:ParseXmlText(contents).TextureAtlas.SubTexture

    return self
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

function Sprite.draw(self)
    if not self.destroyed then
        local spriteNum = math.floor(self.curFrame)
        if not self.paused then
            spriteNum = spriteNum + 1
            self.lastFrame = spriteNum
        else
            spriteNum = self.lastFrame
        end

        local frame = self.curAnim.frames[spriteNum]
        if frame == nil then frame = self.firstFrame end

        love.graphics.draw(self.gfx, frame.quad, self.x, self.y, self.angle,
                           self.sizeX, self.sizeY,
                           frame.offsets.x + self.offsetX,
                           frame.offsets.y + self.offsetY)

        if not self.paused and spriteNum >= self.curAnim.length then
            self.curAnim.finished = true
        end
    end
end

function Sprite.addAnim(self, name, prefix, indices, framerate, loop)
    if not self.destroyed then
        if indices == nil then indices = {} end
        if framerate == nil then framerate = 24 end
        if loop == nil then loop = true end

        for i = 1, #self.xmlData do
            local data = self.xmlData[i]

            if string.match(data["@name"], prefix) then
                local anim = {
                    name = name,
                    frames = {},
                    length = 0,
                    framerate = framerate,
                    loop = loop
                }

                for f = 1, #self.xmlData do
                    local data = self.xmlData[f]

                    if string.sub(data["@name"], 1, string.len(prefix)) ==
                        prefix then
                        if #indices == 0 or tableHasValue(indices, f) then
                            local frame = {
                                quad = love.graphics.newQuad(data["@x"],
                                                             data["@y"],
                                                             data["@width"],
                                                             data["@height"],
                                                             self.gfx:getDimensions()),
                                width = data["@width"],
                                height = data["@height"]
                            }

                            local offsetX = data["@frameX"]
                            if offsetX == nil then
                                offsetX = 0
                            end
                            local offsetY = data["@frameY"]
                            if offsetY == nil then
                                offsetY = 0
                            end

                            local offsetWidth = data["@frameWidth"]
                            if offsetWidth == nil then
                                offsetWidth = 0
                            end
                            local offsetHeight = data["@frameHeight"]
                            if offsetHeight == nil then
                                offsetHeight = 0
                            end

                            frame.offsets = {
                                x = offsetX,
                                y = offsetY,
                                width = offsetWidth,
                                height = offsetHeight
                            }

                            if self.firstFrame == nil then
                                self.firstFrame = frame
                            end
                            table.insert(anim.frames, frame)

                            anim.length = anim.length + 1
                        end
                    end
                end

                self.animations[name] = anim

                break
            end
        end
    end

    return self
end

function Sprite.removeAnim(self, name)
    if self.animations[name] ~= nil then
        if self.curAnim.name == name then self:stop() end
        self.animations[name] = nil
    end
    return self
end

function Sprite.playAnim(self, anim, forced)
    if forced == nil then forced = false end

    if not self.destroyed and not self.paused and self.animations[anim] ~= nil then
        if not forced and anim == self.curAnim.name then return end

        if anim ~= self.curAnim.name then
            self.curAnim = self.animations[anim]
        end
        self.curAnim.finished = false
        self.curFrame = 1
        self.lastFrame = 1
    end

    return self
end

function Sprite.getCurrentAnim(self) return self.curAnim end

function Sprite.pause(self)
    self.paused = true
    return self
end

function Sprite.play(self)
    self.paused = false
    return self
end

function Sprite.stop(self)
    self.curAnim = nil
    return self
end

function Sprite.destroy(self)
    if not self.destroyed then
        self:stop()
        self.curFrame = 1
        self.lastFrame = 1
        self.gfx:release()

        self.animations = {}
        self.firstFrame = nil
        self.xmlData = nil

        self.destroyed = true

        collectgarbage("collect")
    end

    return self
end

return {
    new = new, -- constructor
    __object = Sprite -- object table/metatable
}
