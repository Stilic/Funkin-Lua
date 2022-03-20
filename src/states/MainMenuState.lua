local mainmenu = {}
function mainmenu.load()
	menuBG = love.graphics.newImage("assets/images/menuBG.png")
end

function mainmenu.draw()
	love.graphics.draw(menuBG, 0, 0)
end
return mainmenu