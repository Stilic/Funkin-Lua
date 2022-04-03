local song = {}

function song.loadFromJson(song, folder)
    song = paths.formatToSongPath(song)
    if folder == nil then
        folder = song
    else
        folder = paths.formatToSongPath(folder)
    end
    return utils.readJson(paths.json(folder .. "/" .. song)).song
end

return song
