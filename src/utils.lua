local utils = {}

function utils.readFile(path)
    local contents, size = love.filesystem.read(path)
    return contents
end

function utils.callGroup(grp, func, ...)
    for k, o in pairs(grp) do if o[func] ~= nil then o[func](o, ...) end end
end

function utils.playSound(sound) TEsound.play(sound, "static") end

return utils
