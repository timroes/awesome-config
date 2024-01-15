local screen = screen

local module = {}

-- Lua utility function to return all screen objects as an array
-- since we can't iterate over the screen object from TypeScript
-- since we can't generate pure for-in loops without pairs via
-- TypeScriptToLua
function module.screens_as_array()
	local screens = {}
	for s in screen do
		table.insert(screens, s)
	end
	return screens
end

return module
