local mainmenu = {}

function mainmenu.load()
	menuBG = paths.getImage("menuBG")
	_s.add(menuBG)
end

function mainmenu.draw()
	love.graphics.draw(menuBG, 0, 0)
end
return mainmenu