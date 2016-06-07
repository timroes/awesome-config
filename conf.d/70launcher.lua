local lunaconf = require('lunaconf')

local launcher = lunaconf.launcher()

lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, "space", nil, function() launcher.toggle() end),
	awful.key({ lunaconf.config.MOD }, "KP_Insert", nil, function() launcher.toggle() end)
)
