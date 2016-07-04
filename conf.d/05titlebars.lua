local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local lunaconf = require("lunaconf")
local colorbox = require("lunaconf.widgets.colorbox")

local theme = lunaconf.theme.get()

local titlebars_enabled = true
local previous_titlebar_heights = {}

local ontop_color = lunaconf.theme.get().ontop_indicator
if ontop_color then ontop_color = gears.color(ontop_color) end

local floating_color = lunaconf.theme.get().floating_indicator
if floating_color then floating_color = gears.color(floating_color) end

lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD, "Shift" }, "t", function()
		titlebars_enabled = not titlebars_enabled
		for k, c in ipairs(client.get()) do
			awful.titlebar.toggle(c)
		end
	end)
)

local function refresh_titlebar(c)

	-- Don't draw a titlebar for windows, that don't want to be in the taskbar
	if c.skip_taskbar then
		awful.titlebar.hide(c)
		return
	end

	local s = screen[c.screen]
	local titlebar_height = lunaconf.dpi.y(30, s)
	local color_indicator_size = lunaconf.dpi.y(10, s)

	local titlebar = awful.titlebar(c)
	if titlebar then
		if previous_titlebar_heights[c.window] == titlebar_height then
			-- If titlebar height hasn't changed, when changing screen, don't redraw anything
			return
		end
	end

	previous_titlebar_heights[c.window] = titlebar_height

	local client_status = colorbox.rect(color_indicator_size, color_indicator_size, {
		margin = (titlebar_height - color_indicator_size) / 2
	})

	local icon = awful.titlebar.widget.iconwidget(c)
	local margin_icon = wibox.layout.margin(icon,
			lunaconf.dpi.x(8, s),
			lunaconf.dpi.x(12, s),
			lunaconf.dpi.y(5, s),
			lunaconf.dpi.y(5, s)
		)

	local center_layout = wibox.layout.fixed.horizontal()
	center_layout:add(margin_icon)
	local title_widget = awful.titlebar.widget.titlewidget(c)
	lunaconf.dpi.textbox(title_widget, s)
	center_layout:add(title_widget)

	local titlebar = wibox.layout.align.horizontal()
	titlebar:set_left(client_status)
	titlebar:set_middle(center_layout)
	titlebar:set_right(actions)

	if floating_color then
		local switch_floating = function ()
			local floating = awful.client.floating.get(c)
			client_status:set_color2(floating and floating_color or nil)
		end

		c:connect_signal("property::floating", switch_floating)
		switch_floating()
	end

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

	if not titlebars_enabled then
		awful.titlebar.hide(c)
	end
end

client.connect_signal("manage", function(c, startup)

	-- We need to register the screen listener in the manage method per client
	-- otherwise we would get a property change call before the manage call for a newly
	-- created client, in which not all properties are yet set correctly.
	-- By registering it here it will only apply for screen changes after it got managed.
	c:connect_signal("property::screen", function(c)
		-- TODO: On screen change only modify height etc. instead of generating a new titlebar
		refresh_titlebar(c)
	end)

	refresh_titlebar(c)

end)

client.connect_signal("unmanage", function(c)
	-- When client gets unmanaged, remove its stored titlebar height from the cache
	previous_titlebar_heights[c.window] = nil
end)
