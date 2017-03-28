-- Configure touchpad and trackpoints if available on this device
local lunaconf = require('lunaconf')

lunaconf.utils.spawn(scriptpath .. '/init_touchpads.sh')
