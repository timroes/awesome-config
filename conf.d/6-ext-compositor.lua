local lunaconf = require('lunaconf')
local awful = require('awful')
local gears = require('gears')

local run_picom = function()
	lunaconf.utils.run_once('picom --config ' .. gears.filesystem.get_configuration_dir() .. '/configs/picom.conf -b')
end

local restart_picom = function()
	lunaconf.utils.spawn('killall picom')
	run_picom()
end

-- Register the _PICOM_NO_SHADOW property even if disabled, so we don't need
-- to check in other files whether we can use it
awesome.register_xproperty('_PICOM_NO_SHADOW', 'boolean')

function awful.client.object.set_disable_shadow(c, value)
	c:set_xproperty('_PICOM_NO_SHADOW', value)
end

if not lunaconf.config.get('disable_compositor', false) then
	local function set_shadow_hint(c)
		c.disable_shadow = not c.floating
	end

	-- Shadow handling of picom
	-- Disable shadows (set _PICOM_NO_SHADOW xproperty) on all non floating windows
	-- and windows with a shape so they won't leave ugly shadows on the screen bar(s).
	client.connect_signal('manage', function(c, startup)
		set_shadow_hint(c)
		c:connect_signal('property::floating', set_shadow_hint)
	end)

	lunaconf.utils.only_if_command_exists('picom', function()
		-- Due to a bug in picom we need to kill and restart it if the screen
		-- configuration changes, since otherwise some screens might stay blank
		screen.connect_signal('list', restart_picom)
		screen.connect_signal('property::geometry', restart_picom)

		if not awesome.composite_manager_running then
			run_picom()
		end
	end)
end
