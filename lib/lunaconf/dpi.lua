local dpiUtils = require('lib.dpi');

-- Utilities to work with hidpi screens
local dpi = {}

function dpi.x(value, screen)
	return dpiUtils.dpiX(value, screen)
end

function dpi.y(value, screen)
	return dpiUtils.dpiY(value, screen)
end

return dpi
