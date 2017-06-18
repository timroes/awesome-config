local awful = require('awful')
local wibox = require('wibox')

local clienttitle = {}

local function new(_, screen)
	local textbox = wibox.widget.textbox()
	local update_client = function()
		local c = awful.client.focus.history.get(screen, 0)
		if c and c.name then
			textbox.text = c.name
		else
			textbox.text = ''
		end
	end
	client.connect_signal('focus', update_client)
	client.connect_signal('unfocus', update_client)
	return textbox
end

return setmetatable(clienttitle, { __call = new })
