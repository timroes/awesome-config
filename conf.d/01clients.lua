local awful = require("awful")

local move_client = function(c, direction)
	local cur_tag = awful.tag.selected(c.screen)

	-- Only allow window move for windows on not named tags
	if #cur_tag.name <= 1 then
		local new_screen = ((c.screen - 1 + direction) % screen.count()) + 1
		local new_tag = default_tag_for_screen(new_screen)
		awful.client.movetotag(new_tag, c)
	end
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
	awful.key({ MOD }, "Return", function(c) awful.client.floating.toggle(c) end),
	-- toggle client always on top
	awful.key({ MOD }, "t", function(c) c.ontop = not c.ontop end)
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

	if c.size_hints then
		local sh = c.size_hints
		local wa = screen[c.screen].workarea
		if sh.user_size and sh.user_size.width ~= wa.width and sh.user_size.height ~= wa.height then
			-- If the user size hint is set, make the window floating and give it the specific size
			-- unless the size matches exactly the size of the workarea, in this case leave it fullscreen.
			awful.client.floating.set(c, true)
			c:geometry(sh.user_size)
			awful.placement.centered(c, nil)
		elseif sh.max_height and sh.max_width and sh.max_height == sh.min_height and sh.min_width == sh.max_width then
			-- Check if the client has a program set minimum and maximum size, that are equal
			-- If so, treat this client as a dialog window (center it and make it floating)
			awful.client.floating.set(c, true)
			awful.placement.centered(c, nil)
		end
	end
end)
