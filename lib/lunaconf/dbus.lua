local Gio = require('lgi').Gio
local GLib = require('lgi').GLib
local lunaconf = {
	strings = require('lunaconf.strings')
}
local awesome_dbus = dbus

local dbus = {}

local properties_changed_listener = {}

local system_bus = Gio.bus_get_sync(Gio.BusType.SYSTEM)

--- Send a message via the system DBus and call the passed callback with
--- the answer returned from DBus. If an error occurred the callback won't
--- be called.
function dbus.system(dest, path, interface, method, params, callback)

	local arguments = nil

	if params then
		local variants = {}
		for i, param in ipairs(params) do
			local fields = lunaconf.strings.split(param, ':')
			table.insert(variants, GLib.Variant(fields[1], fields[2]))
		end
		arguments = GLib.Variant.new_tuple(variants, #variants)
	end

	local res, err = system_bus:call_sync(
			dest,
			path,
			interface,
			method,
			arguments,
			nil, -- Not sure what it is
			Gio.DBusConnectionFlags.NONE, -- Call flags
			-1 -- timeout
		)

		if not err and callback then
			callback(res[1])
		end
end

--- Subscribe to a PropertiesChanged dbus event for the specific path.
-- The specified listener will be called whenever a property of that path change.
-- This function is needed, since dbus.connect_signal only allows one listener
-- per interface and all property changed listeners need to listen on the same
-- org.freedesktop.DBus.Properties interface.
function dbus.properties_changed(path, listener)
	awesome_dbus.add_match('system', "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='" .. path .. "'")
	properties_changed_listener[path] = listener
end

-- Listen for PropertiesChanged events and call the registered listener for that path.
awesome_dbus.connect_signal('org.freedesktop.DBus.Properties', function(signal, ...)
	if signal.member == 'PropertiesChanged' and properties_changed_listener[signal.path] then
		properties_changed_listener[signal.path](signal, ...)
	end
end)

return dbus
