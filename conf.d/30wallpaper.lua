local gears = require("gears")
local theme = require("lunaconf.theme")
local config = require("lunaconf.config")

gears.wallpaper.fit(config.get('wallpaper', theme.path() .. theme.get().wallpaper))
