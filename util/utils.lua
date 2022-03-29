local utils = {}

function utils.readFile(path)
    local contents, size = love.filesystem.read(path)
    return contents
end

function utils.remove(obj)
    if obj.destroy ~= nil then
        obj:destroy()
    elseif obj.release ~= nil then
        obj:release()
    elseif obj.clear ~= nil then
        obj:clear()
    end

    obj = nil
end

function utils.gradientMesh(dir, ...)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = select("#", ...)
    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4] or 1}
            meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4] or 1}
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4] or 1}
            meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4] or 1}
        end
    end

    -- Resulting Mesh has 1x1 image size
    return love.graphics.newMesh(meshData, "strip", "static")
end

function utils.callGroup(grp, func, ...)
    for i = 1, #grp do
        if grp[i][func] ~= nil then
            grp[i][func](grp[i], ...)
        end
    end
end

function utils.playSound(sound)
    TEsound.play(sound, "static")
end

return utils
