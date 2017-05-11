-- This configuration handles urgent clients (clients with demands_attention hint).

local awful = require('awful')
local lunaconf = require('lunaconf')

local function jump_to_urgent()
	local next_urgent = awful.client.urgent.get()
	if next_urgent then
		client.focus = next_urgent
		next_urgent:raise()
	end
end

-- On MOD + backslash jump to next window that has the urgent hint set
lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, '\\', jump_to_urgent)
)
