local awful = require("awful")

local move_client = function(c, direction)
	-- If client is unmoveable don't do anything
	if awful.client.property.get(c, "client::unmoveable") then
		return
	end

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
		-- Only start moving client, when it's not unmoveable
		if not awful.client.property.get(c, "client::unmoveable") then
			awful.client.floating.set(c, true)
			awful.mouse.client.move(c)
		end
	end),
	awful.button({ MOD }, 2, function(c) c:kill() end),
	awful.button({ MOD }, 3, function(c)
		-- Resizing of clients on modifier + right mouse button
		if string.starts(awful.layout.get(c.screen).name, "tile") then
			-- If client on a split screen is tried to rescale we modify the split factor instead
			mousegrabber.run(function(ev)
				local s = screen[c.screen] -- current screen
				local mouse_on_screen = ev.x - s.geometry.x -- mouse coordinate on screen
				if mouse_on_screen >= 0 and mouse_on_screen <= s.geometry.width then
					-- Calculate on which percentage of the screen we are
					-- and set the split factor of the tag to that value
					-- but only if we are not ouside of the current screen
					local mouseper_on_screen = (mouse_on_screen / s.geometry.width)
					awful.tag.setmwfact(mouseper_on_screen)
				end
				-- Continue while mouse button is pressed
				return ev.buttons[3]
			end, "sb_h_double_arrow")
		else
			-- On any non tiling screen we make the client floating and start resize mode
			awful.client.floating.set(c, true)
			awful.mouse.client.resize(c)
		end
	end)
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

	-- swap clients into direction (only works in split mode (see tags.lua))
	awful.key({ MOD, "Control" }, "Right", function(c) awful.client.swap.bydirection("right") end),
	awful.key({ MOD, "Control" }, "Left", function(c) awful.client.swap.bydirection("left") end),
	awful.key({ MOD, "Control" }, "Down", function(c) awful.client.swap.bydirection("down") end),
	awful.key({ MOD, "Control" }, "Up", function(c) awful.client.swap.bydirection("up") end),

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
