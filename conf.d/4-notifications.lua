local gears = require('gears')
local lunaconf = require('lunaconf')
local naughty = require('naughty')

local theme = lunaconf.theme.get()

naughty.config.defaults.icon_size = 48
naughty.config.defaults.position = 'top_right'

-- Notifications should have rounded corners
naughty.config.defaults.shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 6) end

-- Always show notifications on primary screen
local function update_notification_screen()
	local screen = lunaconf.screens.primary()
	naughty.config.defaults.screen = screen
	naughty.config.spacing = lunaconf.dpi.y(theme.notification_spacing or 1, screen)
	naughty.config.padding = lunaconf.dpi.y(theme.notification_padding or 4, screen)
end

-- Change notification screen if primary or available screens change
screen.connect_signal('primary_changed', update_notification_screen)
screen.connect_signal('list', update_notification_screen)
-- Set notification screen initially
update_notification_screen()
