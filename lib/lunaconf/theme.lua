local beautiful = require("beautiful")
local awful = require('awful')
local gears = require('gears')

local theme = {}

function theme.get()
	return beautiful.get()
end

return theme
