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

local function screen_factor(screen, fac)
	local output_name = screens.output_name(screen)
	local factor
	if output_name then
		factor = config.get('dpi.' .. output_name .. '.' .. fac, 1.0)
	else
		factor = config.get('dpi.' .. fac, 1.0)
	end
	return tonumber(factor)
end

function dpi.xfactor(screen)
	return screen_factor(screen, 'xfactor')
end

function dpi.yfactor(screen)
	return screen_factor(screen, 'yfactor')
end

local function refresh_dpi()
	scale_x_cache = {}
	scale_y_cache = {}
	for s in screen do
		-- Calculate x dpi for each screen
		local xdpi = screens.xdpi(s)
		if xdpi == nil then
			xdpi = default_dpi
		end
		xdpi = xdpi * dpi.xfactor(s)
		scale_x_cache[s] = xdpi / default_dpi
		-- Calculate y dpi for each screen
		local ydpi = screens.ydpi(s)
		if ydpi == nil then
			ydpi = default_dpi
		end
		ydpi = ydpi * dpi.yfactor(s)
		scale_y_cache[s] = ydpi / default_dpi
		-- Pass the lower dpi to awesome as dpi for that screen
		beautiful.xresources.set_dpi(math.min(xdpi, ydpi), s)
	end
end

function dpi.x(value, screen)
	return math.ceil(value * scale_x_cache[screen])
end

function dpi.y(value, screen)
	return math.ceil(value * scale_y_cache[screen])
end

-- Set up listeners to recalculate dpi and pass it to awesome
for _, signal in ipairs({'list', 'property::geometry', 'property::outputs'}) do
	screen.connect_signal(signal, refresh_dpi)
end

refresh_dpi()

return dpi
