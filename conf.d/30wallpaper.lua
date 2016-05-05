local gears = require("gears")
local theme = require("lunaconf.theme")
local config = require("lunaconf.config")


for s = 1, screen.count() do
	gears.wallpaper.fit(config.get('wallpaper', theme.path() .. theme.get().wallpaper), s)
end
