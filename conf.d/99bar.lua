local awful = require("awful")
local wibox = require("wibox")
local networkmonitor = require("widgets.networkmonitor")
local orglendar = require("widgets.orglendar")
local battery = require('widgets.battery')
local displayswitcher = require('widgets.displayswitcher')
local screensaver = require('widgets.screensaver')

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
	awful.button({ MOD }, 1, function(c)
		awful.layout.set(awful.layout.suit.max)
		c.minimized = false
		client.focus = c
		c:raise()
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

-- Copied from awful.widget.common but modified. --

local create_buttons = function(buttons, object)
	if buttons then
		local btns = {}
		for kb, b in ipairs(buttons) do
			-- Create a proxy button object: it will receive the real
			-- press and release events, and will propagate them the the
			-- button object the user provided, but with the object as
			-- argument.
			local btn = button { modifiers = b.modifiers, button = b.button }
			btn:connect_signal("press", function () b:emit_signal("press", object) end)
			btn:connect_signal("release", function () b:emit_signal("release", object) end)
			btns[#btns + 1] = btn
		end

		return btns
	end
end

-- Function to render one item in the task list
local tasklist_widget = function(w, buttons, label, data, objects)
	-- update the widgets, creating them if needed
	w:reset()
	for i, o in ipairs(objects) do
		local cache = data[o]
		local ib, tb, bgb, m, l, spacer
		if cache then
			ib = cache.ib
			tb = cache.tb
			bgb = cache.bgb
			m   = cache.m
			im = cache.im
		else
			ib = wibox.widget.imagebox()
			tb = wibox.widget.textbox()
			bgb = wibox.widget.background()
			m = wibox.layout.margin(tb, 4, 4)
			im = wibox.layout.margin(ib, 4, 4, 4, 4)
			l = wibox.layout.fixed.horizontal()

			-- All of this is added in a fixed widget
			l:fill_space(true)
			l:add(im)
			l:add(m)

			-- And all of this gets a background
			bgb:set_widget(l)

			bgb:buttons(create_buttons(buttons, o))

			data[o] = {
				ib = ib,
				tb = tb,
				bgb = bgb,
				m = m,
				im = im
			}
		end

		local text, bg, bg_image, icon = label(o)
		-- The text might be invalid, so use pcall
		if not pcall(tb.set_markup, tb, text) then
			tb:set_markup("<i>&lt;Invalid text&gt;</i>")
		end
		bgb:set_bg(bg)
		if type(bg_image) == "function" then
			bg_image = bg_image(tb,o,m,objects,i)
		end
		bgb:set_bgimage(bg_image)
		ib:set_image(icon)

		-- spacer = wibox.layout.margin(bgb, 0, 0)
		w:add(bgb)
	end
	-- w:add(wibox.layout.fixed.horizontal())
end

for s = 1, screen.count() do

	tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist.buttons, nil, tasklist_widget)

	local layoutbox = awful.widget.layoutbox(s)

	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(awful.widget.taglist(s, filter_noname_tags, taglist.buttons))
	left_layout:add(spacer(3))
	left_layout:add(awful.widget.taglist(s, filter_named_tags, taglist.buttons))
	left_layout:add(spacer(3))

	local right_layout = wibox.layout.fixed.horizontal()
	if s == PRIMARY then 

		-- load widgets from config file
		local widgets = split(settings['widgets'], ',')
		for i,w in pairs(widgets) do
			if tonumber(w) ~= nil and tonumber(w) > 0 then
				right_layout:add(spacer(tonumber(w)))
			elseif w == 'displayswitcher' then
				right_layout:add(displayswitcher())
			elseif w == 'battery' then
				right_layout:add(battery())
			elseif w == 'screensaver' then
				right_layout:add(screensaver())
			elseif w == 'network' then
				right_layout:add(networkmonitor())
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
	layout:set_middle(tasklist[s])
	layout:set_right(right_layout)

	bars[s] = awful.wibox({ position = "top", screen = s, height = "28" })
	bars[s]:set_widget(layout)

end

local bars_visible = true

root.keys(awful.util.table.join(root.keys(),
	awful.key({ MOD }, "b", function()
		bars_visible = not bars_visible
		for i,bar in pairs(bars) do
			bar.visible = bars_visible
		end
	end)
))
