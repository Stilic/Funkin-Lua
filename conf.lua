local paths = require("src.paths")

function love.conf(t)
    t.window.title = "Funkin' LUA"
    t.window.icon = paths.image("gameIcon")
    t.window.resizable = false
    t.window.minwidth = 1282
    t.window.minheight = 745
    t.window.width = 1282
    t.window.height = 745
    t.console = true
end
