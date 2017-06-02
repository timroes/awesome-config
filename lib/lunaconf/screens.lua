local awful = require('awful')
local log = require('lunaconf.log')
local screen = screen

local screens = {}

local function get_first_output(screen)
	local next, t = pairs(screen.outputs)
	return screen.outputs[next(t)]
end

function screens.primary_index()
	return screen.primary.index
end

function screens.primary()
	return screen.primary
end

function screens.xdpi(screen)
	if not screen.outputs then
		return nil
	end
	local output = get_first_output(screen)
	return (screen.geometry.width * 25.4) / output.mm_width
end

function screens.ydpi(screen)
	if not screen.outputs then
		return nil
	end
	local output = get_first_output(screen)
	return (screen.geometry.height * 25.4) / output.mm_height
end

function screens.output_name(screen)
	if not screen.outputs then
		return nil
	end
	local next, t = pairs(screen.outputs)
	return next(t)
end

--- Iterates over all screen in their order form left to right.
-- This method just looks at x coordinates to order the screens and only
-- respects y coordinates of the screen if there are two screens with the same
-- x coordinates.
-- The passed function will be called for each screen and gets the position
-- starting from 0 as first argment and the screen object itself as second.
function screens.iterate_in_order(func)
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
		func(i, s)
	end
end

return screens
