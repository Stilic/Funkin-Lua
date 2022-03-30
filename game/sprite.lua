local xml = require("lib.xmlSimple").newParser()

local Sprite = {}
Sprite.__index = Sprite

images = {}

local function new(path, x, y)
    local self = {
        x = x,
        y = y,
        angle = 0,

        sizeX = 1,
        sizeY = 1,

        offsetX = 0,
        offsetY = 0,
        centerOffsets = false,

        paused = false,
        destroyed = false,

        path = nil,
        xmlData = {},

        animations = {},
        firstFrame = nil,
        curAnim = {
            name = "",
            frames = {},
            indices = {},
            offsets = {},
            length = 0,
            framerate = 24,
            loop = false,
            finished = false
        },
        curFrame = 1
    }
    setmetatable(self, Sprite)
    self:loadImage(path)
    return self
end

local function tableHasValue(table, val)
    for index, value in ipairs(table) do
        if value == val then
            return true
        end
    end
    return false
end

function Sprite:loadImage(path)
    self.path = path

    local lePath = path .. ".png"
    if images[lePath] == nil then
        images[lePath] = love.graphics.newImage(lePath)
    end

    local contents, size = love.filesystem.read(path .. ".xml")
    self.xmlData = xml:ParseXmlText(contents).TextureAtlas.SubTexture

    return self
end

function Sprite:update(dt)
    if self.curAnim ~= nil and not self.destroyed then
        local frame = self.curFrame + dt * self.curAnim.framerate
        if not self.paused or (self.curAnim.indices ~= nil and tableHasValue(self.curAnim.frames, frame)) then
            self.curFrame = frame
            if self.curFrame >= self.curAnim.length - 1 then
                if self.curAnim.loop then
                    self.curFrame = 0
                else
                    self.curFrame = self.curAnim.length - 1
                end
            end
        end
    end
end

function Sprite:draw()
    if self.curAnim ~= nil and not self.destroyed then
        local spriteNum = math.floor(self.curFrame)
        if not self.paused then
            spriteNum = spriteNum + 1
        end

        local frame = self.curAnim.frames[spriteNum]
        if frame == nil then
            frame = self.firstFrame
        end

        local centerX = 0
        local centerY = 0
        -- LOL SO CRINGE WORK I DONE
        if self.centerOffsets then
            centerX = frame.width / 2 + frame.offsets.x / 2
            centerY = -frame.height / 35 + frame.height / 3 + frame.offsets.y / 2
        end

        love.graphics.draw(images[self.path .. ".png"], frame.quad, self.x, self.y, self.angle, self.sizeX, self.sizeY,
            frame.offsets.x + centerX + self.offsetX, frame.offsets.y + centerY + self.offsetY)

        if not self.paused and not self.curAnim.loop and spriteNum >= self.curAnim.length then
            self.curAnim.finished = true
        end
    end
end

function Sprite:addByPrefix(name, prefix, framerate, loop)
    self:__addAnim(name, prefix, nil, framerate, loop)
end

function Sprite:addByIndices(name, prefix, indices, framerate, loop)
    self:__addAnim(name, prefix, indices, framerate, loop)
end

function Sprite:__addAnim(name, prefix, indices, framerate, loop)
    if not self.destroyed then
        if framerate == nil then
            framerate = 24
        end
        if loop == nil then
            loop = true
        end

        local anim = {
            name = name,
            frames = {},
            indices = indices,
            length = 0,
            framerate = framerate,
            loop = loop
        }

        for f = 1, #self.xmlData do
            local data = self.xmlData[f]

            if string.sub(data["@name"], 1, string.len(prefix)) == prefix then
                if (indices == nil or indices == {}) or tableHasValue(indices, f) then
                    local frame = {
                        quad = love.graphics.newQuad(data["@x"], data["@y"], data["@width"], data["@height"],
                            images[self.path .. ".png"]:getDimensions()),
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
    end

    return self
end

function Sprite:removeAnim(name)
    if self.animations[name] ~= nil then
        if self.curAnim.name == name then
            self:stop()
        end
        self.animations[name] = nil
    end
    return self
end

function Sprite:playAnim(anim, forced)
    if forced == nil then
        forced = false
    end

    if not self.destroyed and not self.paused and self.animations[anim] ~= nil then
        if not forced and anim == self.curAnim.name then
            return
        end

        if anim ~= self.curAnim.name then
            self.curAnim = self.animations[anim]
        end
        self.curAnim.finished = false
        self.curFrame = 0
    end

    return self
end

function Sprite:pause()
    self.paused = true
    return self
end

function Sprite:play()
    self.paused = false
    return self
end

function Sprite:stop()
    self.curAnim = nil
    return self
end

function Sprite:destroy()
    if not self.destroyed then
        self:stop()
        self.curFrame = 0

        images[self.path .. ".png"] = nil

        self.animations = {}
        self.firstFrame = nil
        self.xmlData = nil

        self.destroyed = true

        collectgarbage("collect")
    end

    return self
end

return setmetatable({
    new = new,
    images = images
}, {
    __call = function(_, ...)
        return new(...)
    end
})
