local theme = require('lunaconf.theme')
local config = require('lunaconf.config')
local screens = require('lunaconf.screens')
local log = require('lunaconf.log')
local wibox = require('wibox')
local awful = require('awful')
local beautiful = require('beautiful')

-- Utilities to work with hidpi screens
local dpi = {}

local default_dpi = 96

local scale_x_cache = {}
local scale_y_cache = {}

local function force_dpi(screen)
	local output_name = screens.output_name(screen)
	local dpi
	if output_name then
		dpi = config.get(string.format('dpi.%s', output_name), nil)
	end
	if not dpi then
		dpi = config.get('dpi.default', nil)
	end
	return tonumber(dpi)
end

local function refresh_dpi_for_screen(s)
	-- Calculate x dpi for each screen
	local xdpi = force_dpi(s)
	if not xdpi then
		xdpi = screens.xdpi(s)
		if xdpi == nil then
			xdpi = default_dpi
		end
	end
	scale_x_cache[s] = xdpi / default_dpi
	-- Calculate y dpi for each screen
	local ydpi = force_dpi(s)
	if not ydpi then
		ydpi = screens.ydpi(s)
		if ydpi == nil then
			ydpi = default_dpi
		end
	end
	scale_y_cache[s] = ydpi / default_dpi
	-- Pass the lower dpi to awesome as dpi for that screen
	beautiful.xresources.set_dpi(math.min(xdpi, ydpi), s)
end

local function refresh_dpi()
	scale_x_cache = {}
	scale_y_cache = {}
	for s in screen do
		refresh_dpi_for_screen(s)
	end
end

function dpi.x(value, screen)
	if not scale_x_cache[screen] then
		refresh_dpi_for_screen(screen)
	end
	return math.ceil(value * scale_x_cache[screen])
end

function dpi.y(value, screen)
	if not scale_y_cache[screen] then
		refresh_dpi_for_screen(screen)
	end
	return math.ceil(value * scale_y_cache[screen])
end

-- Set up listeners to recalculate dpi and pass it to awesome
for _, signal in ipairs({'list', 'property::geometry', 'property::outputs'}) do
	screen.connect_signal(signal, refresh_dpi)
end

refresh_dpi()

return dpi
