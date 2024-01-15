local lunaconf = require('lunaconf')

lunaconf.clients.add_rules({
	{
		rule = { class = "Peek" },
		properties = {
			floating = true,
			border_width = 0,
			focusable = false,
		}
	}
})
