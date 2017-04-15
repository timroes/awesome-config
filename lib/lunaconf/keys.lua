local gears = require('gears')
local root = root

local keys = {}

function keys.globals (...)
	root.keys(gears.table.join(root.keys(), ...))
end

return keys
