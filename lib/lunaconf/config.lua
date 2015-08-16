local io = require('io')

local config = {}

local settings = {}

local file = io.open(CONFIG_PATH .. '/awesome.conf', 'r')
if file then
	for line in io.lines(CONFIG_PATH .. '/awesome.conf') do
		if line:find('#') ~= 1 and #line > 0 then
			-- Parse non comment into settings
			local l = split(line, '=')
			settings[l[1]] = l[2]
		end
	end
end

function config.get(key, default)
	local value = settings[key]
	value = value or default
	return value
end

config.MOD = config.get('modkey', 'Mod4')

return config