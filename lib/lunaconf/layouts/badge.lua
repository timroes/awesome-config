local table = table
local type = type
local math = math
local wibox = require('wibox')

local badge = {}

function badge:add_badge(widget, align, valign)
	-- Check that the placement strings are valid
	align = align or 'center'
	assert(align == 'center' or align == 'left' or align == 'right', 'align must be one of: center, left, right')
	valign = valign or 'center'
	assert(valign == 'center' or valign == 'top' or valign == 'bottom', 'valign must be one of: center, top, bottom')

	wibox.widget.base.check_widget(widget)

	if self.badges[align .. valign] then
		self.badges[align .. valign]:set_children(widget)
	else
		local b = wibox.container.place(widget, align, valign)
		b.forced_width = 5
		b.fill_vertical = true
		self:add(b)
		self.badges[align .. valign] = b
	end
end

function badge:set_widget(widget)
	wibox.widget.base.check_widget(widget)
	self.widget = widget
	-- TODO: emit update event
end

function badge:fit(width, height)
	return wibox.widget.base.fit_widget(self.widget, width, height)
end

local function new(self, widget)
	local w = wibox.layout.stack()

	wibox.widget.base.check_widget(widget)

	-- Overwrite functions
	for k, v in pairs(badge) do
		if type(v) == 'function' then
			w[k] = v
		end
	end

	w.badges = {}

	w:add(widget)

	return w
end

return setmetatable(badge, { __call = new })
