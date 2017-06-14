local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local inspect = require('inspect')
local lunaconf = {
	dbus = require('lunaconf.dbus'),
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	widgets = {
		bar = require('lunaconf.widgets.bar')
	}
}

local battery = {}

local battery_icon = gears.color.recolor_image(lunaconf.icons.lookup_icon('battery-symbolic'), lunaconf.widgets.bar.widget_color())
local ac_icon = gears.color.recolor_image(lunaconf.icons.lookup_icon('battery-full-charging-symbolic'), lunaconf.widgets.bar.widget_color())

local dbus_dest = 'org.freedesktop.UPower'

local icon_widget, bar, tooltip

local function to_time_string(time)
	local hours = math.floor(time / 3600)
	local minutes = math.floor((time - hours * 3600) / 60)
	return string.format('%sh %sm', hours, minutes)
end

-- Updates the state (on battery/ac) by setting the appropriate icon
local function update_state()
	lunaconf.dbus.system(dbus_dest,
		'/org/freedesktop/UPower',
		'org.freedesktop.DBus.Properties',
		'GetAll',
		{ 's:org.freedesktop.UPower' },
		function(state)
			local icon = state.OnBattery and battery_icon or ac_icon
			icon_widget:set_image(icon)
		end
	)
end

local function update_battery()
	lunaconf.dbus.system(dbus_dest,
		'/org/freedesktop/UPower/devices/DisplayDevice',
		'org.freedesktop.DBus.Properties',
		'GetAll',
		{ 's:org.freedesktop.UPower.Device' },
		function(status)
			bar:set_value(status.Percentage)

			local time = status.State == 1 -- Charging
				and '<b>Charging time:</b>\t' .. to_time_string(status.TimeToFull)
				or '<b>Remaining:</b>\t' .. to_time_string(status.TimeToEmpty)
			tooltip.markup = string.format(
				'<b>Percentage:</b>\t%.0f%%\n%s\n' ..
				'<b>Energy rate:</b>\t%.2f W',
				status.Percentage,
				time,
				status.EnergyRate
			)
		end)
end

local function create(_, screen)

	local layout = wibox.layout.fixed.horizontal()
	local mlayout = wibox.container.margin()

	tooltip = awful.tooltip {
		mode = 'outside'
	}
	tooltip:add_to_object(layout)

	icon_widget = wibox.widget.imagebox()
	icon_widget:set_resize(true)

	bar = wibox.widget {
		ticks = true,
		max_value = 100,
		value = 0,
		forced_width = lunaconf.dpi.x(60, screen),
		margins = {
			top = lunaconf.dpi.y(10, screen),
			bottom = lunaconf.dpi.y(10, screen),
			right = lunaconf.dpi.x(5, screen),
			left = lunaconf.dpi.x(4, screen)
		},
		paddings = 2,
		color = '#2196F3',
		background_color = '#00000000',
		border_width = 2,
		border_color = '#2196F3',
		widget = wibox.widget.progressbar
	}

	mlayout:set_widget(icon_widget)
	mlayout:set_top(lunaconf.dpi.y(10, screen))
	mlayout:set_bottom(lunaconf.dpi.y(10, screen))

	layout:add(mlayout)
	layout:add(bar)


	-- TODO: Write own better dbus implementation based on lgi
	-- We cannot use dbus.connect_signal in any other place to listen for
	-- the same signal.
	dbus.add_match('system', "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/freedesktop/UPower/devices/DisplayDevice'")
	dbus.add_match('system', "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/freedesktop/UPower'")
	dbus.connect_signal('org.freedesktop.DBus.Properties', function(signal)
		if signal.path == '/org/freedesktop/UPower' then
			update_state()
		elseif signal.path == '/org/freedesktop/UPower/devices/DisplayDevice' then
			update_battery()
		end
	end)

	update_battery()
	update_state()

	return layout
end

return setmetatable(battery, { __call = create })
