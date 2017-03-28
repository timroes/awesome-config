local lunaconf = require('lunaconf')

-- Bind launcher to MOD + space if a launcher has been defined in the configuration
local ext_launcher = lunaconf.config.get('applications.launcher', nil)
local launcher_function
if ext_launcher then
	launcher_function = function() awful.spawn.spawn(ext_launcher) end
else
	local launcher = lunaconf.launcher()
	launcher_function = function() launcher:toggle() end
end

lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, "space", launcher_function),
	awful.key({ lunaconf.config.MOD }, "KP_Insert", launcher_function)
)
