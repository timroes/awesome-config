local awful = require('awful')

-- Use i3lock to lock the screen (requires package x11-misc/i3lock)
local lock_cmd = "i3lock -c BBBBBB -d"
-- lockout time in minutes
local screensaver_timeout = 10

-- Use lock_cmd as a screensaver (requires x11-misc/xautolock)
awful.util.spawn("xautolock -time " .. screensaver_timeout .. " -locker '" .. lock_cmd .. "'")

-- Add shortcut for MOD + l to lock the screen
add_key({ MOD }, "l", function() awful.util.spawn(lock_cmd) end)
