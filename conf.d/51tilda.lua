local lunaconf = require('lunaconf')
local TILDA_SCREEN = lunaconf.screens.primary_index()

-- Scale window to workspace size (min 15% height)
client.connect_signal("manage", function(c, startup)
	if c.class == "Tilda" then
		local wa = screen[TILDA_SCREEN].workarea
		c:geometry({
			x = wa.x,
			y = wa.y,
			width = wa.width,
			height = wa.height * 0.85
		})
	end
end)

awful.rules.rules = awful.util.table.join(awful.rules.rules, {
	{
		rule = { class = "Tilda" },
		properties = { floating = true, border_width = 0, opacity = 0.9 }
	}
})
