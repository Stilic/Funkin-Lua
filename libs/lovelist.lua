local lovelist = {}

lovelist.sprites = {}

function lovelist.add(spr)
    table.insert(lovelist.sprites, spr)
end

function lovelist.clear()
    -- clear sprites from memory
    for k, spr in pairs(lovelist.sprites) do
        if spr.destroy ~= nil then
            spr:destroy()
        elseif spr.release ~= nil then
            spr:release()
        end

        sprite[k] = nil
    end
    lovelist.sprites = {}
end

return lovelist
