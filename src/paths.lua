local paths = {base = "assets"}

function paths.getPath(path) return paths.base .. "/" .. path end

function paths.sound(path) return paths.getPath("sounds/" .. path .. ".ogg") end

function paths.music(path) return paths.getPath("music/" .. path .. ".ogg") end

-- function paths.getSound(path)
--     return love.audio.newSource(paths.sound(path), "static")
-- end

function paths.getMusic(path)
    return love.audio.newSource(paths.music(path), "stream")
end

function paths.image(path) return paths.getPath("images/" .. path .. ".png") end

function paths.getImage(path) return love.graphics.newImage(paths.image(path)) end

function paths.atlas(path) return paths.getPath("images/" .. path) end

function paths.xml(path) return paths.getPath(path .. ".xml") end

function paths.font(path) return paths.getPath("fonts/" .. path) end

return paths
