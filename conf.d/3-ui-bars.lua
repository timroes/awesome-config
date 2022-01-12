local awful = require("awful")
local wibox = require("wibox")
local gears = require('gears')
local lunaconf = require('lunaconf')

local bar_height = 32

local sidebar = lunaconf.sidebar.get()

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
local function create_primaryscreen_widgets()
	local primary = lunaconf.screens.primary()
	local widgets = wibox.layout.fixed.horizontal()

	local systray = wibox.widget.systray()
	widgets:add(margin(systray, 2, 2, 8, 8))
	
	-- Add textclock
	local clock = wibox.widget.textclock('%H:%M')
	local cal_action = lunaconf.config.get('calendar.action', nil)
	if cal_action then
		clock:buttons(
			awful.button({}, 1, function()
				lunaconf.utils.spawn("dex '" .. cal_action .. "'")
			end)
		)
	end
	widgets:add(margin(clock, 4, 4, 0, 0))
	
	-- Add the trigger for the sidebar to it
	widgets:add(sidebar.trigger)

	return widgets
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
	primary_bar.widget:set_right(create_primaryscreen_widgets())
end

-- For all current and future screens create a bar
awful.screen.connect_for_each_screen(function(s)
	local layout = wibox.layout.align.horizontal()
	local left_widgets = wibox.widget {
		lunaconf.tags.create_widget(s),
		lunaconf.widgets.tasklist(s, function(tag) return not tag.invisible end),
		layout = wibox.layout.fixed.horizontal
	}
	layout:set_left(left_widgets)
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
