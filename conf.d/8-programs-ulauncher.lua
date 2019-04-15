local awful = require('awful')
local gears = require('gears')

client.connect_signal('manage', function(c)
	if c.class == 'Ulauncher' then
		c:set_xproperty("_COMPTON_NO_SHADOW", true)
	end
end)
