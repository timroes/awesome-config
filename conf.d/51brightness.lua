local awful = require('awful')
local lunaconf = require('lunaconf')

local dialog = lunaconf.dialogs.bar('preferences-system-brightness-lock', 1)

local function brightness_control(which)
	awful.spawn.easy_async(lunaconf.utils.scriptpath() .. 'brightness.sh ' .. which, function(out)
		local value = tonumber(out)
		dialog:set_value(value)
		dialog:show()
	end)
end

-- Brightness Control
lunaconf.keys.globals(
	awful.key({}, 'XF86MonBrightnessUp', function() brightness_control('up') end),
	awful.key({ 'Shift' }, 'XF86MonBrightnessUp', function() brightness_control('up small') end),
	awful.key({}, 'XF86MonBrightnessDown', function() brightness_control('down') end),
	awful.key({ 'Shift' }, 'XF86MonBrightnessDown', function() brightness_control('down small') end)
)
