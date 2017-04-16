local awful = require('awful')
local gears = require('gears')
local lunaconf = require('lunaconf')

awful.screen.connect_for_each_screen(function(s)
	gears.wallpaper.tiled(lunaconf.config.get('theme.wallpaper', nil), s)
end)
