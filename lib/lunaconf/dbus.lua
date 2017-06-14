local Gio = require('lgi').Gio
local GLib = require('lgi').GLib
local lunaconf = {
	strings = require('lunaconf.strings')
}

local dbus = {}

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

		if not err then
			callback(res[1])
		end
end

return dbus
