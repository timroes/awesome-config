local awful = require('awful')
local gears = require('gears')
local lunaconf = require('lunaconf')

local function set_position(c)
	local workarea = c.screen.workarea
	c:geometry(workarea)
end

-- Scale window to workspace size (min 15% height)
client.connect_signal("manage", function(c, startup)
	if c.class == "Tilda" then
		c.screen = lunaconf.screens.primary()

		-- Disable shadow for tilda clients
		c:set_xproperty("_COMPTON_NO_SHADOW", true)

		-- Set property of tilda whenever it changes (prevent its own scaling mechanism)
		c:connect_signal('property::geometry', set_position)
		-- Fix geometry when the screen of tilda changes
		c:connect_signal('property::screen', set_position)
		set_position(c)
	end
end)

awful.rules.rules = gears.table.join(awful.rules.rules, {
	{
		rule = { class = "Tilda" },
		properties = { floating = true, border_width = 0, opacity = 0.9 }
	}
})
