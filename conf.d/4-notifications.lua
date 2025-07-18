local awful = require('awful')
local gears = require('gears')
local lunaconf = require('lunaconf')
local naughty = require('naughty')
local notifications = require('build.src.lib.notifications')

local theme = lunaconf.theme.get()

-- Need to refresh the xdg list on start, so that notifications can lookup desktop entry files
lunaconf.xdg.refresh()

naughty.config.defaults.position = 'top_right'

local function mutateChromeNotification(args)
	args.text = args.text:gsub('^([^\n]*)(.*)', '<span size="small" color="#888888">%1</span>%2')
end

-- Register a callback to preprocess all notifications
naughty.config.notify_callback = function(args)
	-- Cancel notifications if dnd widget is enabled
	if notifications.isDndActive() and not args.ignore_dnd then
		return null
	end

	if args.freedesktop_hints and args.freedesktop_hints['image-path'] then
		-- Freedesktop image hint has higher priority than args.icon
		args.icon = lunaconf.icons.lookup_icon(args.freedesktop_hints['image-path'])
	elseif args.icon then
		-- Lookup the icon in case it was an icon name and not a path
		args.icon = lunaconf.icons.lookup_icon(args.icon)
	else
		-- Lookup the icon using our own icon lookup implementation
		if args.freedesktop_hints and args.freedesktop_hints['desktop-entry'] then
			local desktop_id = args.freedesktop_hints['desktop-entry']
			local desktop_entry = lunaconf.xdg.get_entry(desktop_id)
			if not desktop_entry then
				desktop_entry = lunaconf.xdg.get_entry(desktop_id:lower())
			end
			if desktop_entry then
				args.icon = lunaconf.icons.lookup_icon(desktop_entry.Icon)
			end
		end
	end

	-- Limit text of notification to max 200 chars
	if not args.unlimited_content and string.len(args.text) > 200 then
		args.text = args.text:sub(0, 200) .. '…'
	end

	if args.appname == 'Chromium' then
		-- Give chromium notifications a bit of special formatting
		mutateChromeNotification(args)
	end

	return args
end

-- Always show notifications on primary screen
local function update_notification_screen()
	local screen = screen.primary
	naughty.config.defaults.screen = screen
	naughty.config.defaults.icon_size = lunaconf.dpi.x(theme.notification_icon_size, screen)
	naughty.config.spacing = lunaconf.dpi.y(theme.notification_spacing or 1, screen)
	naughty.config.padding = lunaconf.dpi.y(theme.notification_padding or 4, screen)
	naughty.config.defaults.margin = lunaconf.dpi.x(theme.notification_margin or 4, screen)
	naughty.config.defaults.width = lunaconf.dpi.x(theme.notification_width, screen)
end

-- Change notification screen if primary or available screens change
screen.connect_signal('primary_changed', update_notification_screen)
screen.connect_signal('list', update_notification_screen)
-- Set notification screen initially
update_notification_screen()

-- Allow dismissing all notifications via Modifier + d
lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, "d", function() naughty.destroy_all_notifications() end),
	awful.key({ lunaconf.config.MOD, 'Control' }, 'd', function ()
		notifications.toggleDnd();
	end),
	awful.key({ lunaconf.config.MOD , 'Shift' }, 'd', function ()
		notifications.toggleDnd();
	end)
)
