-- Allow to hide clients by pressing MOD + H.
-- This will move the clients to an invisible tag.
local lunaconf = require('lunaconf')
local awful = require('awful')
local wibox = require('wibox')

-- The actual tag object which is used to hide clients
local hidden_tag = awful.tag.add("Hidden Clients", {
	invisible = true -- Mark the tag as invisible (custom flag) that will be filtered for in the tag list
})

local hidden_count_textbox = nil

-- Hide the currently focused client.
local function hide_client()
	if not client.focus then return end
	client.focus:move_to_tag(hidden_tag)
end

-- Show all previously hidden clients, by moving them back to the default tag
-- for the screen they are on.
local function unhide_all_clients()
	local hidden_clients = hidden_tag:clients()
	for i, client in ipairs(hidden_clients) do
		client:move_to_tag(lunaconf.tags.default_tag_for_screen(client.screen))
	end
end

local function create_infolay()

	local function refresh_counter()
		hidden_count_textbox.text = tostring(#hidden_tag:clients())
	end

	-- Refresh the amount of hidden clients each time a new client is tagged
	hidden_tag:connect_signal('tagged', refresh_counter)
	hidden_tag:connect_signal('untagged', refresh_counter)

	hidden_count_textbox = wibox.widget.textbox('0')
	local icon = wibox.widget.imagebox(awful.util.get_configuration_dir() .. '/icons/hidden.svg', true)
	local layout = wibox.layout.fixed.horizontal(icon, hidden_count_textbox)
	layout.spacing = 10

	lunaconf.infolay.add(layout, awful.placement.bottom_right)
end

create_infolay()

-- Set shortcut to MOD + H
lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, 'h', hide_client),
	awful.key({ lunaconf.config.MOD, 'Shift' }, 'h', unhide_all_clients)
)
