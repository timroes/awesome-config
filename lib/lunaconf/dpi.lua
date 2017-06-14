local theme = require('lunaconf.theme')
local config = require('lunaconf.config')
local screens = require('lunaconf.screens')
local log = require('lunaconf.log')
local wibox = require('wibox')

local typeof = typeof

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

-- Pass in an wibox.widget.textbox to this method and it will scale its font
-- so it will take the dpi from the theme into respect. This method will assume
-- the font size set on the textbox was meant to be for 96 dpi.
function dpi.textbox(textbox, screen)
	if textbox == nil then
		textbox = wibox.widget.textbox()
	elseif type(textbox) == "string" then
		textbox = wibox.widget.textbox(textbox)
	end
	if not screen then
		screen = screens.primary()
	end
	-- textbox._layout:get_context():set_resolution(screens.ydpi(screen) * dpi.yfactor(screen))
	return textbox
end

function dpi.x(value, screen)
	if not scale_x_cache[screen] then
		local xdpi = screens.xdpi(screen)
		if xdpi == nil then
			xdpi = default_dpi
		end
		scale_x_cache[screen] = (xdpi * dpi.xfactor(screen)) / default_dpi
	end
	return value * scale_x_cache[screen]
end

function dpi.y(value, screen)
	if not scale_y_cache[screen] then
		local ydpi = screens.ydpi(screen)
		if ydpi == nil then
			ydpi = default_dpi
		end
		scale_y_cache[screen] = (ydpi * dpi.yfactor(screen)) / default_dpi
	end
	return value * scale_y_cache[screen]
end

return dpi
