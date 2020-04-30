local wibox = require('wibox')
local gears = require('gears')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	theme = require('lunaconf.theme')
}

local stats_panel = {}

local theme = lunaconf.theme.get()

function stats_panel:set_title(title)
	self._title.markup = '<small>' .. title .. '</small>'
end

function stats_panel:set_percentage(percentage)
	if percentage ~= self._bar.value then
		self._bar.value = percentage
	end
end

function stats_panel:set_value(value)
	if self._last_value ~= value then
		self._last_value = value
		self._value.markup = '<small>' .. value .. '</small>'
	end
end

function stats_panel:set_color(color)
	self._bar.color = color
end

local function new(_, args)
	local self = wibox.widget {
		widget = wibox.layout.grid.vertical,
		forced_num_cols = 2,
    forced_num_rows = 2,
    homogeneous = false,
		expand = true,
		spacing = lunaconf.dpi.y(6, args.screen),
		{
			widget = wibox.container.background,
			fg = theme.sidebar_shaded_text,
			{
				widget = wibox.widget.textbox,
				id = 'title_textbox',
				markup = '<small>' .. (args.title or '') .. '</small>'
			}
		},
		{
			widget = wibox.container.background,
			fg = theme.sidebar_subtext,
			{
				widget = wibox.widget.textbox,
				id = 'value_textbox',
				align = 'right',
				markup = '<small>' .. (args.value or '') .. '</small>'
			}
		}
	}

	self._last_value = args.value or ''

	self._title = self:get_children_by_id('title_textbox')[1]
	self._value = self:get_children_by_id('value_textbox')[1]

	self._bar = wibox.widget {
		widget = wibox.widget.progressbar,
		forced_height = lunaconf.dpi.y(2, args.screen),
		max_value = 100,
		value = 0,
		color = args.color,
		background_color = theme.sidebar_bg,
		shape = gears.shape.rounded_bar
	}

	self:add_widget_at(self._bar, 2, 1, 1, 2)

	for k,v in pairs(_) do
		self[k] = v
	end

	return self
end

return setmetatable(stats_panel, { __call = new })
