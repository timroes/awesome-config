local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local inspect = require('inspect')
local lunaconf = {
	dbus = require('lunaconf.dbus'),
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	notify = require('lunaconf.notify'),
	theme = require('lunaconf.theme')
}

local battery = {}

local theme = lunaconf.theme.get()

local battery_icon = gears.color.recolor_image(lunaconf.icons.lookup_icon('battery-symbolic'), theme.screenbar_fg)
local ac_icon = gears.color.recolor_image(lunaconf.icons.lookup_icon('battery-full-charging-symbolic'), theme.screenbar_fg)

local dbus_dest = 'org.freedesktop.UPower'

local icon_widget, bar, tooltip
local shown_warning
local bar_color = theme.battery_bar_color or '#000000'
local warning_color = theme.battery_warning_color or '#FF0000'

local state_strings = {
	[0] = 'Unknown',
	[1] = 'Charging',
	[2] = 'Discharging',
	[3] = 'Empty',
	[4] = 'Fully charged',
	[5] = 'Pending charge',
	[6] = 'Pending discharge'
}


--- Checks whether the battery is in a critical state and recolor bar and
--- show notification if it is
local function check_critical(status)
	-- Reset warning when battery isn't discharging anymore
	if status.State ~= 2 then
		shown_warning = false
	end
	if status.State == 2 and status.TimeToEmpty <= 60 * 20 then
		-- If battery is critical show notification
		bar.color = warning_color
		if not shown_warning then
			lunaconf.notify.show {
				title = 'Battery Warning',
				text = 'Remaining time under 20 minutes',
				icon = 'battery-caution',
				timeout = 10
			}
			shown_warning = true
		end
	else
		bar.color = bar_color
	end
end

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
			check_critical(status)

			local time = status.State == 1 -- Charging
				and 'Time to full:\t<b>' .. to_time_string(status.TimeToFull) .. '</b>'
				or 'Remaining:\t<b>' .. to_time_string(status.TimeToEmpty) .. '</b>'
			tooltip.markup = string.format(
				'Status:\t\t<b>%s</b>\n' ..
				'Percentage:\t<b>%.0f%%</b>\n%s\n' ..
				'Energy rate:\t<b>%.2f W</b>',
				state_strings[status.State],
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
		max_value = 100,
		value = 0,
		forced_width = lunaconf.dpi.x(60, screen),
		margins = {
			top = lunaconf.dpi.y(10, screen),
			bottom = lunaconf.dpi.y(10, screen),
			right = 0,
			left = lunaconf.dpi.x(4, screen)
		},
		paddings = 2,
		color = bar_color,
		background_color = '#00000000',
		border_width = 2,
		border_color = bar_color,
		widget = wibox.widget.progressbar
	}

	mlayout:set_widget(icon_widget)
	mlayout:set_top(lunaconf.dpi.y(10, screen))
	mlayout:set_bottom(lunaconf.dpi.y(10, screen))

	layout:add(mlayout)
	layout:add(bar)

	lunaconf.dbus.properties_changed('/org/freedesktop/UPower/devices/DisplayDevice', update_battery)
	lunaconf.dbus.properties_changed('/org/freedesktop/UPower', update_state)

	update_battery()
	update_state()

	return layout
end

return setmetatable(battery, { __call = create })
