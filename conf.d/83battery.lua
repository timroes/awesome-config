local setmetatable = setmetatable
local awful = require('awful')
local w = require('wibox')
local io = io
local timer = timer
local tonumber = tonumber
local tostring = tostring
local math = math
local string = string
local dbus = dbus
local Gio = require('lgi').Gio
local GLib = require('lgi').GLib
local config = require('lunaconf.config')
local icons = require('lunaconf.icons')
local dpi = require('lunaconf.dpi')
local lunaconf = require('lunaconf')

module('widgets.battery')

local bus = Gio.bus_get_sync(Gio.BusType.SYSTEM)
local widget
local label

local function to_time_string(time)
	local hours = math.floor(time / 3600)
	local minutes = math.floor((time - hours * 3600) / 60)
	return tostring(hours) .. ':' .. string.format('%02d', minutes)
end

-- Query UPower over the dbus for information to show.
local function get_battery_status()
	local status, err = bus:call_sync('org.freedesktop.UPower',
		-- DisplayDevice is a meta device that holds information about
		-- all batteries in the system aggregated together.
		'/org/freedesktop/UPower/devices/DisplayDevice',
		-- Call the GetAll interface to load all properties
		'org.freedesktop.DBus.Properties',
		'GetAll',
		GLib.Variant.new_tuple({
			GLib.Variant('s', 'org.freedesktop.UPower.Device')
		}, 1),
		nil,
		Gio.DBusConnectionFlags.NONE,
		-1
	)

	if err then
		return nil
	end

	return status[1]
end

local function update()
	local batteryStatus = get_battery_status()

	if batteryStatus == nil then
		label:set_text('Install upower!')
		return
	end

	widget:set_image(icons.lookup_icon(batteryStatus.IconName))

	-- Battery states:
	-- 0: Unknown
	-- 1: Charging
	-- 2: Discharging
	-- 3: Empty
	-- 4: Fully charged
	-- 5: Pending charge
	-- 6: Pending discharge
	if batteryStatus.State == 1 then
		label:set_text(string.format('%.0f%% (%s)', batteryStatus.Percentage, to_time_string(batteryStatus.TimeToFull)))
	elseif batteryStatus.State == 4 then
		-- If battery is fully charged, don't output any information, just show the battery_plugged icon.
		label:set_text('')
		widget:set_image(icons.lookup_icon('battery_plugged'))
	else
		label:set_text(string.format('%s (%.0f%%)', to_time_string(batteryStatus.TimeToEmpty), batteryStatus.Percentage))
	end

end

local function create(_, screen)
	local layout = w.layout.fixed.horizontal()
	local mlayout = w.layout.margin()

	widget = lunaconf.widgets.svgbox()
	widget:fit(dpi.x(64, screen), dpi.y(64, screen))
	widget:set_resize(true)

	label = w.widget.textbox()
	dpi.textbox(label, screen)

	mlayout:set_widget(widget)
	mlayout:set_top(dpi.y(10, screen))
	mlayout:set_bottom(dpi.y(10, screen))

	layout:add(mlayout)
	layout:add(label)

	dbus.add_match('system', "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/freedesktop/UPower/devices/DisplayDevice'")
	dbus.connect_signal('org.freedesktop.DBus.Properties', function()
		update()
	end)

	update()

	return layout
end

setmetatable(_M, { __call = create })
