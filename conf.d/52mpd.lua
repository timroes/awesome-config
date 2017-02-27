local awful = require("awful")
local naughty = require('naughty')
local config = require("lunaconf.config")

local last_id = 0

shortcuts = awful.util.table.join(root.keys(),
	-- Set shortcuts to control music (mpc [and most likely a running mpd] required)
	awful.key({ }, "XF86AudioPlay", function() awful.spawn.spawn("mpc toggle -q") end),
	awful.key({ }, "XF86AudioNext", function() awful.spawn.spawn("mpc next -q") end),
	awful.key({ }, "XF86AudioPrev", function() awful.spawn.spawn("mpc prev -q") end),

	awful.key({ config.MOD }, "XF86AudioPlay", function()
		local song = awful.util.pread("mpc current"):sub(1,-2)
		if song:len() == 0 then
			song = "- Nothing is playing -"
		end
		naughty.notify({ text = song, title = "Currently playing:", timeout = 3})
	end),

	-- Delete song from playlist
	awful.key({ config.MOD }, "Delete", function() awful.spawn.spawn("mpc del 0") end),

	-- Set shortcuts to control volume (amixer (alsamixer) required)
	awful.key({ }, "XF86AudioRaiseVolume", function() awful.spawn.spawn("amixer -q set Master 2%+") end),
	awful.key({ }, "XF86AudioLowerVolume", function() awful.spawn.spawn("amixer -q set Master 2%-") end),
	awful.key({ }, "XF86AudioMute", function() awful.spawn.spawn("amixer -q set Master toggle") end),
	awful.key({ }, "XF86AudioMicMute", function()
		local state = awful.util.pread("amixer set Capture toggle | tail -c 5")
		local text
		if state:find('on') == nil then
			text = 'Microphone muted'
		else
			text = 'Microphone unmuted'
		end
		local n = naughty.notify({
			text = text,
			replaces_id = last_id
		})
		last_id = n.id
	end)
)

root.keys(shortcuts)
