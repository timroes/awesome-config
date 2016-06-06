local awful = require('awful')
local wibox = require('wibox')
local config = require("lunaconf.config")

local hangout_shortcut_key = "h"

local window_width = 400
local window_height = 520

local titlebar_height = 32
local window_spacing = 42

local is_hidden = false

local hangout_rule = {
	instance = "crx_nckgahadagoaajjgafhacjanaoiihapd"
}

-- Checks wether a given client is a hangout window
local is_hangout = function(c)
	return awful.rules.match(c, hangout_rule)
end

-- Toggle the visibility of all hangout windows
local toggle_visibility = function()
	for c in awful.client.iterate(is_hangout) do
		c.hidden = not is_hidden
	end
	is_hidden = not is_hidden
end

-- Returns the titlebar for a specific hangout window
local titlebar = function(c)
	local w = wibox.layout.fixed.horizontal()

	w:add(wibox.layout.margin(awful.titlebar.widget.iconwidget(c), 6, 12, 6, 6))
	w:add(awful.titlebar.widget.titlewidget(c))

	w:buttons(awful.util.table.join(
		awful.button({ }, 2, function()
			c:kill()
		end)
	))

	return w
end

-- Manage the specified windows as a hangout window
local manage_hangout = function(c)

	-- Set client to floating
	awful.client.floating.set(c, true)

	local s = screen[PRIMARY]

	local win_x
	-- ##
	-- TODO: doesn't work since name is not set during manage for the first time
	-- ##
	if c.name == "Hangouts" then
		win_x = s.workarea.x + window_spacing
	else
		-- Find the position for any message window
		local all_x = {}
		for c in awful.client.iterate(function(c) return is_hangout(c) and c.name ~= "Hangouts" end) do
			-- TODO: With newer lua versions that doesn't work anymore. We need to fix this.
			--table.insert(all_x, math.floor(c:geometry().x), c)
		end
		-- Find the first free slot after the contact list
		win_x = s.workarea.x + (2 * window_spacing) + window_width
		while all_x[win_x] do
			win_x = win_x + window_spacing + window_width
		end
	end

	local win_y = s.workarea.y + s.workarea.height - (window_height + titlebar_height)

	c:geometry({ width = window_width, height = window_height, y = win_y, x = win_x })
	c.above = true
	c.border_width = 0
	c.border_color = '#666666'
	c.skip_taskbar = true

	-- Get the titlebar for a hangout window and attach it to the window
	awful.titlebar(c, { size = titlebar_height, position = "top" }):set_widget(titlebar(c))
end

-- If a hangout window is focused while in hidden state,
-- show all hangout windows
client.connect_signal("focus", function(c)
	if is_hangout(c) and is_hidden then
		toggle_visibility()
	end
end)

-- Shortcut to toggle hangout tag
keys = awful.util.table.join(root.keys(),
	awful.key({ config.MOD }, hangout_shortcut_key, toggle_visibility)
)
root.keys(keys)

-- Add the above specified rule, with a callback to the manage_hangout function
awful.rules.rules = awful.util.table.join(awful.rules.rules, {
	{
		rule = hangout_rule,
		properties = {
			callback = manage_hangout
		}
	}
})
