local awful = require('awful')
local gears = require('gears')
local lunaconf = require('lunaconf')
local inspect = require('inspect')

-- All keys in this list serve as tag keys and can be used to attach clients
-- to and activate the appropriate tag. For each letter here the MOD + letter
-- and MOD + Shift + letter hotkey must be free.
local tag_keys = {'x', 'c', 'v', 'b', 'n', 'm'}

local layouts = {
	awful.layout.suit.max,
	awful.layout.suit.tile.right
}

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
	lunaconf.screens.iterate_in_order(function(pos, s)
		s.primary_tag.name = tostring(pos)
	end)
end

-- Rename screen tags if screen list changes or if the geometry of a screen changes
screen.connect_signal('list', rename_screen_tags)
screen.connect_signal('property::geometry', rename_screen_tags)
rename_screen_tags()

--- This method will move the currently focused client to the tag with the specified
--- name. If there isn't a tag with that name yet, it will create it and show it.
-- Optionally specify a screen onto which the tag should be created and the client
-- moved to. If not specified, use the same screen, that the client is currently on.
local function move_to_tag(tagname, screen)
	local c = client.focus

	if c then
		-- Only do if a client has the focus
		local s = screen or c.screen
		local t = awful.tag.find_by_name(s, tagname)
		if not t then
			-- If tag doesn't exist on that screen yet, create a volatile tag for that name
			t = awful.tag.add(tagname, {
				screen = s,
				layout = layouts[1],
				volatile = true, -- delete the tag if the last client is removed from it
				selected = true -- immediately show that tag
			})
		end

		-- If client is already on tag move it back to primary tag of its screen
		-- otherwise move it to the tag
		if c.first_tag == t then
			c:move_to_tag(s.primary_tag)
		else
			c:move_to_tag(t)
		end
		client.focus = c
	end
end

--- Moves the currently focused client in a specific direction.
--- If the client is on a tag it will create that tag if necessary on the new
--- screen.
local function move_in_direction(direction)
	local c = client.focus
	if c then
		local new_screen = c.screen:get_next_in_direction(direction)
		if new_screen then
			-- Determine whether we need to move to primary tag or the same named tag
			if c.first_tag.is_primary then
				c:move_to_tag(new_screen.primary_tag)
				client.focus = c
			else
				move_to_tag(c.first_tag.name, new_screen)
			end
		end
	end
end

--- Returns the list of visible tags on the current focused screen. It will
--- also return the index of the currently focused tag within that list.
local function visible_tags()
	if not client.focus then
		return nil
	end

	local tags = {}
	local index = 0, current_focused_index
	for i,t in ipairs(client.focus.screen.tags) do
		if t.selected then
			table.insert(tags, t)
			index = index + 1
			if client.focus.first_tag == t then
				current_focused_index = index
			end
		end
	end
	return tags, current_focused_index
end

