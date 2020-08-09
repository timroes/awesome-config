local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
}

local clienticon = require('lunaconf.widgets.clienticon')

local tasklist = {}

local tasklist_buttons = gears.table.join(
	awful.button({ }, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c.minimized = false
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 2, function(c) c:kill() end),
	awful.button({ }, 3, function(c)
		client.focus = c
		c.floating = not c.floating
	end)
)

local function new(self, screen, tag_filter)
	local widget = awful.widget.tasklist {
		screen = screen,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		layout = {
				layout  = wibox.layout.fixed.horizontal
		},
		widget_template = {
			layout = wibox.layout.align.horizontal,
			create_callback = function(self, c)
				self:get_children_by_id('clienticon')[1].client = c
			end,
			{
				{
					{
						id = 'clienticon',
						widget = clienticon,
					},
					margins = lunaconf.dpi.x(5, screen),
					widget  = wibox.container.margin
				},
				id = 'background_role',
				widget = wibox.container.background,
			},
		}
	}

	return widget
end

return setmetatable(tasklist, { __call = new })
