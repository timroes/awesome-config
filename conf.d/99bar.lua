local awful = require("awful")
local wibox = require("wibox")
local networkmonitor = require("widgets.networkmonitor")
local orglendar = require("widgets.orglendar")
local battery = require('widgets.battery')
local displayswitcher = require('widgets.displayswitcher')

bars = {}
taglist = {}
tasklist = {}

taglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly)
)

tasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c.minimized = false
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 2, function(c) c:kill() end),
	awful.button({ }, 4, function()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function()
		awful.client.focus.byidx(-1)
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

	taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

	tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist.buttons)

	local layoutbox = awful.widget.layoutbox(s)

	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(awful.widget.taglist(s, filter_noname_tags, taglist.buttons))
	left_layout:add(spacer(3))
	left_layout:add(awful.widget.taglist(s, filter_named_tags, taglist.buttons))
	left_layout:add(spacer(3))

	local right_layout = wibox.layout.fixed.horizontal()
	if s == PRIMARY then 
		right_layout:add(spacer(2))
		right_layout:add(displayswitcher())
		right_layout:add(spacer(2))
		right_layout:add(battery())
		right_layout:add(spacer(3))
		right_layout:add(networkmonitor())
		right_layout:add(spacer(3))
		right_layout:add(wibox.widget.systray())
		right_layout:add(spacer(3))
		local clock = awful.widget.textclock("%a, %e. %b  %H:%M", 1)
		orglendar(clock)
		right_layout:add(clock)
		right_layout:add(spacer(2))
	end

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(tasklist[s])
	layout:set_right(right_layout)

	bars[s] = awful.wibox({ position = "top", screen = s, height = "28" })
	bars[s]:set_widget(layout)

end
