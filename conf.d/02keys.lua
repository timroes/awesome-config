local awful = require("awful")
local config = require("lunaconf.config")

keys = awful.util.table.join(
	-- System shortcuts
	awful.key({ config.MOD, "Control"}, "Delete", function()
		restart = true
		awesome.restart()
	end),

	-- Start programs
	awful.key({ config.MOD }, "space", function() awful.util.spawn("applepy") end),
	awful.key({ config.MOD }, "z", function() awful.util.spawn_with_shell("xdg-open $HOME") end),

	-- Screenshots
	awful.key({ 'Mod1' }, "Print", function() awful.util.spawn(scriptpath .. "screenshot win") end),
	awful.key({ config.MOD }, "Print", function() awful.util.spawn(scriptpath .. "screenshot scr") end),

	-- config.MOD + PageUp/PageDown switches through clients on current tag and screen
	awful.key({ config.MOD }, "Page_Up", function()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),
	awful.key({ config.MOD }, "Page_Down", function()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end)
)

root.keys(keys)
