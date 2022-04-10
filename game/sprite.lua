local xmlParser = require "lib.xml"

local function tableHasValue(table, val)
    for index, value in ipairs(table) do if value == val then return true end end
    return false
end

local Sprite = {}
Sprite.__index = Sprite

function Sprite:new(path, x, y)
    self = setmetatable({}, {__index = Sprite})

    self.x = x or 0
    self.y = y or 0

    self.width = 0
    self.height = 0

    self.angle = 0

    self.sizeX = 1
    self.sizeY = 1

    self.offsetX = 0
    self.offsetY = 0
    self.centerOffsets = false

    self.paused = false
    self.destroyed = false

    self.path = path or ""
    self.xmlData = {}

    self.animations = {}
    self.curAnim = {
        name = "",
        frames = {},
        indices = {},
        offsets = {},
        length = 0,
        framerate = 24,
        loop = false,
        finished = false
    }

    self.firstFrame = nil
    self.curFrame = 1

    self:load(path)

    return self
end

function Sprite:load(path)
    if path == nil then path = "" end

    self.path = path

    if path ~= "" then
        local lePath = path .. ".xml"
        assert(love.filesystem.getInfo(lePath) ~= nil,
               "'" .. lePath .. "' was not found!")

        local contents, size = love.filesystem.read(lePath)
        local data = xmlParser.parse(contents)
        self.xmlData = {}
        for _, e in pairs(data) do
            if e.tag == "SubTexture" then
                table.insert(self.xmlData, e)
            end
        end
    end

    return self
end

function Sprite:update(dt)
    if self.curAnim ~= nil and not self.destroyed then
        local frame = self.curFrame + dt * self.curAnim.framerate
        if not self.paused or
            (self.curAnim.indices ~= nil and
                tableHasValue(self.curAnim.frames, frame)) then
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

function Sprite:draw(addX, addY)
    if addX == nil then addX = 0 end
    if addY == nil then addY = 0 end

    if self.curAnim ~= nil and not self.destroyed then
        local spriteNum = math.floor(self.curFrame)
        if not self.paused then spriteNum = spriteNum + 1 end

        local frame = self.curAnim.frames[spriteNum]
        if frame == nil then frame = self.firstFrame end

        local offsetX = frame.offsets.x
        local offsetY = frame.offsets.y

        -- why this taken two days to be done
        if self.centerOffsets then
            local funni = self.curAnim.frames[1]
            offsetX = offsetX - funni.offsets.x + funni.width / 2
            offsetY = offsetY - funni.offsets.y + funni.height / 2
        end

        love.graphics.draw(_c.getImage(self.path .. ".png"), frame.quad,
                           self.x - self.offsetX + addX,
                           self.y - self.offsetY + addY, self.angle, self.sizeX,
                           self.sizeY, offsetX, offsetY)

        if not self.paused and not self.curAnim.loop and spriteNum >=
            self.curAnim.length then self.curAnim.finished = true end
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
        if framerate == nil then framerate = 24 end
        if loop == nil then loop = true end

        local anim = {
            name = name,
            frames = {},
            indices = indices,
            length = 0,
            framerate = framerate,
            loop = loop
        }

        for f = 1, #self.xmlData do
            local data = self.xmlData[f].attr

            if string.sub(data["name"], 1, string.len(prefix)) == prefix then
                if (indices == nil or indices == {}) or
                    tableHasValue(indices, f) then
                    local frame = {
                        quad = love.graphics.newQuad(data["x"], data["y"],
                                                     data["width"],
                                                     data["height"],
                                                     _c.getImage(
                                                         self.path .. ".png"):getDimensions()),
                        width = tonumber(data["width"]),
                        height = tonumber(data["height"])
                    }

                    local offsetX = data["frameX"]
                    if offsetX == nil then offsetX = 0 end
                    local offsetY = data["frameY"]
                    if offsetY == nil then offsetY = 0 end

                    local offsetWidth = tonumber(data["frameWidth"])
                    if offsetWidth == nil then
                        offsetWidth = 0
                    end
                    local offsetHeight = tonumber(data["frameHeight"])
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

    self:updateHitbox()

    return self
end

function Sprite:updateHitbox()
    self.width = 0
    self.height = 0

    -- try to get da average size
    for i, v in pairs(self.animations) do
        for i, f in pairs(v.frames) do
            if f.width > self.width then self.width = f.width end
            if f.height > self.height then self.height = f.height end
        end
    end
end

function Sprite:removeAnim(name)
    if self.animations[name] ~= nil then
        if self.curAnim.name == name then self:stop() end
        self.animations[name] = nil
    end
    return self
end

function Sprite:playAnim(anim, forced)
    if forced == nil then forced = false end

    if self.animations[anim] ~= nil and self.animations[anim].frames[1] ~= nil and
        not self.destroyed and not self.paused then
        if not forced and anim == self.curAnim.name then return end

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

        self.animations = {}
        self.firstFrame = nil
        self.xmlData = nil

        self.destroyed = true

        collectgarbage()
    end

    return self
end

return Sprite
