local wibox = require("wibox")
local gears = require("gears")
local lncairo = require("lunaconf.cairo")

local colorbox = {}

function colorbox:draw(wibox, cr, width, height)
	if not self._visible or (not self._color and not self._color2) then return end

	local offset_y, offset_x = self._margin_vertical, self._margin_horizontal

	if 2 * self._margin_vertical + self._height > height then
		offset_y = (height - self._height) / 2.0
	end
	if 2 * self._margin_horizontal + self._width > width then
		offset_x = (width - self._width) / 2.0
	end

	cr:save()
	if self._shape == 'circle' then
		lncairo.semicircle(cr, offset_x, offset_y, self._width, self._height, math.pi * 1.25)
	elseif self._shape == 'rect' then
		cr:new_path()
		cr:move_to(offset_x, offset_y)
		cr:line_to(offset_x + self._width, offset_y)
		cr:line_to(offset_x + self._width, offset_y + self._height)
		cr:close_path()
	end
	cr:set_source(self._color or self._color2)
	cr:fill()

	if self._shape == 'circle' then
		lncairo.semicircle(cr, offset_x, offset_y, self._width, self._height, math.pi * 0.25)
	elseif self._shape == 'rect' then
		cr:new_path()
		cr:move_to(offset_x, offset_y)
		cr:line_to(offset_x + self._width, offset_y + self._height)
		cr:line_to(offset_x, offset_y + self._height)
		cr:close_path()
	end

	cr:set_source(self._color2 or self._color)
	cr:fill()

	cr:restore()
end

function colorbox:fit(width, height)
	local w = self._width + 2 * self._margin_horizontal
	local h = self._height + 2 * self._margin_vertical
	return w, h
end

function colorbox:set_visible(visible)
	self._visible = visible
	self:emit_signal("widget::updated")
end

function colorbox:set_color(color)
	local color = color
	if type(color) == 'string' or type(color) == 'table' then
		color = gears.color(color)
	end
	self._color = color
	self:emit_signal("widget::updated")
end

function colorbox:set_color2(color)
	local color = color
	if type(color) == 'string' or type(color) == 'table' then
		color = gears.color(color)
	end
	self._color2 = color
	self:emit_signal("widget::updated")
end

local function new(self, shape, width, height, args)
	assert(shape == 'circle' or shape == 'rect', 'colorbox shape must be "circle" or "rect"; got: "' .. shape .. '"')

	local widget = wibox.widget.base.empty_widget()
	for k, v in pairs(colorbox) do
		if type(v) == "function" then
			widget[k] = v
		end
	end

	widget._shape = shape
	widget._visible = true
	widget._width = width
	widget._height = height

	widget._margin_vertical = args.margin_vertical or args.margin or 0
	widget._margin_horizontal = args.margin_horizontal or args.margin or 0

	widget._color = args.color and gears.color(args.color)
	widget._color2 = args.color2 and gears.color(args.color2)

	return widget
end

function colorbox.circle(width, height, args)
	return new(colorbox, 'circle', width, height, args)
end

function colorbox.rect(width, height, args)
	return new(colorbox, 'rect', width, height, args)
end

return setmetatable(colorbox, { __call = new })
