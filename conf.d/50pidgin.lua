local awful = require("awful")
local lunaconf = require('lunaconf')
local PIDGIN_SCREEN = lunaconf.screens.primary_index()
local config = require("lunaconf.config")
local icons = require("lunaconf.icons")

-- Create own tag for pidgin
local pidgin_tag = awful.tag.add("Pidgin", { hotkey = "p" })
pidgin_tag.icon = icons.lookup_icon('internet-chat')
-- awful.tag.seticon("/usr/share/icons/hicolor/48x48/apps/pidgin.png", pidgin_tag)
pidgin_tag.screen = PIDGIN_SCREEN
-- Limit tag to pidgin's windows
limit_tag(pidgin_tag, { class = "Pidgin" })
-- start pidgin on this tag
start_on_tag(pidgin_tag, "pidgin")

-- Set layout to tiling mode on pidgin tab
awful.layout.set(awful.layout.suit.tile.right, pidgin_tag)
pidgin_tag.master_width_factor = 0.2

-- Store tags that has been activated when switching to pidgin tag
local tags_before = nil

-- Try to focus the best window in the pidgin tag.
-- this will try to focus a message window if available
-- and the buddy list otherwise
local focus_window = function()
	local clients = pidgin_tag:clients()
	for i,c in pairs(clients) do
		if client.focus == nil or client.focus.class ~= "Pidgin" then
			-- If no pidgin client is focused yet, focus one
			client.focus = c
		else
			-- if a pidgin client is already focused only focus
			-- message windows
			if client.focus.role == "buddy_list" then
				client.focus = c
			end
		end
	end
end

local buddy_list_left = function()
	local clients = pidgin_tag:clients()
	for i,c in pairs(clients) do
		if c.role == "buddy_list" then
			awful.client.swap.bydirection("left", c)
		end
	end
end

client.connect_signal("manage", function(c, startup)
	if c.class == "Pidgin" then
		buddy_list_left()
	end
end)

pidgin_tag:connect_signal("property::selected", function(t)
	if t.selected then
		-- If we switch to tag, pull the buddy list to the left side again
		buddy_list_left()
		focus_window()
	else
		tags_before = nil
	end
end)

-- Shortcut to switch to pidgin tag
keys = awful.util.table.join(root.keys(),
	awful.key({ config.MOD }, "p", function()
		if pidgin_tag.selected then
			if not client.focus or client.focus.class ~= "Pidgin" then
				-- If we press the shortcut while the tag is open, but not focues,
				-- focus the tag instead of hiding it
				focus_window()
			else
				-- switch back to previous tags if available
				if tags_before then
					awful.tag.viewmore(tags_before, PIDGIN_SCREEN)
				else
					-- Switch to main tag of this screen if no previous tags has been saved
					local first_tag = default_tag_for_screen(PIDGIN_SCREEN)
					awful.tag.viewmore({ first_tag }, PIDGIN_SCREEN)
				end
			end
		else
			-- save previous tags and switch to pidgin tag
			tags_before = awful.tag.selectedlist(PIDGIN_SCREEN)
			awful.tag.viewmore({ pidgin_tag }, PIDGIN_SCREEN)
		end
	end)
)

root.keys(keys)

-- Rules to place pidgin always on pidgin tag and make buddy list not floating
awful.rules.rules = awful.util.table.join(awful.rules.rules, {
	{
		rule = { class = "Pidgin" },
		properties = {
			tag = pidgin_tag,
			maximized_vertical = false,
			maximized_horizontal = false
		}
	},{
		rule = { class = "Pidgin", role = "buddy_list" },
		properties = {
			floating = false
		}
	}
})
