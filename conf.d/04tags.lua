local awful = require("awful")

tags = {}
tag_keys = root.keys()

for s = 1, screen.count() do
	-- Get name for screen tag (horizontal position of screen)
	local tagname = screen_position(s)
	-- Create tag for that name and select it
	local tag = awful.tag.add(tagname, { screen = s, layout = awful.layout.suit.max })
	tag.selected = true

	-- Switch to tag
	local tagFocus = function() 
		if client.focus and client.focus.screen == s and awful.tag.selected(s) == tag then
			-- If screen is already focused switch to next client
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		else
			awful.tag.viewmore({ tag }, s) 
			-- Focus last focused client on this tag
			local focus = awful.client.focus.history.get(s, 0)
			if focus then client.focus = focus end
		end
	end
	-- Move to tag
	local moveToTag = function() 
		if not client.focus then return end
		awful.client.movetotag(tag, client.focus)
	end

	-- Assign key shortcuts for every tag
	tag_keys = awful.util.table.join(tag_keys, 
		-- Switch to tag
		awful.key({ MOD }, "#" .. tagname + 9, tagFocus), -- Numbers
		awful.key({ MOD }, "#" .. tagname + 86, tagFocus), -- Numpad keys
		-- Move client to tag
		awful.key({ MOD, "Control" }, "#" .. tagname + 9, moveToTag),
		awful.key({ MOD, "Control" }, "#" .. tagname + 86, moveToTag)
	)
end

root.keys(tag_keys)
