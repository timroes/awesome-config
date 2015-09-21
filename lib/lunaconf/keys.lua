local awful = require('awful')
local root = root

local keys = {}

function keys.globals (...)
	root.keys(awful.util.table.join(root.keys(), ...))
end

return keys