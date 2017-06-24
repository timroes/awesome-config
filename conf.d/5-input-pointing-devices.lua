-- Configure touchpad and trackpoints if available on this device
local lunaconf = require('lunaconf')

lunaconf.utils.spawn(lunaconf.utils.scriptpath() .. '/pointing-devices.sh')
