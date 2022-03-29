local cache = {}

cache.objects = {}

function cache.add(obj, keep)
    if keep == nil then
        keep = false
    end

    table.insert(cache.objects, {
        [0] = obj,
        [1] = keep
    })
end

function cache.remove(obj)
    for k, v in pairs(cache.objects) do
        if v[0] == obj then
            utils.remove(v[0])
            collectgarbage("collect")
            break
        end
    end
end

function cache.clear()
    for k, v in pairs(cache.objects) do
        if not v[1] then
            utils.remove(v[0])
        end
    end

    cache.objects = {}
    collectgarbage("collect")
end

return cache
