local lunaconf = require('lunaconf')

-- Use dex tool to start all desktop files from xdg autostart folders
lunaconf.utils.spawn('dex -a -e awesome')
