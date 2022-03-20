local mainmenu = {}
function mainmenu.load
	menuBG = utils.makeSprite("menuBG")
end

function mainmenu.draw
	menuBG:draw(0, 0)
end