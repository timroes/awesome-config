local awful = require('awful')
local naughty = require('naughty')
local gears = require('gears')
local lunaconf = require('lunaconf')

-- Requires setxkbmap to be installed
local setkeymap = "setxkbmap"
local keyboard_layouts = lunaconf.config.get("keyboard_layouts", { "us" })

local set_layout = function(layout)
	lunaconf.utils.spawn(setkeymap .. " " .. layout)
end

set_layout(keyboard_layouts[1])

if #keyboard_layouts > 1 then
	local keyboard_icon = lunaconf.icons.lookup_icon('input-keyboard')

	local layout_items = {}
	for i,l in ipairs(keyboard_layouts) do
		layout_items[i] = {
			icon = keyboard_icon,
			text = l:sub(0, 2):upper(),
			value = l
		}
	end

	local dialog = lunaconf.dialogs.chooser()
	dialog:set_items(layout_items)

	lunaconf.keys.globals(awful.key({ "Mod1" }, "Shift_L", function()
		dialog:show("Shift_L", function(item)
			set_layout(item.value)
		end, true)
	end))
end

-- Enable X-server kill
lunaconf.utils.spawn(setkeymap .. " -option terminate:ctrl_alt_bksp")
