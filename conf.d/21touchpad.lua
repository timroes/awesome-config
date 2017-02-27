-- Configure touchpad and trackpoints if available on this device
local awful = require('awful')

awful.spawn.spawn(scriptpath .. '/init_touchpads.sh')
