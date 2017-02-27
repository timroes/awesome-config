local base = require('wibox.widget.base')
local debug = require('gears.debug')
local table = table
local type = type
local math = math
local wibox = require('wibox')

local badge = {}

local function draw_badge(badge, wibox, cr, width, height, horizontal, vertical)
	local w, h = base.fit_widget(badge.widget, width, height)
	if badge.max_width then
		w = math.min(width * badge.max_width, w)
	end
	if badge.max_height then
		h = math.min(height * badge.max_height, h)
	end

	-- base.draw_widget(wibox, cr, badge.widget,
	-- 	),
	-- 	,
	-- 	w, h)

	cr:save()
	cr:translate(
		horizontal * (width - w) + ((1 - horizontal * 2) * badge.margin),
		vertical * (height - h) + ((1 - vertical * 2) * badge.margin)
	)
	cr:rectangle(0, 0, w, h)
	cr:clip()


	-- local
end

function badge:draw(wibox, cr, width, height)
	base.draw_widget(wibox, cr, self.widget, 0, 0, width, height)

	if self.badges.se then
		draw_badge(self.badges.se, wibox, cr, width, height, 1, 1)
	end
	if self.badges.sw then
		draw_badge(self.badges.sw, wibox, cr, width, height, 0, 1)
	end
	if self.badges.ne then
		draw_badge(self.badges.ne, wibox, cr, width, height, 1, 0)
	end
	if self.badges.nw then
		draw_badge(self.badges.nw, wibox, cr, width, height, 0, 0)
	end
end

function badge:add_badge(placement, widget, margin, max_width, max_height)
	-- Check that placement is one of the valid placements
	assert(placement == 'se' or placement == 'ne' or placement == 'nw' or placement == 'sw')
	base.check_widget(widget)

	self.badges[placement] = {
		widget = widget,
		margin = margin or 0,
		max_width = max_width or nil,
		max_height = max_height or nil
	}
end

function badge:set_widget(widget)
	base.check_widget(widget)
	self.widget = widget
	-- TODO: emit update event
end

function badge:fit(width, height)
	return base.fit_widget(self.widget, width, height)
end

local function new(self, widget)
	local w = base.make_widget()

	base.check_widget(widget)

	-- Overwrite functions
	for k, v in pairs(badge) do
		if type(v) == 'function' then
			w[k] = v
		end
	end

	w.badges = {
		se = nil,
		sw = nil,
		ne = nil,
		nw = nil
	}

	w.widget = widget

	return w
end

return setmetatable(badge, { __call = new })
