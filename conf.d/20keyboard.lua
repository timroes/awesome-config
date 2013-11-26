local awful = require('awful')
local naughty = require('naughty')
local gears = require('gears')

-- Requires setxkbmap to be installed

local setkeymap = "setxkbmap"
local keyboard_layouts = {
	"us -variant altgr-intl",
	"de"
}
local current_layout = 1

local last_id = 0

local set_current_layout = function()
	awful.util.spawn(setkeymap .. " " .. keyboard_layouts[current_layout])
end

-- Initialize with porimary keyboard layout
set_current_layout()

add_key({ MOD }, "Tab", function() 
	current_layout = ((current_layout) % #keyboard_layouts) + 1
	set_current_layout()
	local notif = naughty.notify({
		title = "Changed keyboard layout",
		text = keyboard_layouts[current_layout]:upper(),
		replaces_id = last_id
	})
	last_id = notif.id
end)
