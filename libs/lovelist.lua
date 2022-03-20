local lovelist = {}

lovelist.objects = {}

function lovelist.add(obj, keep)
    if keep == nil then
        keep = false
    end

    table.insert(lovelist.objects, {[0] = obj, [1] = keep})
end

function lovelist.remove(obj)
    for k, v in pairs(lovelist.objects) do
        if v[0] == obj then
            if v[0].destroy ~= nil then
                v[0]:destroy()
            elseif o.release ~= nil then
                v[0]:release()
            end

            lovelist.objects[k] = nil
            collectgarbage("collect")

            break
        end
    end
end

function lovelist.clear()
    for k, v in pairs(lovelist.objects) do
        if not v[1] then
            if v[0].destroy ~= nil then
                v[0]:destroy()
            elseif o.release ~= nil then
                v[0]:release()
            end
        end
    end

    lovelist.objects = {}
    collectgarbage("collect")
end

return lovelist
