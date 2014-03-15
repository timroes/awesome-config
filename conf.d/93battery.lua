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

module('widgets.battery')

local batdev = 'BAT0'
local widget
local label

local function read(file)
	local f = io.open(file)
	local ret = f:read()
	f:close()
	return ret
end

local function to_time_string(time)
	local hours = math.floor(time / 3600)
	local minutes = math.floor((time - hours * 3600) / 60)
	return tostring(hours) .. ':' .. string.format('%02d', minutes)
end

local function update()
	local cap = tonumber(read('/sys/class/power_supply/' .. batdev .. '/capacity'))
	local status = read('/sys/class/power_supply/' .. batdev .. '/status')
	local charging = status == 'Charging'
	local full = status == 'Full'
	local power_now = tonumber(read('/sys/class/power_supply/' .. batdev .. '/power_now'))
	local power_remain = tonumber(read('/sys/class/power_supply/' .. batdev .. '/energy_now'))
	local last_full = tonumber(read('/sys/class/power_supply/' .. batdev .. '/energy_full'))

	local src
	if full or status == 'Unknown' then
		src = 'battery-100-charging'
		label:set_text('')
	else
		-- Round charge to the next 20 points (for the image)
		local charge = string.format('%03d', math.floor(cap / 20 + 0.5) * 20)
		src = 'battery-' .. charge
		
		tooltip = tostring(cap) .. '%'

		if charging then
			src = src .. '-charging'
			-- SHow percentage (since remaining time is not predictable (since it's not linear at all)
			label:set_text(' ' .. math.floor((power_remain / last_full) * 100) .. '%')
		else
			label:set_text(' ' .. to_time_string((power_remain / power_now) * 3600))
		end
	end

	widget:set_image(configpath .. '/images/' .. src .. '.png')
end

local function create(_)
	local layout = w.layout.fixed.horizontal()
	local mlayout = w.layout.margin()

	widget = w.widget.imagebox()
	widget:fit(24, 24)
	widget:set_resize(false)

	label = w.widget.textbox()

	mlayout:set_widget(widget)
	mlayout:set_top(2)

	layout:add(mlayout)
	layout:add(label)

	local refresh = timer({ timeout = 10 })
	refresh:connect_signal('timeout', function(self)
		update()
	end)
	refresh:start()

	update()

	dbus.request_name('system', 'de.timroes.batterywidget')
	dbus.add_match('system', "interface='de.timroes.batterywidget'")
	dbus.connect_signal('de.timroes.batterywidget', function(msg)
		update()
	end)

	return layout
end

setmetatable(_M, { __call = create })
