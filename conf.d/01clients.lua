local awful = require("awful")

local move_client = function(c, direction)
	local new_screen = ((c.screen - 1 + direction) % screen.count()) + 1
	local new_tag = default_tag_for_screen(new_screen)
	awful.client.movetotag(new_tag, c)
end

-- Define buttons for every client
buttons = awful.util.table.join(
	awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
	awful.button({ MOD }, 1, function(c)
		client.focus = c
		c:raise()
		awful.mouse.client.move(c)
	end),
	awful.button({ MOD }, 2, function(c) c:kill() end),
	awful.button({ MOD }, 3, awful.mouse.client.resize)
)

-- Define keys for every client
-- Keys depending on direct tag access (Mod + .. + Number) are
-- defined in the tags configuration file
keys = awful.util.table.join(
	-- close client
	awful.key({ MOD }, "q", function(c) c:kill() end),
	awful.key({ "Mod1" }, "F4", function(c) c:kill() end),

	-- move client to other screen/tag
	awful.key({ MOD }, "Right", function(c) move_client(c, 1) end),
	awful.key({ MOD }, "Left", function(c) move_client(c, -1) end),

	-- toggle client floating state
	awful.key({ MOD }, "Return", function(c) awful.client.floating.toggle(c) end)
)

awful.rules.rules = {
	{
		rule = { },
		properties = {
			focus = awful.client.focus.filter,
			buttons = buttons,
			keys = keys,
			floating = false,
			focus = true
		}
	},{
		rule = { },
		except = { type = "normal" },
		properties = {
			floating = true,
		}
	},{
		rule = { type = "dialog" },
		callback = function(c)
			awful.placement.centered(c,nil)
		end
	}
}

-- Raise client when focused
client.connect_signal("focus", function(c)
	c:raise()
end)

-- Focus and raise window when created
client.connect_signal("manage", function(c, startup)
	client.focus = c
	c:raise()
end)
