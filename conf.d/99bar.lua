local awful = require("awful")
local wibox = require("wibox")
local orglendar = require("widgets.orglendar")
local battery = require('widgets.battery')
local displayswitcher = require('widgets.displayswitcher')
local config = require('lunaconf.config')
local tasklist = require('lunaconf.widgets.tasklist')
local gears = require('gears')
local lunaconf = require('lunaconf')

bars = {}
taglist = {}
tasklists = {}

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

local spacer = function(width)
	return wibox.widget.textbox(string.rep(" ",width))
end

local filter_named_tags = function(t)
	return t.name:len() > 1
end

local filter_noname_tags = function(t)
	return t.name:len() <= 1
end

for s = 1, screen.count() do

	tasklists[s] = lunaconf.widgets.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklists.buttons)

	local layoutbox = awful.widget.layoutbox(s)

	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(lunaconf.widgets.taglist(s, awful.widget.taglist.filter.all, taglist.buttons))
	left_layout:add(spacer(5))

	local right_layout = wibox.layout.fixed.horizontal()
	if s == PRIMARY then

		-- load widgets from config file
		local widgets = split(config.get('bar.widgets', ''), ',')
		for i,w in pairs(widgets) do
			if tonumber(w) ~= nil and tonumber(w) > 0 then
				right_layout:add(spacer(tonumber(w)))
			elseif w == 'displayswitcher' then
				right_layout:add(displayswitcher())
			elseif w == 'battery' then
				right_layout:add(battery())
			elseif w == 'screensaver' then
				right_layout:add(lunaconf.widgets.screensaver())
			elseif w == 'network' then
				right_layout:add(lunaconf.widgets.networkmonitor())
			elseif w == 'systray' then
				right_layout:add(wibox.widget.systray())
			elseif w == 'clock' then
				local clock = awful.widget.textclock("%a, %e. %b  %H:%M", 1)
				orglendar(clock)
				right_layout:add(clock)
			end
		end

	end

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(tasklists[s])
	layout:set_right(right_layout)

	bars[s] = awful.wibox({ position = "top", screen = s, height = config.get("bar.height", 52), bg = lunaconf.theme.get().screenbar_bg })
	bars[s]:set_widget(layout)

end

local bars_visible = true

root.keys(awful.util.table.join(root.keys(),
	awful.key({ config.MOD }, "b", function()
		bars_visible = not bars_visible
		for i,bar in pairs(bars) do
			bar.visible = bars_visible
		end
	end)
))
