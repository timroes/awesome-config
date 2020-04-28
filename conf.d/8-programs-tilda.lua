local awful = require('awful')
local gears = require('gears')
local lunaconf = require('lunaconf')

local function set_position(c)
	local workarea = c.screen.workarea
	c:geometry(workarea)
end

lunaconf.clients.add_rules({
	{
		rule = { class = "Tilda" },
		properties = {
			floating = true,
			border_width = 0,
			opacity = 0.9,
			callback = function(c)
				c.screen = lunaconf.screens.primary()

				-- Set property of tilda whenever it changes (prevent its own scaling mechanism)
				c:connect_signal('property::geometry', set_position)
				-- Fix geometry when the screen of tilda changes
				c:connect_signal('property::screen', set_position)
				set_position(c)
			end
		}
	}
})
