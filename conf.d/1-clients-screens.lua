local awful = require('awful')
local lunaconf = require('lunaconf')

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
