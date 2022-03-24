local Sprite = {
    x = 0,
    y = 0,
    angle = 0,

    sizeX = 1,
    sizeY = 1,

    paused = false,
    destroyed = false,

    gfx = nil,
    xmlData = {},
    animations = {},
    firstQuad = nil,
    curAnim = {
        name = "",
        quads = {},
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

function Sprite.draw(self)
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

        -- very inspired from funkin-rewritten lol
        local width
        local height

        if quad.offsets["width"] == 0 then
            width = math.floor(quad.width / 2)
        else
            width = math.floor(quad.offsets["width"] / 2) + quad.offsets["x"]
        end
        if quad.offsets["height"] == 0 then
            height = math.floor(quad.height / 2)
        else
            height = math.floor(quad.offsets["height"] / 2) + quad.offsets["y"]
        end

        love.graphics.draw(self.gfx, quad, self.x, self.y, self.angle,
                           self.sizeX, self.sizeY, width + self.offsetX,
                           height + self.offsetY)

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
                local anim = {
                    name = name,
                    quads = {},
                    length = 0,
                    framerate = framerate,
                    loop = loop
                }

                for f = 1, #self.xmlData do
                    local data = self.xmlData[f]

                    if string.starts(data["@name"], prefix) then
                        if table.length(indices) == 0 or
                            table.has_value(indices, f) then
                            local quad =
                                love.graphics.newQuad(data["@x"], data["@y"],
                                                      data["@width"],
                                                      data["@height"],
                                                      self.gfx:getDimensions())

                            quad.width = data["@width"]
                            quad.height = data["@height"]

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

                            quad.offsets = {
                                ["x"] = offsetX,
                                ["y"] = offsetY,
                                ["width"] = offsetWidth,
                                ["height"] = offsetHeight
                            }

                            if self.firstQuad == nil then
                                self.firstQuad = quad
                            end
                            table.insert(anim.quads, quad)

                            anim.length = anim.length + 1
                        end
                    end
                end

                self.animations[name] = anim

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
