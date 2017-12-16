-- This configuration allows switching between previously focused clients
local awful = require('awful')
local lunaconf = require('lunaconf')

-- On MOD + backslash jump to previously focused client
lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, '\\', function() awful.client.focus.history.previous() end)
)
