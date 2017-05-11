local awful = require('awful')
local gears = require('gears')
local lunaconf = require('lunaconf')

local function set_wallpaper(s)
	gears.wallpaper.tiled(lunaconf.config.get('theme.wallpaper', nil), s)
end

-- Set wallpaper for each new screen and if the geometry of a screen changes
awful.screen.connect_for_each_screen(set_wallpaper)
screen.connect_signal('property::geometry', set_wallpaper)
