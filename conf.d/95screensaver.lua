local io = io
local debug = debug
local table = table
local timer = timer
local scriptpath = scriptpath
local w = require('wibox')
local awful = require('awful')
local string = string
local math = math
local setmetatable = setmetatable

module("widgets.screensaver")

local textbox
local widget
local is_off = false
local button_text = '<span color="%s">☀</span>'

local active_color = '#FF5722'
local disabled_color = '#777777'

local function create(_, dev)

	textbox = w.widget.textbox()
	textbox:set_align("center")
	textbox:set_markup(string.format(button_text, disabled_color))

	widget = w.layout.margin(textbox, 5, 5, 0, 0)

	widget:buttons(awful.util.table.join(
		awful.button({ }, 1, function()
			if is_off then
				awful.util.pread(scriptpath .. '/screensaver.sh resume')
				textbox:set_markup(string.format(button_text, disabled_color))
				is_off = false
			else
				awful.util.pread(scriptpath .. '/screensaver.sh pause')
				textbox:set_markup(string.format(button_text, active_color))
				is_off = true
			end
		end)
	))

	return widget
end

setmetatable(_M, { __call = create })
