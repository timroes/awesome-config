local awful = require('awful')
local screen = screen

local screens = {}

function screens.primary()
	return screen.primary
end

-- #########################
-- Screen position numbering
-- #########################

--- Iterates over all screen in their order form left to right.
-- This method just looks at x coordinates to order the screens and only
-- respects y coordinates of the screen if there are two screens with the same
-- x coordinates.
-- The passed function will be called for each screen and gets the position
-- starting from 0 as first argment and the screen object itself as second.
local function set_screen_positions()
	local sorted_screens = {}
	-- First copy all existing screen objects into the table
	for s in screen do
		table.insert(sorted_screens, s)
	end
	-- Sort that table first by its x coordinates and only respect y if x is the same
	table.sort(sorted_screens, function(a, b)
		if a.geometry.x == b.geometry.x then
			return a.geometry.y < b.geometry.y
		else
			return a.geometry.x < b.geometry.x
		end
	end)

	for i, s in ipairs(sorted_screens) do
		s.position = i
		s:emit_signal('property::position')
	end
end

-- Every time the screen order or screens change make sure to attach the positional
-- number to each screen
screen.connect_signal('list', set_screen_positions)
screen.connect_signal('property::geometry', set_screen_positions)
set_screen_positions()

return screens
