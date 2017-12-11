local lunaconf = require('lunaconf')
local awful = require('awful')
local gears = require('gears')

local run_compton = function()
	lunaconf.utils.run_once('compton --config ' .. gears.filesystem.get_configuration_dir() .. '/configs/compton.conf -b')
end

local restart_compton = function()
	lunaconf.utils.spawn('killall compton')
	run_compton()
end

-- Register the _COMPTON_NO_SHADOW property even if disabled, so we don't need
-- to check in other files whether we can use it
awesome.register_xproperty('_COMPTON_NO_SHADOW', 'boolean')

if not lunaconf.config.get('disable_compositor', false) then
	local function set_shadow_hint(c)
		c:set_xproperty("_COMPTON_NO_SHADOW", not c.floating)
	end

	-- Shadow handling of compton
	-- Disable shadows (set _COMPTON_NO_SHADOW xproperty) on all non floating windows
	-- and windows with a shape so they won't leave ugly shadows on the screen bar(s).
	client.connect_signal('manage', function(c, startup)
		set_shadow_hint(c)
		c:connect_signal('property::floating', set_shadow_hint)
	end)

	lunaconf.utils.only_if_command_exists('compton', function()
		-- Due to a bug in compton we need to kill and restart it if the screen
		-- configuration changes, since otherwise some screens might stay blank
		screen.connect_signal('list', restart_compton)
		screen.connect_signal('property::geometry', restart_compton)

		if not awesome.composite_manager_running then
			run_compton()
		end
	end)
end
