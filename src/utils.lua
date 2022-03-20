local utils = {}

function utils.readFile(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then
        return nil
    end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

function utils.parseAtlas(xml)
    local anims = {}
    local texList = xml.TextureAtlas.SubTexture
    for i = 1, #texList do
        table.insert(anims, texList[i])
    end
    return anims
end

function utils.makeSprite(path)
    return sprite.newSprite(paths.getImage(path), paths.readXml("images/" .. path))
end

return utils
