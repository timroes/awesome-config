local awful = require('awful')
local cairo = require('lgi').cairo
local common = require('awful.widget.common')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	config = require('lunaconf.config'),
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	theme = require('lunaconf.theme')
}

local tasklist = {}

local theme = lunaconf.theme.get()

local function margin(widget, left, right, top, bottom, screen)
	return wibox.container.margin(widget,
		lunaconf.dpi.x(left, screen),
		lunaconf.dpi.x(right, screen),
		lunaconf.dpi.y(top, screen),
		lunaconf.dpi.y(bottom, screen)
	)
end

local tasklist_buttons = gears.table.join(
	awful.button({ }, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c.minimized = false
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ lunaconf.config.MOD }, 1, function(c)
		awful.layout.set(awful.layout.suit.max)
		c.minimized = false
		client.focus = c
		c:raise()
	end),
	awful.button({ }, 2, function(c) c:kill() end),
	awful.button({ }, 3, function(c)
		client.focus = c
		c.floating = not c.floating
	end)
)

--- Draws a replacement icon for the given client, that doesn't have client.
local function replacement_icon(client)
	math.randomseed(client.window)
	local r = math.random()
	local g = math.random()
	local b = math.random()
	math.randomseed(os.time())
	local img_surface = cairo.ImageSurface(cairo.Format.ARGB32, 100, 100)
	-- Draw the raw surface onto the new image surface
	local cr = cairo.Context(img_surface)
	cr:set_source_rgb(r, g, b)
	cr:arc(50, 50, 50, 0, 2 * math.pi)
	cr:fill()
	return img_surface
end

local function list_update(screen, container, buttons, label, data, clients)
	-- update the widgets, creating them if needed
	container:reset()
	for i, cl in ipairs(clients) do
		local cache = data[cl]
		local ib, bgb, ibm, l
		if cache then
			ib = cache.ib
			bgb = cache.bgb
			ibm = cache.ibm
		else
			-- TODO: Create tooltip for every icon
			ib = wibox.widget.imagebox()
			bgb = wibox.container.background()
			ibm = margin(ib, 2, 2, 2, 2, screen)
			l = wibox.layout.fixed.horizontal()

			-- All of this is added in a fixed widget
			l:fill_space(true)
			l:add(ibm)

			-- And all of this gets a background
			bgb:set_widget(ibm)

			bgb:buttons(common.create_buttons(buttons, cl))

			data[cl] = {
					ib  = ib,
					bgb = bgb,
					ibm = ibm,
			}
		end

		if not cl.icon and not cl.replacement_icon then
			local ic = lunaconf.icons.lookup_icon(cl.instance)
			if ic then
				cl.replacement_icon = ic
			else
				cl.replacement_icon = replacement_icon(cl)
			end
		end

		if cl.icon then
			ib:set_image(cl.icon)
		elseif cl.replacement_icon then
			ib:set_image(cl.replacement_icon)
		end

		if client.focus == cl then
			bgb:set_bg(theme.tasklist_bg_focus or theme.bg_focus or theme.bg_normal)
		else
			bgb:set_bg(theme.tasklist_bg_normal or theme.bg_normal)
		end

		bgb.opacity = cl.minimized and 0.5 or 1.0

		container:add(bgb)
	end
end

-- A function which creates a filter function for the specific tag, i.e.
-- a function that will accept a client and return true if is tagged with that tag.
local function filter_clients_for_tag(tag)
	return function(client)
		local tags = client:tags()
		for _, t in ipairs(tags) do
			if tag == t then
				return true
			end
		end
		return false
	end
end

-- A helper function creating the shape function for the tagname for a specific screen
local function tag_name_shape(screen, tag)
	return function(cr, width, height)
		gears.shape.partially_rounded_rect(cr, width, height, false, false, true, not tag.is_primary,
			lunaconf.dpi.y(2, screen)
		)
	end
end

--- Create the list of all tasks for one tag including decoration
local function taglist(screen, tag)
	-- The stripe above all clients belonging to this tag
	local tag_stripe = wibox.container.background(wibox.widget{}, nil)
	tag_stripe.forced_height = lunaconf.dpi.y(3, screen)

	local tag_name = wibox.widget {
		text = tag.name:upper(),
		font = theme.tag_name_font,
		widget = wibox.widget.textbox
	}
	local tag_name_box = wibox.container.background(margin(tag_name, 4, 4, 2, 2, screen))
	tag_name_box.shape = tag_name_shape(screen, tag)

	-- Update the tag stripe color dependent on its selected state
	local update_stripe_color = function()
		local bg
		if tag.selected then
			bg = theme.tag_color_selected_bg or theme.bg_focus
		else
			bg = theme.tag_color_bg or theme.bg_normal
		end
		tag_stripe.bg = bg
		tag_name_box.bg = bg
	end

	-- Whenever the selected state of the tag change, update the strip color
	tag:connect_signal('property::selected', update_stripe_color)
	update_stripe_color()

	local tasklist = awful.widget.tasklist(screen, filter_clients_for_tag(tag), tasklist_buttons, nil, function(...)
		list_update(screen, ...)
	end)

	local tasklist_container = wibox.widget {
		tag_stripe,
		margin(tasklist, 4, 0, 0, 0, screen),
		layout = wibox.layout.fixed.vertical
	}

	local check_client_count = function()
		tasklist_container.visible = #tag:clients() > 0
	end

	-- Whenever a client tagging change state, check if we still have clients
	client.connect_signal('tagged', check_client_count)
	client.connect_signal('untagged', check_client_count)
	check_client_count()

	local taglist_widget = wibox.widget {
		{
			tag_name_box,
			valign = 'top',
			widget = wibox.container.place
		},
		tasklist_container,
		layout = wibox.layout.fixed.horizontal
	}

	taglist_widget._screentag_name = tag_name

	return taglist_widget
end

-- A custom render function for awful.widget.taglist, that will use the above
-- 'taglist' function to create a taglist for each tag
local function taglist_update(screen, container, buttons, label, data, tags)
	container:reset()
	for i, t in ipairs(tags) do
		local cache = data[t]
		if not cache then
			data[t] = taglist(screen, t)
		else
			-- If we already have created a list for that screen only change screentag name
			-- This happens when the screen order changes and we are updated because of that
			data[t]._screentag_name.text = t.name:upper()
		end
		container:add(data[t])
	end
end

local function new(self, screen, tag_filter)

	-- The container widget that will be used to put all taglists in
	local taglist_container = wibox.widget {
		spacing = lunaconf.dpi.x(10, screen),
		widget = wibox.layout.fixed.horizontal
	}

	-- Use awful.widget.taglist to render the overall taglist with a custom render function
	local alltags = awful.widget.taglist(screen, tag_filter, nil, nil, function(...)
		taglist_update(screen, ...)
	end, taglist_container)

	return wibox.layout.fixed.horizontal(alltags)
end

return setmetatable(tasklist, { __call = new })
