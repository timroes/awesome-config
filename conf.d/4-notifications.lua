local gears = require('gears')
local lunaconf = require('lunaconf')
local naughty = require('naughty')

local theme = lunaconf.theme.get()

naughty.config.defaults.icon_size = 48
naughty.config.defaults.position = 'top_right'

-- Notifications should have rounded corners
naughty.config.defaults.shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 6) end
-- Register a callback to preprocess all notifications
naughty.config.notify_callback = function(args)
	-- Cancel notifications if dnd widget is enabled
	if lunaconf.widgets.dnd.is_enabled() then
		return null
	end

	if args.icon then
		-- Lookup the icon in case it was an icon name and not a path
		args.icon = lunaconf.icons.lookup_icon(args.icon)
	else
		-- Lookup the icon using our own icon lookup implementation
		if args.freedesktop_hints and args.freedesktop_hints['desktop-entry'] then
			local desktop_id = args.freedesktop_hints['desktop-entry']
			local desktop_entry = lunaconf.xdg.get_entry(desktop_id)
			if desktop_entry then
				args.icon = lunaconf.icons.lookup_icon(desktop_entry.Icon)
			end
		end
	end

	return args
end

-- Always show notifications on primary screen
local function update_notification_screen()
	local screen = lunaconf.screens.primary()
	naughty.config.defaults.screen = screen
	naughty.config.spacing = lunaconf.dpi.y(theme.notification_spacing or 1, screen)
	naughty.config.padding = lunaconf.dpi.y(theme.notification_padding or 4, screen)
	naughty.config.defaults.margin = lunaconf.dpi.x(theme.notification_margin or 4, screen)
end

-- Change notification screen if primary or available screens change
screen.connect_signal('primary_changed', update_notification_screen)
screen.connect_signal('list', update_notification_screen)
-- Set notification screen initially
update_notification_screen()
