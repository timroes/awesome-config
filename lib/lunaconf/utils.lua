local awful = require('awful')
local gears = require('gears')
local lfs = require('lfs')
local io = io
local log = require('lunaconf.log')

local utils = {}

--- A wrapper around `awful.spawn`, that spawns a process but forwards it's
--- stdout and stderr to a logfile.
-- @param cmd the command and all its parameters to run
function utils.spawn(cmd)
	awful.spawn.with_shell(cmd .. ' >> /tmp/awesome.spawn.log 2>&1')
end

--- Merges one table into another.
-- @param table_to_merge_into the table into which the other should be merged
-- @param merging_table the table that will be merged into the first
-- @param at_front_reverse if this is set to true, the table will be added to the front of the other in reverse order
function utils.merge_into_table(table_to_merge_into, merging_table, at_front_reverse)
	for i,v in ipairs(merging_table) do
		if at_front_reverse then
			table.insert(table_to_merge_into, 1, v)
		else
			table.insert(table_to_merge_into, v)
		end
	end
end

function utils.list_directories(path)
	local dir = lfs.attributes(path)
	if not dir or dir.mode ~= "directory" then
		return {}
	end

	local dirs = {}

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local subdir = path .. '/' .. file
			local f = lfs.attributes(subdir)
			if f and f.mode == "directory" then
				table.insert(dirs, subdir .. '/')
				local subdirs = utils.list_directories(subdir)
				utils.merge_into_table(dirs, subdirs)
			end
		end
	end

	return dirs
end

return utils
