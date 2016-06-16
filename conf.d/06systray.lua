local lunaconf = require('lunaconf')

local systray = lunaconf.widgets.systray()
lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, "/", function() systray:toggle() end)
)
