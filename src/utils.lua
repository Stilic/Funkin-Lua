local utils = {}

function utils.readFile(path)
    local contents, size = love.filesystem.read(path)
    return contents
end

function utils.clearSprite(spr)
    if spr.destroy ~= nil then
        spr:destroy()
    elseif spr.release ~= nil then
        spr:release()
    elseif spr.clear ~= nil then
        spr:clear()
    else
        spr = nil
    end
end

function utils.playSound(sound)
    TEsound.play(sound, "static")
end

return utils
