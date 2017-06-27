local awful = require('awful')
local gears = require('gears')
local strings = require('lunaconf.strings')
local lfs = require('lfs')
local io = io
local log = require('lunaconf.log')

local utils = {}

--- The path under which several utility scripts can be found.
function utils.scriptpath()
	return gears.filesystem.get_configuration_dir() .. '/scripts/'
end

--- A wrapper around `awful.spawn`, that spawns a process but forwards it's
--- stdout and stderr to a logfile.
-- @param cmd the command and all its parameters to run
function utils.spawn(cmd)
	awful.spawn.with_shell(cmd .. ' >> /tmp/awesome.spawn.log 2>&1')
end

--- Runs a command if it's not already started
-- @param cmd the command and all its parameters to run
-- @param pidof an optional string to use in the pidof check to
--              whether the process is already running. If this
--              is not specified the first word of cmd will be used.
function utils.run_once(cmd, pidof)
	local pidof = pidof or cmd:match('[%w]+')
	awful.spawn.easy_async('pidof ' .. pidof, function(pid)
		if pid == nil or pid:len() == 0 then
			utils.spawn(cmd)
		end
	end)
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

--- Checks whether the specified command exists.
--- Once the check finished, it will call the passed
--- callback function, with either true (command exists)
--- or false (command doesn't exist).
function utils.command_exists(command, callback)
	awful.spawn.easy_async("/bin/bash -c 'command -v " .. command .. "'", function(stdout, stderr, reason, status)
		callback(status == 0)
	end)
end

--- Checks whether the specified command exists and execute the
--- given callback only if it exists.
function utils.only_if_command_exists(command, callback)
	utils.command_exists(command, function(exists)
		if exists then
			callback()
		end
	end)
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
