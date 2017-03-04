local awful = require('awful')
local strings = require('lunaconf.strings')
local lfs = require('lfs')
local io = io
local log = require('lunaconf.log')

local utils = {}

--- Runs a command if it's not already started
-- @param cmd the command and all its parameters to run
-- @param pidof an optional string to use in the pidof check to
--              whether the process is already running. If this
--              is not specified the first word of cmd will be used.
function utils.run_once(cmd, pidof)
	local pidof = pidof or cmd:match('[%w]+')
	awful.spawn.easy_async('pidof ' .. pidof, function(pid)
		if pid ~= nil and pid:len() > 0 then
			awful.spawn.spawn(cmd)
		end
	end)
end

--- Returns the user that owns the process with the given pid.
--- Will return nil if the user cannot be found.
function utils.user_of_pid(pid)
	-- TODO: requires refactor for awesome 4 to async
	if not pid or pid == 0 then return nil end
	return strings.trim(awful.util.pread('ps -o user ' .. math.floor(pid) .. ' | sed 1d'))
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
