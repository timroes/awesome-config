local lunaconf = require('lunaconf')

lunaconf.utils.only_if_command_exists('xrandr', function(xrandr_exists)
	lunaconf.displayswitcher({ lunaconf.config.MOD }, 'p')
end)
