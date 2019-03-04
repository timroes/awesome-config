local awful = require("awful")
local wibox = require("wibox")
local config = require('lunaconf.config')
local tasklist = require('lunaconf.widgets.tasklist')
local gears = require('gears')
local lunaconf = require('lunaconf')

local bar_height = 32

local function margin(widget, left, right, top, bottom, screen)
	if not screen then
		screen = lunaconf.screens.primary()
	end
	left = lunaconf.dpi.x(left, screen)
	right = lunaconf.dpi.x(right, screen)
	top = lunaconf.dpi.y(top, screen)
	bottom = lunaconf.dpi.y(bottom, screen)
	return wibox.container.margin(widget, left, right, top, bottom)
end

--- Create the widgets, that should only be shown on the primary screen.
--- The widgets will be passed to the specified callback once they are created.
local function create_primaryscreen_widgets(callback)
	lunaconf.pacman.installed('upower', function(upower_installed)

		local primary = lunaconf.screens.primary()
		local widgets = wibox.layout.fixed.horizontal()

		-- Add battery widget if upower is installed
		if upower_installed then
			widgets:add(margin(lunaconf.widgets.battery(primary), 4, 4, 0, 0))
		end

		local systray = wibox.widget.systray()
		widgets:add(margin(systray, 2, 2, 8, 8))

		-- Add widget to disable screensaver
		widgets:add(lunaconf.widgets.screensaver(primary))
		-- Add do not disturb widget with hotkey
		widgets:add(lunaconf.widgets.dnd(primary, { lunaconf.config.MOD, 'Control' }, 'd'))

		-- Add textclock
		local clock = wibox.widget.textclock("%H:%M")
		lunaconf.widgets.calendar(clock) -- Attach calendar to clock
		widgets:add(margin(clock, 4, 8, 0, 0))

		callback(widgets)
	end)
end

--- Function to be executed whenever the primary screen changes.
-- This will remove the primar widgets from all bars (actually it should only be
-- on the old primary screen) and after that creates a new set of widgets for the
-- new primary screen and attach them to its bar.
local function update_primary_bar()
	-- Remove primary widgets from all current screens.
	for s in screen do
		s.bar.widget:set_right(nil)
	end
	-- Create new widgets and attach them on the current primary
	local primary_bar = lunaconf.screens.primary().bar
	create_primaryscreen_widgets(function(widgets)
		primary_bar.widget:set_right(widgets)
	end)
end

-- For all current and future screens create a bar
awful.screen.connect_for_each_screen(function(s)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(lunaconf.widgets.tasklist(s, function(tag) return not tag.invisible end))
	layout:set_middle(margin(lunaconf.widgets.clienttitle(s), 12, 4, 0, 0))

	local bar = awful.wibar {
		position = "top",
		screen = s,
		height = lunaconf.dpi.y(bar_height, s),
		bg = lunaconf.theme.get().screenbar_bg
	}
	bar:set_widget(layout)

	s.bar = bar
end)

-- Whenever the primary change move the widgets to the new primary bar
screen.connect_signal('primary_changed', update_primary_bar)
-- Initialize the widgets on the current primary
update_primary_bar()
