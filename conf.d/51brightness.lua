local awful = require('awful')
local lunaconf = require('lunaconf')

local function brightness_control(which)
	awful.spawn.easy_async(lunaconf.utils.scriptpath() .. 'brightness.sh ' .. which, function(out)
		local value = tonumber(out)
		-- Number of blocks to draw for volume (0 volume = 0, 1-9 = 1, ..., 90-99 = 10, 100 = 11)
		local value_rounded = value == 0 and 0 or math.floor(value / 10) + 1
		-- Depending on mute state use different shaded block drawing chars to paint a bar
		local value_blocks = string.rep('█', value_rounded) .. string.rep('░', 11 - value_rounded)
		lunaconf.notify.show_or_update('brightness.control', {
			title = 'Brightness',
			text = value_blocks,
			icon = 'display-brightness-symbolic',
			timeout = 2
		})
	end)
end

-- Brightness Control
lunaconf.keys.globals(
	awful.key({}, 'XF86MonBrightnessUp', function() brightness_control('up') end),
	awful.key({ 'Shift' }, 'XF86MonBrightnessUp', function() brightness_control('up small') end),
	awful.key({}, 'XF86MonBrightnessDown', function() brightness_control('down') end),
	awful.key({ 'Shift' }, 'XF86MonBrightnessDown', function() brightness_control('down small') end)
)
