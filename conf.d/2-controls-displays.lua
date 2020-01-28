local lunaconf = require('lunaconf')

lunaconf.utils.command_exists('xrandr', function(xrandr_exists)
	if xrandr_exists then
		lunaconf.displayswitcher({ lunaconf.config.MOD }, 'p')
	end
end)
