local awful = require("awful")
local lunaconf = require('lunaconf')
local MOD = lunaconf.config.MOD

lunaconf.keys.globals(
	-- System shortcuts
	awful.key({ MOD, "Control"}, "Delete", function()
		awesome.restart()
	end),

	-- Start programs
	awful.key({ MOD }, "e", function() lunaconf.utils.spawn("xdg-open $HOME") end),

	-- Screenshots
	awful.key({ 'Mod1' }, "Print", function() awful.spawn.spawn(lunaconf.utils.scriptpath() .. "screenshot win") end),
	awful.key({ MOD }, "Print", function() awful.spawn.spawn(lunaconf.utils.scriptpath() .. "screenshot scr") end)
)
