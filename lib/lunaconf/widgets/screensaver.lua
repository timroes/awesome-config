local io = io
local debug = debug
local table = table
local timer = timer
local scriptpath = require('lunaconf.utils').scriptpath()
local wibox = require('wibox')
local awful = require('awful')
local gears = require('gears')
local string = string
local math = math
local setmetatable = setmetatable
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	theme = require('lunaconf.theme')
}

local screensaver = {}

local theme = lunaconf.theme.get()

local is_off = false

local active_color = theme.screenbar_fg
local inactive_color = theme.screenbar_inactive_fg

local icon_active = gears.color.recolor_image(lunaconf.icons.lookup_icon('display-brightness-high-symbolic'), active_color)
local icon_inactive = gears.color.recolor_image(lunaconf.icons.lookup_icon('display-brightness-symbolic'), inactive_color)

local function create(_, screen)

	local imagebox = wibox.widget.imagebox(icon_inactive)
	-- textbox:set_align("center")
	-- textbox:set_markup(string.format(button_text, disabled_color))

	local widget = wibox.container.margin(imagebox,
		lunaconf.dpi.x(4, screen), lunaconf.dpi.x(4, screen),
		lunaconf.dpi.y(8, screen), lunaconf.dpi.y(8, screen))

	widget:buttons(awful.util.table.join(
		awful.button({ }, 1, function()
			if is_off then
				awful.spawn.spawn(scriptpath .. '/screensaver.sh resume')
				imagebox:set_image(icon_inactive)
				is_off = false
			else
				awful.spawn.spawn(scriptpath .. '/screensaver.sh pause')
				imagebox:set_image(icon_active)
				is_off = true
			end
		end)
	))

	return widget
end

return setmetatable(screensaver, { __call = create })
