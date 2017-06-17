local wibox = require('wibox')

local clienttitle = {}

local textbox = nil

local function update_client()
	if client.focus and client.focus.name then
		textbox.text = client.focus.name
	else
		textbox.text = ''
	end
end

local function new(_, screen)
	textbox = wibox.widget.textbox()
	client.connect_signal('focus', update_client)
	client.connect_signal('unfocus', update_client)
	return textbox
end

return setmetatable(clienttitle, { __call = new })
