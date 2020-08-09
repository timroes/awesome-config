local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	config = require('lunaconf.config'),
	dpi = require('lunaconf.dpi'),
	notify = require('lunaconf.notify'),
	theme = require('lunaconf.theme'),
	utils = require('lunaconf.utils')
}

local tagwidget = {}

local theme = lunaconf.theme.get()

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
				-- TODO: Add screen position number to active tag
				-- if i == self._selected_tag then
				-- 	cr:set_font_size(height / 1.5)
				-- 	local extents = cr:text_extents(tostring(position))
				-- 	cr:set_source_rgb(gears.color.parse_color(theme.tag_color_fg))
				-- 	cr:move_to(width / 2 - extents.width / 2, height / 2 + extents.height / 2)
				-- 	cr:show_text(tostring(screen.position))
				-- end
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
