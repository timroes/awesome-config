local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')

local clienttitle = {}

local function new(_, screen)

	local get_client = function()
		return awful.client.focus.history.get(screen, 0)
	end

	local textbox = wibox.widget.textbox()
	local update_client = function()
		local c = get_client()
		if c and c.name then
			textbox.text = c.name
		else
			textbox.text = ''
		end
	end

	local focus_client = function()
		local c = get_client()
		if c then
			client.focus = c
		end
	end

	local kill_client = function()
		local c = get_client()
		if c then
			c:kill()
		end
	end

	-- Setup buttons
	local buttons = gears.table.join(
		awful.button({ }, 1, focus_client),
		awful.button({ }, 2, kill_client)
	)

	textbox:buttons(buttons)
	client.connect_signal('property::name', update_client)
	client.connect_signal('focus', update_client)
	client.connect_signal('unfocus', update_client)
	client.connect_signal('manage', update_client)
	client.connect_signal('unmanage', update_client)

	screen:connect_signal('removed', function()
		-- remove all listeners on client, since this will otherwise keep this widget
		-- illegally in memory, even though the screen it was for is already removed
		client.disconnect_signal('property::name', update_client)
		client.disconnect_signal('focus', update_client)
		client.disconnect_signal('unfocus', update_client)
		client.disconnect_signal('manage', update_client)
		client.disconnect_signal('unmanage', update_client)
	end)

	return textbox
end

return setmetatable(clienttitle, { __call = new })
