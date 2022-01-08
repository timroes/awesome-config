local io = require('io')
local yaml = require('lyaml')
local gears = require('gears')

local config = {}

local settings = {}

local configFile = io.open(gears.filesystem.get_configuration_dir() .. '/configs/config.yml', 'r')
if configFile then
	local configYaml = configFile:read('*all')
	configFile:close()
	settings = yaml.load(configYaml)
end

function config.get(key, default)
	local level = settings
	for i,k in pairs(gears.string.split(key, '[.]')) do
		if not level then return default end
		level = level[k]
	end
	return level or default
end

config.MOD = 'Mod4'

return config
