local awful = require('awful')
local lunaconf = require('lunaconf')

local backlight_device = lunaconf.config.get('brightness_device', nil)

if backlight_device then
	local dialog = lunaconf.dialogs.bar('preferences-system-brightness-lock', 1)
	
	local function brightness_control(value)
		awful.spawn.easy_async(string.format('%s/brightness.sh %s %s', lunaconf.utils.scriptpath(), backlight_device, value), function(out)
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
end
