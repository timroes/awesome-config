local lunaconf = require('lunaconf')

-- Use dex tool to start all desktop files from xdg autostart folders or show a warning
-- if dex isn't installed
lunaconf.utils.command_exists('dex', function(exists)
	if exists then
		lunaconf.utils.spawn('dex -a -e awesome')
	else
		lunaconf.notify.show({
			title = 'dex missing',
			text = 'Install `dex` to enable autostart',
			icon = 'dialog-warning'
		})
	end
end)
