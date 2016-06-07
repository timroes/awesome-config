local log = require('lunaconf.log')
local inspect = require('inspect')
local menubar = require('menubar')

local xdg = {}

local apps = {}

function xdg.refresh()
	apps = menubar.utils.parse_dir('/usr/share/applications')
end

function xdg.all()
	return apps
end

return xdg