--- Focuses the "next" client. That is the next client on the currently
--- active tag on the screen that client.focus is on.
local function focus_next(previous)
	if not client.focus then
		return
	end

	local s = client.focus.screen
	local cur_tag = client.focus.first_tag
	local clients = client.get(s)

	-- Sort all clients by their tag, so we have a table that has as a key the tag
	-- and as a value an array of all clients on this tag (in the order they also
	-- appear in the tasklist)
	local clients_per_tag = {}
	local index = 0, current_focused_index
	for i,c in ipairs(clients) do
		-- Exclude all clients, that shouldn't get the focus
		if not c.hidden and not c.minimized then
			-- Create the list for that tag if it doesn't exist
			if not clients_per_tag[c.first_tag] then
				clients_per_tag[c.first_tag] = {}
			end
			-- Insert the client for that tag in the list
			table.insert(clients_per_tag[c.first_tag], c)
			-- We only want to count index for the current tag, since we use it
			-- to determin the index of the currently focused client
			if c.first_tag == cur_tag then
				index = index + 1
			end
			if c == client.focus then
				current_focused_index = index
			end
		end
	end

	local new_index = current_focused_index + (previous and -1 or 1)

	if new_index < 1 or new_index > #clients_per_tag[cur_tag] then
		-- If index is outside current clients list, jump to next/previous tag
		local previous_tag = new_index < 1
		local tags, cur_tag_index = visible_tags()
		local offset = 0
		-- Try to find a tag, that actually has a focusable client on it
		-- Cycle through all tags, until an index has been found, where the clients_per_tag
		-- list isn't nil (i.e. has focusable clients)
		local new_tag_clients
		repeat
			offset = offset + (previous_tag and -1 or 1)
			new_tag_index = gears.math.cycle(#tags, cur_tag_index + offset)
			new_tag_clients = clients_per_tag[tags[new_tag_index]]
		until new_tag_clients
		client.focus = new_tag_clients[previous and #new_tag_clients or 1]
	else
		client.focus = clients_per_tag[cur_tag][new_index]
	end
end

--- Find a given tagname on all screens and return a table with the screen as
--- a key and the tag as a value. It also returns as a second parameter one
--- of the found tags by random.
local function find_all_by_name(tagname)
	local tag_per_screen = {}, t, random_tag
	for s in screen do
		t = awful.tag.find_by_name(s, tagname)
		if t then
			tag_per_screen[s] = t
			random_tag = t
		end
	end
	return tag_per_screen, random_tag
end

local function toggle_tag(tagname)
	local focused_before = client.focus

	-- Collect all tags by their
	local tags, random_tag = find_all_by_name(tagname)
	if not random_tag then
		-- If no tags with that name exists exit
		return
	end

	if random_tag.selected then
		-- If the current focused client is not on this tag, focus a client of the tag
		-- otherwise (if the current focused client is on the tag) hide the tag
		if client.focus and client.focus.first_tag.name ~= tagname then
			local tag_to_focus = tags[client.focus.screen] and tags[client.focus.screen] or random_tag
			client.focus = tag_to_focus:clients()[1]
		else
			-- Unselect all tags
			for screen, tag in pairs(tags) do
				tag.selected = false
			end

			-- If we had a focused client before and now don't it was on a tag that got
			-- hidden, so select another client on that screen it was on from history.
			if not client.focus and focused_before then
				client.focus = awful.client.focus.history.get(focused_before.screen, 0)
			end
		end
	else
		-- Select all found tags
		for screen, tag in pairs(tags) do
			tag.selected = true
			local client_on_tag = tag:clients()[1]
			client.focus = client_on_tag
		end

		if focused_before and tags[focused_before.screen] then
			client.focus = awful.client.focus.history.get(focused_before.screen, 0)
		end
	end
end

local function focus_fallback(oldfocus)
	if not client.focus then
		local fallback = awful.client.focus.history.get(oldfocus.screen, 0)
		if fallback then
			client.focus = fallback
		end
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

local function focus_screen(screen_position)
	local t = awful.tag.find_by_name(nil, tostring(screen_position))
	-- Ignore key presses if there is no screen tag with that name
	if t then
		if client.focus and client.focus.screen == t.screen then
			-- If the currently focused client is on the same screen as the tag,
			-- focus the next client on that screen.
			focus_next()
			if client.focus then client.focus:raise() end
		else
			-- Focus last focused client on this screen (which also might be on a different)
			-- tag than the primary one.
			local focus = awful.client.focus.history.get(t.screen, 0)
			if focus then client.focus = focus end
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

	-- Switch layouts for the current screen
local switch_layout = awful.key({ lunaconf.config.MOD }, "s", function()
	-- Only allow split screen on screen tags
	local cur_tag = client.focus.screen.selected_tag
	if cur_tag.is_primary then
		awful.layout.inc(layouts, 1, client.focus.screen)
	end
end)

lunaconf.keys.globals(switch_layout,
	-- move client to other screen
	awful.key({ lunaconf.config.MOD }, "Right", function() move_in_direction('right') end),
	awful.key({ lunaconf.config.MOD }, "Left", function() move_in_direction('left') end),
	awful.key({ lunaconf.config.MOD }, "Down", function() move_in_direction('down') end),
	awful.key({ lunaconf.config.MOD }, "Up", function() move_in_direction('up') end),
	awful.key({ lunaconf.config.MOD }, "Page_Up", function() focus_next(true) end),
	awful.key({ lunaconf.config.MOD }, "Page_Down", function() focus_next(false) end)
)

client.connect_signal('focus', function(c)
	-- If a client is focused, whose tag is not selected, activate the tag (on all screens)
	if not c.first_tag.selected then
		toggle_tag(c.first_tag.name)
	end
end)

client.connect_signal('manage', function(c)
		-- Don't add newly created clients to all currently visible tags, only to the
		-- primary tag of the screen they are created on.
		c:tags({ c.screen.primary_tag })
end)

-- Whenever a client is unmanaged or possibliy loses focus otherwise, make sure
-- another client will receive the focus.
client.connect_signal('unmanage', focus_fallback)
client.connect_signal('untagged', focus_fallback)
client.connect_signal('property::minimized', focus_fallback)
client.connect_signal('property::hidden', focus_fallback)
