local wibox = require("wibox")
local gears = require("gears")
local t = require("timer")

client.connect_signal("manage", function(c, startup)

	local close_btn = wibox.widget.imagebox()

	local actions = wibox.layout.fixed.horizontal()
	actions:add(close_btn)

	local icon = awful.titlebar.widget.iconwidget(c)
	local margin_icon = wibox.layout.margin(icon, 8, 12, 5, 5)

	local center_layout = wibox.layout.fixed.horizontal()
	center_layout:add(margin_icon)
	center_layout:add(awful.titlebar.widget.titlewidget(c))

	local titlebar = wibox.layout.align.horizontal()
	--titlebar:set_left(margin_icon)
	titlebar:set_middle(center_layout)
	titlebar:set_right(actions)

	local bar = awful.titlebar(c, { size = 30 })
	bar:set_widget(titlebar)

end)