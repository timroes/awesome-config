local lunaconf = require('lunaconf')
local awful = require('awful')

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
	awesome.register_xproperty("_COMPTON_NO_SHADOW", "number")
	client.connect_signal("manage", function(c, startup)
		set_shadow_hint(c)
		c:connect_signal("property::floating", set_shadow_hint)
	end)

	if not awesome.composite_manager_running then
		lunaconf.utils.run_once('compton --config ' .. awful.util.get_configuration_dir() .. '/compton.conf -b')
	end
end
