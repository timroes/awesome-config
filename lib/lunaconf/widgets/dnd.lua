local wibox = require('wibox')
local awful = require('awful')
local setmetatable = setmetatable
local gears = require('gears')
local naughty = require('naughty')
local lunaconf = {
	bar = require('lunaconf.widgets.bar'),
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	keys = require('lunaconf.keys'),
	theme = require('lunaconf.theme')
}

local dnd = {}

local imagebox
local widget

local theme = lunaconf.theme.get()

local icon_active = gears.color.recolor_image(lunaconf.icons.lookup_icon('notification-symbolic'), lunaconf.bar.widget_color())
local icon_dnd = gears.color.recolor_image(lunaconf.icons.lookup_icon('notification-disabled-symbolic'), lunaconf.bar.widget_color())

local function toggle()
	naughty.toggle()
	imagebox:set_image(naughty.is_suspended() and icon_dnd or icon_active)
end

local function create(_, screen, mod, key)

	imagebox = wibox.widget.imagebox()
	imagebox:set_image(icon_active)

	widget = wibox.container.margin(imagebox,
		lunaconf.dpi.x(5, screen), lunaconf.dpi.x(5, screen),
		lunaconf.dpi.y(5, screen), lunaconf.dpi.y(5, screen))

	widget:buttons(awful.button({ }, 1, toggle))

	if mod and key then
		lunaconf.keys.globals(awful.key(mod, key, toggle))
	end

	return widget
end

return setmetatable(dnd, { __call = create })
