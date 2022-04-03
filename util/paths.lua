local paths = {base = "assets", soundExt = ".ogg"}

function paths.getPath(path) return paths.base .. "/" .. path end

function paths.sound(path) return paths.getPath("sounds/" .. path .. paths.soundExt) end

function paths.music(path) return paths.getPath("music/" .. path .. paths.soundExt) end

function paths.formatToSongPath(path) return string.lower(path):gsub("% ", "-") end

function paths.inst(song)
    return paths.getPath("songs/" .. paths.formatToSongPath(song) .. "/Inst" .. paths.soundExt)
end

function paths.image(path) return paths.getPath("images/" .. path .. ".png") end

function paths.getImage(path) return _c.getImage(paths.image(path)) end

function paths.atlas(path) return paths.getPath("images/" .. path) end

function paths.xml(path) return paths.getPath(path .. ".xml") end

function paths.font(path) return paths.getPath("fonts/" .. path) end

return paths
