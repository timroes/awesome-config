local setmetatable = setmetatable
local awful = require('awful')
local w = require('wibox')
local io = io
local timer = timer
local dbg = dbg
local tonumber = tonumber
local configpath = configpath
local tostring = tostring
local math = math
local string = string
local dbus = dbus
local Gio = require('lgi').Gio
local GLib = require('lgi').GLib
local config = require('lunaconf.config')
local icons = require('lunaconf.icons')

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

	if batteryStatus.State == 1 or batteryStatus == 4 then
		label:set_text(string.format('%.0f%% (%s)', batteryStatus.Percentage, to_time_string(batteryStatus.TimeToFull)))
	else
		label:set_text(string.format('%s (%.0f%%)', to_time_string(batteryStatus.TimeToEmpty), batteryStatus.Percentage))
	end

	widget:set_image(icons.lookup_icon(batteryStatus.IconName))
end

local function create(_)
	local layout = w.layout.fixed.horizontal()
	local mlayout = w.layout.margin()

	widget = w.widget.imagebox()
	widget:set_resize(true)

	label = w.widget.textbox()

	mlayout:set_widget(widget)
	mlayout:set_top(2)

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
