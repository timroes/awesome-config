local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local lunaconf = require("lunaconf")

local theme = lunaconf.theme.get()

local previous_titlebar_heights = {}

local ontop_color = lunaconf.theme.get().ontop_indicator
if ontop_color then ontop_color = gears.color(ontop_color) end

local function should_show_titlebar(c)
	return not c.skip_taskbar and c.floating
end

local function refresh_titlebar(c)
	-- If the client doesn't need a titlebar, hide it and don't continue with configuration
	if not should_show_titlebar(c) then
		awful.titlebar.hide(c)
		return
	end

	local s = c.screen
	local titlebar_height = lunaconf.dpi.y(30, s)
	local color_indicator_size = lunaconf.dpi.y(10, s)

	local titlebar = awful.titlebar(c)
	if titlebar and previous_titlebar_heights[c.window] == titlebar_height then
			-- If titlebar height hasn't changed, when changing screen, don't redraw anything
			return
	end

	previous_titlebar_heights[c.window] = titlebar_height

	local client_status = lunaconf.widgets.colorbox.rect(color_indicator_size, color_indicator_size, {
		margin = (titlebar_height - color_indicator_size) / 2
	})

	local icon = awful.titlebar.widget.iconwidget(c)
	local margin_icon = wibox.container.margin(icon,
			lunaconf.dpi.x(8, s),
			lunaconf.dpi.x(12, s),
			lunaconf.dpi.y(5, s),
			lunaconf.dpi.y(5, s)
		)

	local title_widget = awful.titlebar.widget.titlewidget(c)

	local center_layout = wibox.layout.fixed.horizontal()
	center_layout:add(margin_icon)
	center_layout:add(title_widget)

	local titlebar = wibox.layout.align.horizontal()
	titlebar:set_left(client_status)
	titlebar:set_middle(center_layout)

	if ontop_color then
		local switch_ontop = function ()
			client_status:set_color(c.ontop and ontop_color or nil)
		end

		c:connect_signal("property::ontop", switch_ontop)
		switch_ontop()
	end

	local buttons = awful.util.table.join(
		awful.button({ }, 1, function() lunaconf.clients.smart_move(c) end),
		awful.button({ }, 2, function() c:kill() end)
	)

	titlebar:buttons(buttons)

	local bar = awful.titlebar(c, { size = titlebar_height })
	bar:set_widget(titlebar)
end

client.connect_signal("manage", function(c, startup)
	-- We need to register the screen listener in the manage method per client
	-- otherwise we would get a property change call before the manage call for a newly
	-- created client, in which not all properties are yet set correctly.
	-- By registering it here it will only apply for screen changes after it got managed.
	-- Update titlebar on floating change (since only floating clients have titlebars)
	-- and screen changes (since screens might have different densities and need different
	-- heights of titlebars)
	c:connect_signal("property::screen", refresh_titlebar)
	c:connect_signal("property::floating", refresh_titlebar)

	refresh_titlebar(c)
end)

client.connect_signal("unmanage", function(c)
	-- When client gets unmanaged, remove its stored titlebar height from the cache
	previous_titlebar_heights[c.window] = nil
end)
