local wibox = require('wibox')
local awful = require('awful')
local setmetatable = setmetatable
local gears = require('gears')
local naughty = require('naughty')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	keys = require('lunaconf.keys'),
	theme = require('lunaconf.theme')
}

local dnd = {}

local imagebox
local widget

local theme = lunaconf.theme.get()

local mute_notifications = false

local icon_active = gears.color.recolor_image(lunaconf.icons.lookup_icon('notification-symbolic'), theme.screenbar_inactive_fg)
local icon_dnd = gears.color.recolor_image(lunaconf.icons.lookup_icon('notification-disabled-symbolic'), theme.screenbar_fg)

function dnd.is_enabled()
	return mute_notifications
end

local function toggle()
	mute_notifications = not mute_notifications
	if mute_notifications then
		naughty.destroy_all_notifications()
	end
	imagebox:set_image(mute_notifications and icon_dnd or icon_active)
end

local function create(_, screen, mod, key)

	imagebox = wibox.widget.imagebox()
	imagebox:set_image(icon_active)

	widget = wibox.container.margin(imagebox,
		lunaconf.dpi.x(4, screen), lunaconf.dpi.x(4, screen),
		lunaconf.dpi.y(8, screen), lunaconf.dpi.y(8, screen))

	widget:buttons(awful.button({ }, 1, toggle))

	if mod and key then
		lunaconf.keys.globals(awful.key(mod, key, toggle))
	end

	return widget
end

return setmetatable(dnd, { __call = create })
