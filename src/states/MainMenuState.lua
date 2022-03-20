local mainmenu = {}

function mainmenu.load()
	menuBG = paths.getImage("menuBG")
	_c.add(menuBG)
-- i would make this a table but idk how they work lmao
	story_mode = utils.makeSprite("menu_story_mode")
	story_mode:addAnim("idle", "story_mode basic")
	story_mode:addAnim("selected", "story_mode white")
	story_mode:playAnim("idle")
	_c.add(story_mode)

	freeplay = utils.makeSprite("menu_freeplay")
	freeplay:addAnim("idle", "freeplay basic")
	freeplay:addAnim("selected", "freeplay white")
	freeplay:playAnim("idle")
	_c.add(freeplay)

--[[i kept the donate button just because i might add a link to my paypal or something idk
	but i think i really shouldn't try to profit from a fnf engine even if its optional
	let's just keep it like this unless we talk bout this, ight?
]]
	donate = utils.makeSprite("menu_donate")
	donate:addAnim("idle", "donate basic")
	donate:addAnim("selected", "donate white")
	donate:playAnim("idle")
	_c.add(donate)
-- credit to psych engine for making the options sprites btw.
	options = utils.makeSprite("menu_options")
	options:addAnim("idle", "options basic")
	options:addAnim("selected", "options white")
	options:playAnim("idle")
	_c.add(options)
end

function mainmenu.update(dt)
	story_mode:update(dt)
	freeplay:update(dt)
	donate:update(dt)
	options:update(dt)
end

function mainmenu.draw()
	love.graphics.draw(menuBG, 0, 0)
	story_mode:draw(340, 10)
	freeplay:draw(400, 140)
	donate:draw(400, 280)
	options:draw(400, 420) -- why did it have to be the unfunny number :whyyyy;
end
return mainmenu