local inspect = require('inspect')
local utils = require('lunaconf.utils')
local menubar = require('menubar')
local awful = require('awful')
local glib = require("lgi").GLib
local log = require('lunaconf.log')

local xdg = {}

local apps = {}
local apps_by_id = {}

function xdg.refresh(callback)
	local data_dirs = glib.get_system_data_dirs()
	table.insert(data_dirs, glib.get_user_data_dir() .. '/')
	log.info("data_dirs: %s", inspect(data_dirs))

	apps = {}
	apps_by_id = {}
	for i,path in ipairs(data_dirs) do
		menubar.utils.parse_dir(path .. 'applications', function(result)
			for i, desktop in ipairs(result) do
				local id = desktop.file:match('.-([^\\/]-)%.?[^%.\\/]*$')
				apps_by_id[id] = desktop
			end
			utils.merge_into_table(apps, result)
		end)
	end
end

function xdg.apps()
	return apps
end

function xdg.get_entry(id)
	return apps_by_id[id]
end

return xdg
