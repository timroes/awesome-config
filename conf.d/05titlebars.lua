local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local t = require("timer")
local lunaconf = require("lunaconf")
local colorbox = require("lunaconf.widgets.colorbox")

local theme = lunaconf.theme.get()

local titlebar_height = 30

local titlebars_enabled = true

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

client.connect_signal("manage", function(c, startup)

	local client_status = colorbox.rect(10, 10, {
		margin = (titlebar_height - 10) / 2
	})

	local icon = awful.titlebar.widget.iconwidget(c)
	local margin_icon = wibox.layout.margin(icon, 8, 12, 5, 5)

	local center_layout = wibox.layout.fixed.horizontal()
	center_layout:add(margin_icon)
	center_layout:add(awful.titlebar.widget.titlewidget(c))

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

end)