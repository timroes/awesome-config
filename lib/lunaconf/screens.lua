local awful = require('awful')
local log = require('lunaconf.log')
local screen = screen

local screens = {}

local primary = nil

-- {{{ Offer functions to get screens in their right order
-- 		and not in by their index number

local screen_order = {}

-- Sort screens by their x coordinates
-- and store them in screen_order
table.insert(screen_order, screen[1])
for s = 2, screen.count() do
	local inserted = false
	for i,sc in pairs(screen_order) do
		if screen[s].geometry.x < sc.geometry.x then
			table.insert(screen_order, i, screen[s])
			inserted = true
			break
		end
	end
	if not inserted then
		table.insert(screen_order, screen[s])
	end
end

-- Returns the x-coordinate sorted position of the screen
-- by its screen index
function screen_position(index)
	for i,s in pairs(screen_order) do
		if s.index == index then
			return i
		end
	end
end

-- Returns the screen index (index in screen table) by
-- its position
local function screen_index(position)
	return screen_order[position].index
end
-- }}}

local function detect_primary_screen()
	local primary
	local xrandr = awful.util.pread("xrandr | grep -E ' connected primary [0-9]' | cut -f1 -d' '")
	if #xrandr > 0 then
		-- if a primary screen has been configured via xrandr, use this as primary
		xrandr = xrandr:gsub("%s+$", "") -- remove newline at end of string
		primary = screen[xrandr].index
	end
	-- If xrandr has not been set (or the screen couldn't be detected)
	-- use the screen that is the most in the center of all screens
	if not primary then
		primary = screen_index(math.ceil(screen.count() / 2))
	end

	return primary
end

function screens.primary_index()
	if primary == nil then
		primary = detect_primary_screen()
	end
	return primary
end

function screens.primary()
	return screen[screens.primary_index()]
end

function screens.xdpi(screen)
	if not screen.outputs then
		return nil
	end
	return (screen.geometry.width * 25.4) / screen.outputs['eDP-1'].mm_width
end

function screens.ydpi(screen)
	if not screen.outputs then
		return nil
	end

	return (screen.geometry.height * 25.4) / screen.outputs['eDP-1'].mm_height
end

return screens
