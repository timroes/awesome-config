local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	theme = require('lunaconf.theme'),
	dialogs = {
		base = require('lunaconf.dialogs.base')
	}
}
local naughty = require('naughty')

local chooser = {}

local theme = lunaconf.theme.get()

local prev_selected = nil

local function draw_children(self, screen)
	self._item_layout:reset()

	self._item_layout.spacing = lunaconf.dpi.x(2, screen)

	local rounded_corners = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, lunaconf.dpi.x(3, screen))
	end

	for index,item in ipairs(self._items) do
		item._background = wibox.widget {
			{
				{
					{
						image = item.icon,
						forced_width = lunaconf.dpi.x(32, screen),
						forced_height = lunaconf.dpi.y(32, screen),
						widget = wibox.widget.imagebox
					},
					{
						text = item.text,
						font = theme.large_font or theme.font,
						align = 'center',
						widget = wibox.widget.textbox
					},
					layout = wibox.layout.fixed.vertical
				},
				top = lunaconf.dpi.y(10, screen),
				bottom = lunaconf.dpi.y(10, screen),
				left = lunaconf.dpi.x(15, screen),
				right = lunaconf.dpi.x(15, screen),
				widget = wibox.container.margin
			},
			shape = rounded_corners,
			shape_border_width = lunaconf.dpi.x(2, screen),
			widget = wibox.container.background
		}

		self._item_layout:add(item._background)
	end

	local width, height = wibox.widget.base.fit_widget(self._item_layout, {}, self._item_layout, 1000, 1000)
	self._base:set_raw_dimensions(width, lunaconf.dpi.y(72, screen))
end

function chooser:set_highlight(index)
	if prev_selected then
		prev_selected.bg = nil
		prev_selected.shape_border_color = nil
	end
	prev_selected = self._items[index]._background
	prev_selected.bg = theme.dialog_chooser_highlight
	prev_selected.shape_border_color = theme.dialog_chooser_highlight_border
end

function chooser:show(chooser_key, callback, reuse_index)
	if not reuse_index then
		self._index = 1
	end

	self._base:recalculate_sizes(function (screen)
		draw_children(self, screen)
	end)

	keygrabber.run(function(mod, key, event)
		if key == chooser_key or key == 'Right' or key == 'Left' then
			if event == 'press' then
				local direction = key == 'Left' and -1 or 1
				self._index = gears.math.cycle(#self._items, self._index + direction)
				self:set_highlight(self._index)
			end
		elseif event == 'release' then
			-- If we release any other key than the actual trigger key (which rotates
			-- through the options) apply the config and hide it
			keygrabber.stop()
			self._base:hide()
			callback(self._items[self._index])
		end
	end)

	self:set_highlight(self._index)

	self._base:show()
end

function chooser:set_items(items)
	self._index = 1
	self._items = items
end

local function new(_, params)
	local self = {}
	for k,v in pairs(_) do
		self[k] = v
	end

	self._item_layout = wibox.widget {
		layout = wibox.layout.fixed.horizontal
	}

	self._base = lunaconf.dialogs.base {
		widget = self._item_layout,
		margin = 8,
		width = 450,
		height = 450
	}

	return self
end

return setmetatable(chooser, { __call = new })
