-- Logging via the log functions here will log to syslog.
-- If you use systemd you can easily follow the log with:
-- $ journalctl -t awesome -f

local awful = require('awful')

local log = {}

function log.log(level, message, ...)
	awful.spawn.spawn('logger -t awesome "' .. string.format(message, ...) .. '"')
end

function log.info(message, ...)
	log.log('info', message, ...)
end

function log.notice(message, ...)
	log.log('notice', message, ...)
end

function log.warning(message, ...)
	log.log('warning', message, ...)
end

function log.err(message, ...)
	log.log('err', message, ...)
end

return log
