local cache = {}

cache.objects = {}
cache.images = {}

function cache.add(obj) table.insert(cache.objects, obj) end

function cache.getImage(path)
    if cache.images[path] == nil then
        cache.images[path] = love.graphics.newImage(path)
    end
    return cache.images[path]
end

function cache.clear()
    for i = 1, #cache.objects do
        if cache.objects[i].release ~= nil then
            cache.objects[i]:release()
        elseif cache.objects[i].destroy ~= ni then
            cache.objects[i]:destroy()
        end
        cache.objects[i] = nil
    end
    cache.images = {}
    collectgarbage()
end

return cache
