local log = {}

function log.log(level, message, ...)
	awful.util.spawn('logger -t awesome ' .. string.format(message, ...))
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
