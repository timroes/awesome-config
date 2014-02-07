local awful = require("awful")

keys = awful.util.table.join(
	-- System shortcuts
	awful.key({ MOD, "Control"}, "Delete", function()
		restart = true
		awesome.restart()
	end),

	-- Start programs
	awful.key({ MOD }, "space", function() awful.util.spawn("java -jar /home/timroes/code/start-plz/dist/start-plz.jar") end),
	awful.key({ MOD }, "z", function() awful.util.spawn_with_shell("xdg-open $HOME") end),

	-- Screenshots
	awful.key({  }, "Print", function() awful.util.spawn(scriptpath .. "screenshot win") end),
	awful.key({ MOD }, "Print", function() awful.util.spawn(scriptpath .. "screenshot scr") end),

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

root.keys(keys)
