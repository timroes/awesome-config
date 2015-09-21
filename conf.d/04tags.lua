local awful = require("awful")
local config = require("lunaconf.config")

local layouts = {
	awful.layout.suit.max,
	awful.layout.suit.tile.right
}

tags = {}
tag_keys = root.keys()

for s = 1, screen.count() do
	-- Get name for screen tag (horizontal position of screen)
	local tagname = screen_position(s)
	-- Create tag for that name and select it
	local tag = awful.tag.add(tagname, { screen = s, layout = layouts[1], screen_tag = true })
	tag.selected = true

	-- Switch to tag
	local tagFocus = function() 
		if client.focus and client.focus.screen == s and awful.tag.selected(s) == tag then
			-- If screen is already focused switch to next client
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		else
			if not tag.selected then
				awful.tag.viewmore({ tag }, s) 
			end
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
		awful.key({ config.MOD }, "#" .. tagname + 9, tagFocus), -- Numbers
		awful.key({ config.MOD }, "#" .. tagname + 86, tagFocus), -- Numpad keys
		-- Move client to tag
		awful.key({ config.MOD, "Control" }, "#" .. tagname + 9, moveToTag),
		awful.key({ config.MOD, "Control" }, "#" .. tagname + 86, moveToTag)
	)
end

tag_keys = awful.util.table.join(tag_keys,
	-- Switch layouts for the current screen
	awful.key({ config.MOD }, "s", function()
		-- Only allow split screen on regular (screen) tags
		local cur_tag = awful.tag.selected(client.focus.screen)
		if #cur_tag.name <= 1 then
			awful.layout.inc(layouts, 1, client.focus.screen)
		end
	end)
)

root.keys(tag_keys)
