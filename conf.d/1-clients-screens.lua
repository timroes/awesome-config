local awful = require('awful')
local lunaconf = require('lunaconf')

-- Focus the screen at the given position (if it's a valid screen position)
local function focus_screen(screen_position)
	for s in screen do
		if s.position == screen_position then
			if client.focus and client.focus.screen == s then
				lunaconf.clients.focus_next(1)
			else
				client.focus = s.clients[1]
			end
			return
		end
	end
end

-- Add hotkeys to navigate to screens between 1 and 9
for i = 1, 9 do
	local key = awful.key({ lunaconf.config.MOD }, '#' .. i + 9, function()
		focus_screen(i)
	end)
	lunaconf.keys.globals(key)
end

-- ##################
-- Directional moving
-- ##################

-- Moves the currently focused client into a specific direction onto the next screen
local function move_in_direction(direction)
	local c = client.focus
	if c and not c.is_docked then
		local tags = c:tags()
		for _,t in pairs(tags) do
			-- t.selected = false
			if t.layout.moveClient then
				 if t.layout.moveClient(c, direction) then
				  -- if any of the tags' layouts could move the client we don't need
					-- to handle it here anymore
					return
				 end
			end
		end
		local new_screen = c.screen:get_next_in_direction(direction)
		if new_screen then
			c:move_to_tag(lunaconf.tags.get_current_tag(new_screen))
			client.focus = c
		end
	end
end

lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, 'Right', function() move_in_direction('right') end),
	awful.key({ lunaconf.config.MOD }, 'Up', function() move_in_direction('up') end),
	awful.key({ lunaconf.config.MOD }, 'Down', function() move_in_direction('down') end),
	awful.key({ lunaconf.config.MOD }, 'Left', function() move_in_direction('left') end)
)
