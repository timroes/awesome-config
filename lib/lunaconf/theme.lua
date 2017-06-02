local beautiful = require("beautiful")
local awful = require('awful')
local gears = require('gears')

local theme = {}

local themepath = gears.filesystem.get_configuration_dir() .. "/theme/light/"

beautiful.init(gears.filesystem.get_configuration_dir() .. "/theme/light/theme.lua")

function theme.get()
	return beautiful.get()
end

function theme.path()
	return themepath
end

return theme
