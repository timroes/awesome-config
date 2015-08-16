local gears = require("gears")
local theme = require("lunaconf.theme")

gears.wallpaper.tiled(theme.path() .. theme.get().wallpaper)