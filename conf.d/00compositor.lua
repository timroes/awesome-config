local lunaconf = require('lunaconf')
local awful = require('awful')
local gears = require('gears')

if not lunaconf.config.get('disable_compositor', false) then
	local function set_shadow_hint(c)
		local no_shadow
		if c.floating then
			no_shadow = 0
		else
			no_shadow = 1
		end
		c:set_xproperty("_COMPTON_NO_SHADOW", no_shadow)
	end

	-- Shadow handling of compton
	-- Disable shadows (set _COMPTON_NO_SHADOW xproperty) on all non floating windows
	-- so they won't leave ugly shadows on the screen bar(s).
	awesome.register_xproperty("_COMPTON_NO_SHADOW", "number")
	client.connect_signal("manage", function(c, startup)
		set_shadow_hint(c)
		c:connect_signal("property::floating", set_shadow_hint)
	end)

	if not awesome.composite_manager_running then
		lunaconf.utils.run_once('compton --config ' .. gears.filesystem.get_configuration_dir() .. '/compton.conf -b')
	end
end
