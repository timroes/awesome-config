local io = io
local debug = debug
local table = table
local timer = timer
local w = require('wibox')
local awful = require('awful')
local string = string
local math = math
local setmetatable = setmetatable

module("widgets.networkmonitor")

local function trim(s)
	return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

local function split(s,re)
	local i1 = 1
	local ls = {}
	local append = table.insert
	if not re then re = '%s+' end
	if re == '' then return {s} end
	while true do
		local i2,i3 = s:find(re,i1)
		if not i2 then
			local last = s:sub(i1)
			if last ~= '' then append(ls,last) end
			if #ls == 1 and ls[1] == '' then
			return {}
		else
			return ls
		end
	end
	append(ls,s:sub(i1,i2-1))
	i1 = i3+1
	end
end

local function get_all_devices()
	local devices = {}
	for line in io.lines('/proc/net/dev') do
		local dev = line:match('^[%s]?[%s]?[%s]?[%s]?([%w]+):')
		if dev then
			devices[dev] = line
		end
	end

	return devices
end

local function round(num, prec)
	local mult = 10^(prec or 0)
	return math.floor(num * mult + 0.5) / mult
end

local last_stats = nil

local function get_device(dev)
	local devs = get_all_devices()
	if not devs[dev] then return nil end
	local fields = split(trim(devs[dev]))
	local down = fields[2]
	local up = fields[10]
	local ret = nil
	if last_stats then
		local ddown = (down - last_stats.down)
		local dup = (up - last_stats.up)

		if ddown >= 0 and dup >= 0 then
			ret = { down = ddown, up = dup }
		end
	end

	last_stats = { up = up, down = down }

	return ret
end

local function readableSize(bytes)
	local unit = 1024
	if bytes < unit then return string.format("%db", math.floor(bytes)) end
	local exp = math.floor(math.log(bytes) / math.log(unit))
	local UNITS = { 'k','m','g' }
	return string.format("%.1f%s", round((bytes / math.pow(unit, exp)), 1), UNITS[exp])
end

local function create(_, dev)
	
	widget = w.widget.textbox()
	widget.fit = function(widget, w, h) return 150, h end
	widget:set_align("center")

	if not dev then
		-- Find device of default route (to 8.8.8.8)
		local route = awful.util.pread('ip route get 8.8.8.8')
		dev = route:gsub(".* dev ([A-Za-z0-9]+) .*", "%1")
	end

	if not dev then
		return nil
	end

	local refresh = timer({ timeout = 1 })
	refresh:connect_signal('timeout', function(self)
		local dev = get_device(dev)
		if dev then
			widget:set_markup(string.format('<span color="#CCFF33">↓ %s</span>  <span color="#F57B00">↑ %s</span>', readableSize(dev.down), readableSize(dev.up)))
		end
	end)
	refresh:start()
	get_device(dev)

	return widget
end

setmetatable(_M, { __call = create })
