local awful = require("awful")

shortcuts = awful.util.table.join(root.keys(),
	-- Set shortcuts to control music (mpc [and most likely a running mpd] required)
	awful.key({ }, "XF86AudioPlay", function() awful.util.spawn("mpc toggle -q") end),
	awful.key({ }, "XF86AudioNext", function() awful.util.spawn("mpc next -q") end),
	awful.key({ }, "XF86AudioPrev", function() awful.util.spawn("mpc prev -q") end),

	-- Delete song from playlist
	awful.key({ MOD }, "Delete", function() awful.util.spawn("mpc del 0") end),

	-- Set shortcuts to control volume (amixer (alsamixer) required)
	awful.key({ }, "XF86AudioRaiseVolume", function() awful.util.spawn("amixer -q set Master 2%+") end),
	awful.key({ }, "XF86AudioLowerVolume", function() awful.util.spawn("amixer -q set Master 2%-") end),
	awful.key({ }, "XF86AudioMute", function() awful.util.spawn("amixer -q set Master toggle") end)
)

root.keys(shortcuts)
