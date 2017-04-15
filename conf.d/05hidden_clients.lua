-- Allow to hide clients by pressing MOD + H.
-- This will move the clients to an invisible tag.
local lunaconf = require('lunaconf')
local awful = require('awful')

local hidden_tag = awful.tag.add("hidden_clients", {
  activated = false -- Set tag is inactive so it won't show up in tag lists
})

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

-- Set shortcut to MOD + H
lunaconf.keys.globals(
  awful.key({ lunaconf.config.MOD }, 'h', hide_client),
  awful.key({ lunaconf.config.MOD, 'Shift' }, 'h', unhide_all_clients)
)
