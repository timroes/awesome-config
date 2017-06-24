local lunaconf = require('lunaconf')

lunaconf.pacman.installed('xorg-xrandr', function(is_installed)
	if is_installed then
		lunaconf.displayswitcher({ lunaconf.config.MOD }, 'p')
	end
end)
