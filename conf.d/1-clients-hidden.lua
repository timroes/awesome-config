-- Allow to hide clients by pressing MOD + H.
-- This will move the clients to an invisible tag.
local lunaconf = require('lunaconf')
local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')

-- The actual tag object which is used to hide clients
local hidden_tag = awful.tag.add("Hidden Clients", {
	invisible = true -- Mark the tag as invisible (custom flag) that will be filtered for in the tag list
})

-- Hide the currently focused client.
local function hide_client()
	if not client.focus then return end
	client.focus.screen_before_hiding = client.focus.screen
	client.focus:move_to_tag(hidden_tag)
end

-- Show all previously hidden clients, by moving them back to the default tag
-- for the screen they are on.
local function unhide_all_clients()
	local hidden_clients = hidden_tag:clients()
	for i, client in ipairs(hidden_clients) do
		if client.screen_before_hiding and client.screen_before_hiding.valid then
			client:move_to_tag(client.screen_before_hiding.primary_tag)
		else
			client:move_to_tag(lunaconf.screens.primary().primary_tag)
		end
	end
end

-- Set shortcut to MOD + H
lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, 'h', hide_client),
	awful.key({ lunaconf.config.MOD, 'Shift' }, 'h', unhide_all_clients)
)
