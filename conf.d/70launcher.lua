local lunaconf = require('lunaconf')

local launcher = lunaconf.launcher()

-- Bin dlauncher to MOD + space if a launcher has been defined in the configuration
local ext_launcher = lunaconf.config.get('applications.launcher', nil)
if ext_launcher then
	lunaconf.keys.globals(
		awful.key({ lunaconf.config.MOD }, "space", function() awful.util.spawn(ext_launcher) end)
	)
else
	lunaconf.keys.globals(
		awful.key({ lunaconf.config.MOD }, "space", function() launcher.toggle() end),
		awful.key({ lunaconf.config.MOD }, "KP_Insert", function() launcher.toggle() end)
	)
end
