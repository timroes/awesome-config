-- Enables numpad on startup when numlockx is installed.
local lunaconf = require('lunaconf')

lunaconf.utils.only_if_command_exists('numlockx', function ()
	lunaconf.utils.spawn('numlockx on')
end)
