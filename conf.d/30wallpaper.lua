local gears = require("gears")
local theme = require("lunaconf.theme")
local config = require("lunaconf.config")


for s = 1, screen.count() do
	gears.wallpaper.tiled(config.get('theme.wallpaper', nil), s, theme.get().wallpaper)
end
