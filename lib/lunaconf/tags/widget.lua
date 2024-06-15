local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	log = require('lunaconf.log'),
	theme = require('lunaconf.theme')
}
local screens = require('lib.screens')

local tagwidget = {}

local theme = lunaconf.theme.get()

local dot_indicators = {
	{ { 0, 0 } },
	{ { -0.35, 0 }, { 0.35, 0 } },
	{ { 0, -0.35}, { -0.35, 0.35 }, { 0.35, 0.35 } },
	{ { -0.35, -0.35 }, { 0.35, -0.35 }, { 0.35, 0.35 }, { -0.35, 0.35} }
}

local function draw_position_indicator(cr, screen, position, size)
	if position > #dot_indicators then
		return lunaconf.log.err('The tag widget only supports up to ' .. tostring(#dot_indicators) .. ' screens.')
	end

	local dot_size = lunaconf.dpi.x(4, screen)
	cr:set_source_rgb(gears.color.parse_color(theme.tag_color_fg))

	for _, dot in ipairs(dot_indicators[position]) do
		cr:save()
		cr:translate(dot[1] * size - dot_size / 2, dot[2] * size - dot_size / 2)
		gears.shape.circle(cr, dot_size, dot_size)
		cr:fill()
		cr:restore()
	end
end

local function new(self, screen, tags, args)
	self = {
		_tags = tags
	}
	self._dx = function (v) return lunaconf.dpi.x(v, screen) end
	self._dy = function (v) return lunaconf.dpi.y(v, screen) end

	self._tag_count = args.tag_count
	self._selected_tag = args.selected_tag

	self._square_size = 0

	self._boxes = wibox.widget {
		widget = wibox.widget.base.make_widget,
		fit = function (s, context, width, height)
			self._square_size = math.min(height, width)
			return self._square_size * self._tag_count - (self._tag_count - 1) * 0.2 * self._square_size, self._square_size
		end,
		draw = function (s, context, cr, width, height)
			local regular_color = theme.tag_color_bg

			for i=1,self._tag_count do
				cr:set_source_rgb(gears.color.parse_color(i == self._selected_tag and theme.tag_color_selected_bg or regular_color))
				gears.shape.transform(gears.shape.rounded_rect)
					:translate(0.2 * height + (i-1) * height - (i-1) * height * 0.2, 0.2 * height)
					(cr, 0.6 * height, 0.6 * height, self._dx(3))
				cr:fill()

				if i == self._selected_tag then
					cr:save()
					cr:translate(0.5 * height + (i-1) * height - (i-1) * height * 0.2, 0.5 * height)
					draw_position_indicator(cr, screen, screens.getScreenPosition(screen) + 1, height * 0.6 / 2)
					cr:restore()
				end
			end
		end
	}

	self._boxes:connect_signal('button::press', function (_, x, y, button)
		if button == 1 then
			local tag_position = x // self._square_size
			self._tags.select_tag(tag_position + 1)
		elseif button == 4 then
			self._tags.prev_tag()
		elseif button == 5 then
			self._tags.next_tag()
		end
	end)

	screen:connect_signal('common_tag::changed', function(_, tag_count)
		self._tag_count = tag_count
		self._boxes:emit_signal('widget::layout_changed')
	end)

	screen:connect_signal('common_tag::selected', function(_, index)
		self._selected_tag = index
		self._boxes:emit_signal('widget::redraw_needed')
	end)

	return self._boxes
end

return setmetatable(tagwidget, { __call = new })
