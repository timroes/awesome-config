local wibox = require('wibox')
local gears = require('gears')
local inspect = require('inspect')
local lunaconf = {
	dbus = require('lunaconf.dbus'),
	dpi = require('lunaconf.dpi'),
	notify = require('lunaconf.notify'),
	theme = require('lunaconf.theme')
}

local stats_panel = require('lunaconf.sidebar.stats_panel')

local battery = {}

local theme = lunaconf.theme.get()

local empty_percentage = 30
local critical_time_left_minutes = 15

local shown_warning
local colors = {
	charging = theme.battery_charging,
	fully_charged = theme.battery_fully_charged,
	bat_good = theme.battery_good,
	bat_empty = theme.battery_empty,
	bat_critical = theme.battery_critical
}

local state_strings = {
	[0] = 'Unknown',
	[1] = 'Charging',
	[2] = 'Discharging',
	[3] = 'Empty',
	[4] = 'Fully charged',
	[5] = 'Pending charge',
	[6] = 'Pending discharge'
}

local function to_time_string(time)
	local hours = math.floor(time / 3600)
	local minutes = math.floor((time - hours * 3600) / 60)
	if hours == 0 and minutes == 0 then
		return ''
	end
	return string.format('%sh %sm', hours, minutes)
end

local function set_color(self, color)
	if color ~= self._quick_status_bar.color then
		self._quick_status_bar.color = color
		self._quick_status_bar.border_color = color
		self._stats_panel:set_color(color)
	end
end

local function update_battery(self)
	lunaconf.dbus.system('org.freedesktop.UPower',
		'/org/freedesktop/UPower/devices/DisplayDevice',
		'org.freedesktop.DBus.Properties',
		'GetAll',
		{ 's:org.freedesktop.UPower.Device' },
		function(status)
			self._quick_status_bar:set_value(status.Percentage)
			self._stats_panel:set_percentage(status.Percentage)
			self._stats_panel:set_title('Battery (' .. state_strings[status.State] .. ')')
			local time = status.State == 1
				and to_time_string(status.TimeToFull)
				or to_time_string(status.TimeToEmpty)
			local format_string = time == ''
				and '%.1f%% / %.2f W'
				or '%.1f%% / %.2f W / %s'
			self._stats_panel:set_value(string.format(format_string, status.Percentage, status.EnergyRate, time))

			if status.State == 4 then
				self._battery_warning_shown = false
				set_color(self, colors.fully_charged)
			elseif status.State == 1 then
				self._battery_warning_shown = false
				set_color(self, colors.charging)
			else
				if status.TimeToEmpty <= critical_time_left_minutes * 60 then
					if not self._battery_warning_shown then
						lunaconf.notify.show {
							title = 'Battery Warning',
							text = 'Remaining time under ' .. critical_time_left_minutes .. ' minutes',
							icon = 'battery-caution',
							timeout = 10
						}
						self._battery_warning_shown = true
					end
					set_color(self, colors.bat_critical)
				elseif status.Percentage <= empty_percentage then
					set_color(self, colors.bat_empty)
				else
					set_color(self, colors.bat_good)
				end
			end
		end)
end

local function new(_, screen)
	local self = {}
	for k,v in pairs(_) do
		self[k] = v
	end

	self._quick_status_bar = wibox.widget {
		widget = wibox.widget.progressbar,
		max_value = 100,
		value = 0,
		forced_width = lunaconf.dpi.x(50, screen),
		margins = {
			top = lunaconf.dpi.y(10, screen),
			bottom = lunaconf.dpi.y(10, screen),
			right = lunaconf.dpi.x(4, screen),
			left = lunaconf.dpi.x(4, screen)
		},
		paddings = lunaconf.dpi.x(1, screen),
		color = colors.fully_charged,
		background_color = '#00000000',
		border_width = lunaconf.dpi.x(1, screen),
		border_color = colors.fully_charged,
		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar
	}

	self._stats_panel = stats_panel {
		screen = screen,
		title = 'Battery',
		color = colors.fully_charged
	}

	lunaconf.dbus.properties_changed('/org/freedesktop/UPower/devices/DisplayDevice', function() update_battery(self) end)
	update_battery(self)

	self.quick_status = self._quick_status_bar
	self.full_status = self._stats_panel

	return self
end

return setmetatable(battery, { __call = new })
