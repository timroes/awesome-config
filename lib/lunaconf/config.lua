local io = require('io')

local config = {}

local settings = {}

local file = io.open(awful.util.getdir('config') .. '/awesome.conf', 'r')
if file then
	for line in io.lines(awful.util.getdir('config') .. '/awesome.conf') do
		if line:find('#') ~= 1 and #line > 0 then
			-- Parse non comment into settings
			local l = split(line, '=')
			settings[l[1]] = l[2]
		end
	end
end

function config.get(key, default)
	return settings[key] or default
end

config.MOD = config.get('modkey', 'Mod4')

return config
