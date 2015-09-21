local CONFIG_PATH = CONFIG_PATH
local beautiful = require("beautiful")

local theme = {}

local themepath = CONFIG_PATH .. "theme/light/"

beautiful.init(CONFIG_PATH .. "theme/light/theme.lua")

function theme.get()
	return beautiful.get()
end

function theme.path()
	return themepath
end

return theme
