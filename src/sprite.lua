local sprite = {}

local utils = require "src.utils"

-- default data
local Sprite = {
    gfx = nil,
    xmlData = nil,
    animations = {},
    firstQuad = nil,

    curAnim = {
        name = '',
        quads = {},
        length = 0,
        height = 0,
        width = 0,
        framerate = 24,
        loop = false,
        finished = false
    },

    curFrame = 1,
    lastFrame = 1,

    paused = false,
    destroyed = false
}
Sprite.__index = Sprite

function Sprite:update(dt)
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

function Sprite:draw(x, y, r, sx, sy)
    if not self.destroyed then
        local spriteNum = math.floor(self.curFrame)
        if not self.paused then
            spriteNum = spriteNum + 1
            self.lastFrame = spriteNum
        else
            spriteNum = self.lastFrame
        end

        local quad = self.curAnim.quads[spriteNum]
        if quad == nil then
            quad = self.firstQuad
        end

        love.graphics.draw(self.gfx, quad, x, y, r, sx, sy)

        if not self.paused and not self.curAnim.loop and spriteNum >= self.curAnim.length then
            self.curAnim.finished = true
        end
    end
end

function Sprite:addAnim(name, prefix, indices, framerate, loop)
    if not self.destroyed then
        if indices == nil then
            indices = {};
        end
        if framerate == nil then
            framerate = 24
        end
        if loop == nil then
            loop = true
        end

        for i = 1, #self.xmlData do
            local data = self.xmlData[i]

            if string.match(data["@name"], prefix) then
                local quads = {}
                local length = 0

                for f = 1, #self.xmlData do
                    local data = self.xmlData[f]

                    if string.starts(data["@name"], prefix) then
                        if table.length(indices) == 0 or table.has_value(indices, f) then
                            local x = data["@x"]
                            local y = data["@y"]

                            local width = data["@width"]
                            local height = data["@height"]

                            if data["@frameX"] ~= nil then
                                x = x + data["@frameX"]
                            end
                            if data["@frameY"] ~= nil then
                                y = y + data["@frameY"]
                            end

                            if data["@frameWidth"] ~= nil then
                                width = data["@frameWidth"]
                            end
                            if data["@frameHeight"] ~= nil then
                                height = data["@frameHeight"]
                                y = y + 2
                            end

                            local quad = love.graphics.newQuad(x, y, width, height, self.gfx:getDimensions())

                            if self.firstQuad == nil then
                                self.firstQuad = quad
                            end

                            table.insert(quads, quad)
                            length = length + 1
                        end
                    end
                end

                self.animations[name] = {
                    name = name,
                    quads = quads,
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

function Sprite:removeAnim(name)
    if self.animations[name] ~= nil then
        if self.curAnim.name == name then
            self:stop()
        end

        self.animations[name] = nil
        return true
    end

    return false
end

function Sprite:playAnim(anim, forced)
    if not self.destroyed and not self.paused then
        if forced == nil then
            forced = false
        end

        self:stop()

        if self.animations[anim] ~= null then
            -- very dumb i am so i do this
            local canPlay = true
            if not forced and self.curAnim.name == anim then
                canPlay = false
            end

            if canPlay then
                self.curAnim = self.animations[anim]
                self.curAnim.finished = false
                self.curFrame = 1
                self.lastFrame = 1
            end
        end
    end
end

function Sprite:getCurrentAnim()
    return self.curAnim
end

function Sprite:pause()
    self.paused = true
end

function Sprite:play()
    self.paused = false
end

function Sprite:stop()
    self.curAnim = nil
end

function Sprite:destroy()
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
        self.xmlData = nil

        self.destroyed = true

        collectgarbage("collect")

        return true
    end

    return false
end

-- HELPER FUNCTION
function sprite.newSprite(gfx, xml)
    local self = {}
    setmetatable(self, Sprite)

    self.gfx = gfx
    self.xmlData = utils.parseAtlas(xml)

    return self
end

return sprite
