local beautiful = require("beautiful")
local awful = require('awful')

local theme = {}

local themepath = awful.util.get_configuration_dir() .. "/theme/light/"

beautiful.init(awful.util.get_configuration_dir() .. "/theme/light/theme.lua")

function theme.get()
	return beautiful.get()
end

function theme.path()
	return themepath
end

return theme
