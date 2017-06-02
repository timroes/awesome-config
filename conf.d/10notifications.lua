local gears = require('gears')
local lunaconf = require('lunaconf')
local naughty = require('naughty')

local theme = lunaconf.theme.get()

naughty.config.spacing = 10
naughty.config.padding = 10

naughty.config.defaults.icon_size = 48
naughty.config.defaults.position = 'top_right'
naughty.config.defaults.border_width = theme.notify_border_width
naughty.config.defaults.opacity = theme.notify_opacity or 1.0
naughty.config.defaults.margin = 7

-- Notifications should have rounded corners
naughty.config.defaults.shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 6) end

-- Always show notifications on primary screen
local function update_notification_screen()
	naughty.config.defaults.screen = lunaconf.screens.primary()
end

-- Change notification screen if primary or available screens change
screen.connect_signal('primary_changed', update_notification_screen)
screen.connect_signal('list', update_notification_screen)
-- Set notification screen initially
update_notification_screen()

naughty.config.presets.normal.bg = theme.notify_normal_bg or "#000000"
naughty.config.presets.normal.fg = theme.notify_normal_fg or "#FFFFFF"
