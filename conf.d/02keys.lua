local awful = require("awful")
local lunaconf = require('lunaconf')
local MOD = lunaconf.config.MOD

lunaconf.keys.globals(
	-- System shortcuts
	awful.key({ MOD, "Control"}, "Delete", function()
		restart = true
		awesome.restart()
	end),

	-- Start programs
	awful.key({ MOD }, "z", function() awful.util.spawn_with_shell("xdg-open $HOME") end),

	-- Screenshots
	awful.key({ 'Mod1' }, "Print", function() awful.util.spawn(scriptpath .. "screenshot win") end),
	awful.key({ MOD }, "Print", function() awful.util.spawn(scriptpath .. "screenshot scr") end),

	-- Brightness Control
	awful.key({}, 'XF86MonBrightnessUp', function() awful.util.spawn(scriptpath .. "brightness.sh up") end),
	awful.key({ 'Shift' }, 'XF86MonBrightnessUp', function() awful.util.spawn(scriptpath .. "brightness.sh up small") end),
	awful.key({}, 'XF86MonBrightnessDown', function() awful.util.spawn(scriptpath .. "brightness.sh down") end),
	awful.key({ 'Shift' }, 'XF86MonBrightnessDown', function() awful.util.spawn(scriptpath .. "brightness.sh down small") end),

	-- MOD + PageUp/PageDown switches through clients on current tag and screen
	awful.key({ MOD }, "Page_Up", function()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),
	awful.key({ MOD }, "Page_Down", function()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end)
)

-- Bin dlauncher to MOD + space if a launcher has been defined in the configuration
-- local launcher = lunaconf.config.get('applications.launcher', nil)
-- if launcher then
-- 	lunaconf.keys.globals(
-- 		awful.key({ MOD }, "space", function() awful.util.spawn(launcher) end)
-- 	)
-- end
