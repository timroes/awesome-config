local inspect = require('inspect')
local utils = require('lunaconf.utils')
local menubar = require('menubar')
local awful = require('awful')
local glib = require("lgi").GLib

local xdg = {}

local apps = {}

function xdg.refresh()
	local data_dirs = glib.get_system_data_dirs()
	table.insert(data_dirs, glib.get_user_data_dir() .. '/')

	apps = {}
	for i,path in ipairs(data_dirs) do
		utils.merge_into_table(apps, menubar.utils.parse_dir(path .. 'applications'))
	end
end

function xdg.apps()
	return apps
end

return xdg
