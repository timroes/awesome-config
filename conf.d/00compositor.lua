local lunaconf = require('lunaconf')

lunaconf.utils.run_once('compton --config ' .. CONFIG_PATH .. 'compton.conf -b')