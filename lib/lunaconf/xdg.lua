local inspect = require('inspect')
local utils = require('lunaconf.utils')
local menubar = require('menubar')
local awful = require('awful')
local glib = require("lgi").GLib
local log = require('lunaconf.log')

local xdg = {}

local apps = {}

function xdg.refresh(callback)
	local data_dirs = glib.get_system_data_dirs()
	table.insert(data_dirs, glib.get_user_data_dir() .. '/')
	log.info("data_dirs: %s", inspect(data_dirs))

	apps = {}
	for i,path in ipairs(data_dirs) do
		menubar.utils.parse_dir(path .. 'applications', function(result)
			utils.merge_into_table(apps, result)
		end)
	end
end

function xdg.apps()
	return apps
end

return xdg
