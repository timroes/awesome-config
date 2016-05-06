local lunaconf = require('lunaconf')

lunaconf.utils.run_once('compton --config ' .. awful.util.getdir('config') .. '/compton.conf -b')
