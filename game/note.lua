local Note = {swagWidth = 160 * 0.7, directions = {'left', 'down', 'up', 'right'}}

function Note.getRawDirection(i)
    return note.directions[i - 1]
end

return Note
