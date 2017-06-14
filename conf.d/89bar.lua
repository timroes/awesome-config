local awful = require("awful")
local wibox = require("wibox")
local orglendar = require("widgets.orglendar")
local config = require('lunaconf.config')
local tasklist = require('lunaconf.widgets.tasklist')
local gears = require('gears')
local lunaconf = require('lunaconf')
local primary_screen = lunaconf.screens.primary_index()

local bars = {}
local taglist = {}
local tasklists = {}

taglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly)
)

tasklists.buttons = awful.util.table.join(
	awful.button({ }, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c.minimized = false
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ config.MOD }, 1, function(c)
		awful.layout.set(awful.layout.suit.max)
		c.minimized = false
		client.focus = c
		c:raise()
	end),
	awful.button({ }, 2, function(c) c:kill() end),
	awful.button({ }, 4, function()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end)
)

--- A simple function creating a spacer widget with the given with for the specified
--- screen.
local function spacer(width, screen)
	return wibox.widget.textbox(string.rep(" ", math.floor(lunaconf.dpi.x(width, screen))))
end

--- Create the widgets, that should only be shown on the primary screen.
--- The widgets will be passed to the specified callback once they are created.
local function create_primaryscreen_widgets(callback)
	lunaconf.pacman.installed('upower', function(upower_installed)

		local primary = lunaconf.screens.primary()
		local widgets = wibox.layout.fixed.horizontal()

		-- Add battery widget if upower is installed
		if upower_installed then
			widgets:add(lunaconf.widgets.battery(primary))
		end

		-- Add widget to disable screensaver
		widgets:add(lunaconf.widgets.screensaver(primary))
		-- Add do not disturb widget with hotkey
		widgets:add(lunaconf.widgets.dnd(primary, { lunaconf.config.MOD }, 'd'))

		-- Add textclock
		local clock = wibox.widget.textclock("%a, %e. %b  %H:%M")
		lunaconf.dpi.textbox(clock, primary)
		orglendar(clock, primary)
		widgets:add(clock)

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
		bars[s].widget:set_right(nil)
	end
	-- Create new widgets and attach them on the current primary
	local primary_bar = bars[lunaconf.screens.primary()]
	create_primaryscreen_widgets(function(widgets)
		primary_bar.widget:set_right(widgets)
	end)
end

-- For all current and future screens create a bar
awful.screen.connect_for_each_screen(function(s)
	-- TODO: Use custom tasklist again if needed
	tasklists[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklists.buttons)

	local layoutbox = awful.widget.layoutbox(s)

	local left_layout = wibox.layout.fixed.horizontal()
	-- TODO: Use custom taglist again
	left_layout:add(awful.widget.taglist(s, function(t) return not t.invisible end, taglist.buttons))
	left_layout:add(spacer(5, screen[s]))

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(tasklists[s])

	bars[s] = awful.wibar({
		position = "top",
		screen = s,
		height = lunaconf.dpi.y(config.get("bar.height", 52), screen[s]),
		bg = lunaconf.theme.get().screenbar_bg
	})
	bars[s]:set_widget(layout)

	-- Delete bar when screen is removed
	s:connect_signal('removed', function(c)
		bars[s] = nil
	end)
end)

-- Whenever the primary change move the widgets to the new primary bar
screen.connect_signal('primary_changed', update_primary_bar)
-- Initialize the widgets on the current primary
update_primary_bar()

local bars_visible = true

root.keys(awful.util.table.join(root.keys(),
	awful.key({ config.MOD }, "b", function()
		bars_visible = not bars_visible
		for i,bar in pairs(bars) do
			bar.visible = bars_visible
		end
	end)
))
