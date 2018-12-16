local lunaconf = require('lunaconf')

lunaconf.clients.add_rules({
	{
		rule = { class = "Peek" },
		properties = {
			floating = true,
			border_width = 0,
			focusable = false,
			skip_titlebar = true,
			callback = function(c)
				c:connect_signal('property::name', function(c, name)
					if c.name == '00:00' then
						c.minimized = true
					elseif c.name == nil then
						c.minimized = false
					end
				end)
			end
		}
	}
})
