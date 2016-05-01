-- Configure touchpad and trackpoints if available on this device
local awful = require('awful')

awful.util.spawn(scriptpath .. '/init_touchpads.sh')
