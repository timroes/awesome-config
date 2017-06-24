local awful = require('awful')
local naughty = require('naughty')
local gears = require('gears')
local lunaconf = require('lunaconf')

-- Requires setxkbmap to be installed

local setkeymap = "setxkbmap"
local keyboard_layouts = lunaconf.config.get("keyboard_layouts", { "us" })
local current_layout = 1

local set_current_layout = function()
	lunaconf.utils.spawn(setkeymap .. " " .. keyboard_layouts[current_layout])
end

-- Initialize with primary keyboard layout
set_current_layout()

lunaconf.keys.globals(awful.key({ "Mod1" }, "Shift_L", function()
	current_layout = gears.math.cycle(#keyboard_layouts, current_layout + 1)
	set_current_layout()
	lunaconf.notify.show_or_update('keyboard_layout::switch', {
		title = "Changed keyboard layout",
		text = keyboard_layouts[current_layout]:upper(),
		icon = "input-keyboard",
		timeout = 2
	})
end))

-- Enable X-server kill
lunaconf.utils.spawn(setkeymap .. " -option terminate:ctrl_alt_bksp")
