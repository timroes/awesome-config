local awful = require("awful")
local lunaconf = require("lunaconf")
local gears = require('gears')

local MOD = lunaconf.config.MOD

--- Toggle ontop state of a client.
-- This is only allowed for floating clients, since only these can be "above"
-- another client and should stay there.
local function toggle_ontop(c)
	if c.floating then
		c.ontop = not c.ontop
	end
end

-- When a client isn't floating anymore switch its ontop property to false (see above).
client.connect_signal('property::floating', function(c)
	if not c.floating then
		c.ontop = false
	end
end)

-- Define buttons for every client
buttons = gears.table.join(
	awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
	awful.button({ MOD }, 1, function(c)
		lunaconf.clients.smart_move(c)
	end),
	awful.button({ MOD }, 2, function(c) c:kill() end),
	awful.button({ MOD }, 3, function(c)
		-- Resizing of clients on modifier + right mouse button
		if gears.string.startswith(awful.layout.get(c.screen).name, "tile") then
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
			if not c.unresizeable then
				c.floating = true
				client.focus = c
				awful.mouse.client.resize(c)
			end
		end
	end)
)

-- Define keys for every client
-- Keys depending on direct tag access (Mod + .. + Number) are
-- defined in the tags configuration file
keys = gears.table.join(
	-- close client
	awful.key({ MOD }, "q", function(c) c:kill() end),
	awful.key({ "Mod1" }, "F4", function(c) c:kill() end),

	-- swap clients into direction (only works in split mode (see tags.lua))
	awful.key({ MOD, "Control" }, "Right", function(c) awful.client.swap.bydirection("right") end),
	awful.key({ MOD, "Control" }, "Left", function(c) awful.client.swap.bydirection("left") end),
	awful.key({ MOD, "Control" }, "Down", function(c) awful.client.swap.bydirection("down") end),
	awful.key({ MOD, "Control" }, "Up", function(c) awful.client.swap.bydirection("up") end),

	-- toggle client floating state
	awful.key({ MOD }, "Return", function(c)
		if not c.unresizeable then
			awful.client.floating.toggle(c)
		end
	end),
	-- toggle client always on top
	awful.key({ MOD }, "t", toggle_ontop),
	awful.key({ MOD }, "f", function(c) c.fullscreen = not c.fullscreen end)
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
	},
	{
		rule_any = { type = { 'dialog' }, role = { 'pop-up' } },
		properties = {
			callback = function (c)
				local wa = screen[c.screen].workarea
				-- If a popup or dialog has the exact same size then the workarea its in
				-- don't make it floating, otherwise make it floating
				if c.width == wa.width and c.height == wa.height and c.x == wa.x and c.y == wa.y then
					c.floating = false
				else
					c.floating = true
					awful.placement.centered(c)
				end
			end
		}
	}
}

-- Raise client when focused
client.connect_signal("focus", function(c)
	c:raise()
end)

-- Focus and raise window when created
client.connect_signal("manage", function(c, startup)

	-- Special behavior for chromium browser, so you can pull out tabs easily
	if c.class == 'Chromium' then
		local under_mouse = awful.mouse.client_under_pointer()
		-- If the new window is a chromium browser and the window currently under
		-- the mouse cursor is from the same process it is likely we just pulled
		-- out a tab, so make it floating, so chromium can control its position
		-- while we drag it to its final position
		if under_mouse and under_mouse.pid == c.pid then
			c.floating = true
		end
	end

	client.focus = c
	c:raise()

	-- Do not use the maximized feature, since we let maximized windows handle by the layout
	c.maximized_vertical = false
	c.maximized_horizontal = false

	if c.size_hints then
		local sh = c.size_hints
		local wa = screen[c.screen].workarea
		if sh.user_size and sh.user_size.width ~= wa.width and sh.user_size.height ~= wa.height then
			-- If the user size hint is set, make the window floating and give it the specific size
			-- unless the size matches exactly the size of the workarea, in this case leave it fullscreen.
			c.floating = true
			c:geometry(sh.user_size)
			awful.placement.centered(c, nil)
		elseif sh.max_height and sh.max_width and sh.max_height == sh.min_height and sh.min_width == sh.max_width then
			-- Check if the client has a program set minimum and maximum size, that are equal
			-- If so, treat this client as a dialog window (center it and make it floating)
			-- Also make it unresizeable (also meaning it cannot be unfloated)
			c.unresizeable = true
			c.floating = true
			awful.placement.centered(c, nil)
		end
	end
end)
