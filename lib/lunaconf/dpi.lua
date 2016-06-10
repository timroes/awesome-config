local theme = require('lunaconf.theme')
local config = require('lunaconf.config')
local wibox = require('wibox')

local typeof = typeof

-- Utilities to work with hidpi screens
local dpi = {}

-- TODO: Get this from one of the several places where this is set
local currentDpi = config.get('theme.dpi', 96)
local scale = currentDpi / 96

-- Pass in an wibox.widget.textbox to this method and it will scale its font
-- so it will take the dpi from the theme into respect. This method will assume
-- the font size set on the textbox was meant to be for 96 dpi.
function dpi.textbox(textbox)
	if textbox == nil then
		textbox = wibox.widget.textbox()
	elseif type(textbox) == "string" then
		textbox = wibox.widget.textbox(textbox)
	end
	textbox._layout:get_context():set_resolution(currentDpi)
	return textbox
end

function dpi.toScale(value)
	return value * scale
end

return dpi
