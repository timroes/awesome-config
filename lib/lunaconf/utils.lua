local awful = require('awful')
local strings = require('lunaconf.strings')

local utils = {}

--- Checks whether the specified process is running (i.e. has at least on pid)
function utils.is_running(proc)
	local pid = awful.util.pread('pidof ' .. proc)
	return pid ~= nil and pid:len() > 0
end

--- Runs a command if it's not already started
-- @param cmd the command and all its parameters to run
-- @param pidof an optional string to use in the pidof check to
--              whether the process is already running. If this
--              is not specified the first word of cmd will be used.
function utils.run_once(cmd, pidof)
	local pidof = pidof or cmd:match('[%w]+')
	if not utils.is_running(pidof) then
		awful.util.spawn(cmd)
	end
end

--- Returns the user that owns the process with the given pid.
--- Will return nil if the user cannot be found.
function utils.user_of_pid(pid)
	if not pid then return nil end
	return strings.trim(awful.util.pread('ps -o user ' .. math.floor(pid) .. ' | sed 1d'))
end

function utils.merge_into_table(table_to_merge_into, merging_table)
	for i,v in ipairs(merging_table) do
		table.insert(table_to_merge_into, v)
	end
end

--- Checks whether the specified command exists.
-- @return true if the specific command exists and can be executed.
function utils.command_exists(command)
	local result = awful.util.pread("/bin/bash -c 'command -v " .. command .. " >/dev/null 2>&1 && echo true || echo false'")
	if strings.trim(result) == "true" then
		return true
	else
		return false
	end
end


return utils
