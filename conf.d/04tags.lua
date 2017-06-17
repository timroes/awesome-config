local awful = require('awful')
local lunaconf = require('lunaconf')

-- All keys in this list serve as tag keys and can be used to attach clients
-- to and activate the appropriate tag. For each letter here the MOD + letter
-- and MOD + Shift + letter hotkey must be free.
local tag_keys = {'x', 'c', 'v', 'b', 'n', 'm'}

local layouts = {
	awful.layout.suit.max,
	awful.layout.suit.tile.right
}

local screens_in_order = {}

-- Create the primary tag on each screen
awful.screen.connect_for_each_screen(function(s)
	-- Create the new primary tag for this screen (leave it's name empty yet)
	-- since the screen.list signal will take care renaming it in a moment
	local tag = awful.tag.add('-', {
		screen = s, -- Set the screen to the current
		layout = layouts[1], -- Set its layout to the default layout
		is_primary = true, -- Add a custom flag to mark it as the primary for this screen
		selected = true
	})
	-- Attach the tag as the primary tag to the given screen
	s.primary_tag = tag
end)

--- Iterate over all screens and give their primary tag the name of their screen
--- position. Also save this renamed order in screens_in_order, which will be
--- used to lookup the screens in hotkeys.
local function rename_screen_tags()
	screens_in_order = {}
	lunaconf.screens.iterate_in_order(function(pos, s)
		screens_in_order[pos] = s
		s.primary_tag.name = tostring(pos)
	end)
end

-- Rename screen tags if screen list changes or if the geometry of a screen changes
screen.connect_signal('list', rename_screen_tags)
screen.connect_signal('property::geometry', rename_screen_tags)
rename_screen_tags()

local function focus_tag(screen_position)
	local s = screens_in_order[screen_position]
	-- Ignore key presses if there is no screen with that position
	if s then
		if client.focus and client.focus.screen == s and s.selected_tag == s.primary_tag then
			-- If screen is already focused switch to next client
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		else
			if not s.primary_tag.selected then
				awful.tag.viewmore({ s.primary_tag }, s)
			end
			-- Focus last focused client on this tag
			local focus = awful.client.focus.history.get(s, 0)
			if focus then client.focus = focus end
		end
	end
end

-- Add hotkeys to navigate to screens between 1 and 9
for i = 1, 9 do
	local key = awful.key({ lunaconf.config.MOD }, '#' .. i + 9, function()
		focus_tag(i)
	end)
	lunaconf.keys.globals(key)
end

--- This method will move the currently focused client to the tag with the specified
--- name. If there isn't a tag with that name yet, it will create it and show it.
local function move_to_tag(tagname)
	local c = client.focus

	if c then
		-- Only do if a client has the focus
		local t = awful.tag.find_by_name(c.screen, tagname)
		if not t then
			-- If tag doesn't exist on that screen yet, create a volatile tag for that name
			t = awful.tag.add(tagname, {
				screen = c.screen,
				layout = layouts[1],
				volatile = true, -- delete the tag if the last client is removed from it
				selected = true -- immediately show that tag
			})
		end

		-- If client is already on tag move it back to primary tag of its screen
		-- otherwise move it to the tag
		if c.first_tag == t then
			c:move_to_tag(c.screen.primary_tag)
		else
			c:move_to_tag(t)
		end
	end
end

local function toggle_tag(tagname)
	-- TODO: Toggle on all screens
	local t = awful.tag.find_by_name(client.focus.screen, tagname)
	if t then
		t.selected = not t.selected
	end
end

for _, letter in ipairs(tag_keys) do
	local move_hotkey = awful.key({ lunaconf.config.MOD, 'Control' }, letter, function()
		move_to_tag(letter)
	end)
	local toggle_tag_hotkey = awful.key({ lunaconf.config.MOD }, letter, function()
		toggle_tag(letter)
	end)
	lunaconf.keys.globals(move_hotkey, toggle_tag_hotkey)
end

	-- Switch layouts for the current screen
local switch_layout = awful.key({ lunaconf.config.MOD }, "s", function()
	-- Only allow split screen on screen tags
	local cur_tag = client.focus.screen.selected_tag
	if cur_tag.is_primary then
		awful.layout.inc(layouts, 1, client.focus.screen)
	end
end)

lunaconf.keys.globals(switch_layout)
