local awful = require('awful')
local lunaconf = require('lunaconf')
local config = require("lunaconf.config")

local lock_cmd = lunaconf.utils.scriptpath() .. "lockscreen.sh"
-- lockout time in minutes
local screensaver_timeout = lunaconf.config.get('screensaver.timeout', 10)

-- Use lock_cmd as a screensaver
lunaconf.utils.run_once("xautolock -time " .. screensaver_timeout .. " -locker '" .. lock_cmd .. "'")

-- Add shortcut for config.MOD + l to lock the screen
lunaconf.keys.globals(awful.key({ config.MOD }, "l", function()
	awful.spawn.spawn('xautolock -locknow')
end))
