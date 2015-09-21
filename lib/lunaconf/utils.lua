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
	return strings.trim(awful.util.pread('ps -o user ' .. pid .. ' | sed 1d'))
end

return utils