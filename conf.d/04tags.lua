local awful = require("awful")

local screen_order = {}

-- Sort screens by their x coordinates
-- and store them in screen_order
table.insert(screen_order, screen[1])
for s = 2, screen.count() do
	local inserted = false
	for i,sc in pairs(screen_order) do
		if screen[s].geometry.x < sc.geometry.x then
			table.insert(screen_order, i, screen[s])
			inserted = true
			break
		end
	end
	if not inserted then
		table.insert(screen_order, screen[s])
	end
end

-- Returns the x-coordinate sorted position of the screen
-- by its screen index
local screen_name = function(index)
	for i,s in pairs(screen_order) do
		if s.index == index then
			return i
		end
	end
end

tags = {}
tag_keys = root.keys()

for s = 1, screen.count() do
	-- Get name for screen tag (horizontal position of screen)
	local tagname = screen_name(s)
	-- Create tag for that name and select it
	local tag = awful.tag.add(tagname, { screen = s, layout = awful.layout.suit.max })
	tag.selected = true

	-- Switch to tag
	local tagFocus = function() 
		awful.tag.viewmore({ tag }, s) 
		-- Focus last focused client on this tag
		local focus = awful.client.focus.history.get(s, 0)
		if focus then client.focus = focus end
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
		-- Move screen to tag
		awful.key({ MOD, "Control" }, "#" .. tagname + 9, moveToTag),
		awful.key({ MOD, "Control" }, "#" .. tagname + 86, moveToTag)
	)
end

root.keys(tag_keys)
