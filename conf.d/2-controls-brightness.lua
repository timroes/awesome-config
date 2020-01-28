local awful = require('awful')
local lunaconf = require('lunaconf')


lunaconf.utils.only_if_command_exists('xbacklight', function()
	local dialog = lunaconf.dialogs.bar('preferences-system-brightness-lock', 1)
	
	local function brightness_control(value)
		awful.spawn.easy_async('xbacklight ' .. value, function()
			awful.spawn.easy_async('xbacklight -get', function(out)
				local value = tonumber(out)
				dialog:set_value(value)
				dialog:show()
			end)
		end)
	end
	
	-- Brightness Control
	lunaconf.keys.globals(
		awful.key({}, 'XF86MonBrightnessUp', function() brightness_control('+5%') end),
		awful.key({ 'Shift' }, 'XF86MonBrightnessUp', function() brightness_control('+1%') end),
		awful.key({}, 'XF86MonBrightnessDown', function() brightness_control('-5%') end),
		awful.key({ 'Shift' }, 'XF86MonBrightnessDown', function() brightness_control('-1%') end)
	)
end)
