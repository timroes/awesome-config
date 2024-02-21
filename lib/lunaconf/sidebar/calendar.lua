local wibox = require('wibox')
local gears = require('gears')
local glib = require("lgi").GLib
local DateTime = glib.DateTime
local TimeZone = glib.TimeZone
local lunaconf = {
	config = require('lunaconf.config'),
	dpi = require('lunaconf.dpi'),
	log = require('lunaconf.log'),
	theme = require('lunaconf.theme')
}

local calendar = {}

local highlights = lunaconf.config.get('calendar.highlights', {})

local day_widgets = {}

local current_month
local current_year

local function today()
	local now = DateTime.new_now(TimeZone.new_local())
	local month = now:get_month()
	local year = now:get_year()
	local day = now:get_day_of_month()
	return year, month, day
end

local function recolor_daybox(self, daybox)
	if daybox._highlight then
		daybox.bg = lunaconf.theme.get().calendar_highlight
		daybox.fg = lunaconf.theme.get().calendar_highlight_text
	elseif self._highlighted_day == daybox then
		daybox.bg = lunaconf.theme.get().calendar_hover
		daybox.fg = lunaconf.theme.get().calendar_hover_text
	else
		daybox.bg = nil
		daybox.fg = nil
	end
end

local function render_month(self)
	local year, month, day = today()
	local first_day_in_month = os.time { year = current_year, month = current_month, day = 1 }
	local last_day_in_month = tonumber(os.date("%d", os.time { year = current_year,	month = current_month + 1, day = 1 } - 86400))
	local first_weekday_in_month = math.floor((os.date("%w", first_day_in_month) - 1) % 7 + 1)
	self._month_name.text = os.date('%B %Y', first_day_in_month)

	-- Handle the special case where the whole month would fit within 4 rows
	-- which can only happen for 28 days if it start with a Monday. In that case
	-- we want that month to only begin in the 2nd row for better vertical alignment
	if last_day_in_month == 28 and first_weekday_in_month == 1 then
		first_weekday_in_month = 8
	end

	for i, widget in ipairs(day_widgets) do
		widget._highlight = nil

		if i < first_weekday_in_month or i >= first_weekday_in_month + last_day_in_month then
			widget.visible = false
		else
			widget._date = os.time { year = current_year, month = current_month, day = i - first_weekday_in_month + 1 }
			widget._highlight = highlights[os.date('%Y-%m-%d', widget._date)]
			widget.visible = true
			widget:get_children_by_id('text')[1].text = tostring(i - first_weekday_in_month + 1)
			if year == current_year and month == current_month and (i - first_weekday_in_month + 1) == day then
				widget.shape_border_width = lunaconf.dpi.x(1, self._screen)
			else
				widget.shape_border_width = 0
			end
			recolor_daybox(self, widget)
		end
	end
end

local function weekday_name(name)
	return wibox.widget {
		widget = wibox.widget.textbox,
		text = name,
		align = 'center'
	}
end

local function calculate_datediff(self, daybox)
	local year, month, day = today()
	local beginning_of_today = os.time { year = year, month = month, day = day }
	local diff = math.floor(os.difftime(beginning_of_today, daybox._date) // (24 * 60 * 60))
	local diffstr
	if diff == 0 then
		diffstr = 'today'
	else
		local diffabs = math.abs(diff)
		if diffabs < 7 then
			diffstr = tostring(diffabs) .. ' days'
		else
			diffstr = math.floor(diffabs / 7) .. ' weeks'
			if diffabs % 7 ~= 0 then
				diffstr = diffstr .. ' and ' .. (diffabs % 7) .. ' days'
			end
		end
		diffstr = diff < 0 and ('in ' .. diffstr) or (diffstr .. ' ago')
	end
	self._datediff.widget.text = diffstr
	self._hover_line.visible = true
end

local function daybox(self, nr)
	local daybox = wibox.widget {
		layout = wibox.container.background,
		shape = gears.shape.circle,
		shape_border_color = lunaconf.theme.get().calendar_today,
		{
			widget = wibox.container.margin,
			top = lunaconf.dpi.y(4, self._screen),
			bottom = lunaconf.dpi.y(4, self._screen),
			right = lunaconf.dpi.x(4, self._screen),
			left = lunaconf.dpi.x(4, self._screen),
			{
				widget = wibox.widget.textbox,
				id = 'text',
				align = 'center',
				valign = 'center'
			}
		}
	}
	daybox:connect_signal('mouse::enter', function()
		self._highlighted_day = daybox
		recolor_daybox(self, daybox)
		if daybox._highlight then
			self._highlight_label.visible = true
			self._highlight_label:get_children_by_id('text')[1].text = daybox._highlight
		end
		if daybox.visible then
			calculate_datediff(self, daybox)
		end
	end)
	daybox:connect_signal('mouse::leave', function()
		self._highlighted_day = nil
		self._hover_line.visible = false
		self._highlight_label.visible = false
		self._highlight_label:get_children_by_id('text')[1].text = ''
		recolor_daybox(self, daybox)
	end)
	return daybox
end

function calendar:set_to_now(force_refresh)
	local year, month, day = today()
	if current_month ~= month or current_year ~= year then
		current_month = month
		current_year = year
		if self._highlighted_day then
			self._highlighted_day:emit_signal('mouse::leave')
		end
		render_month(self)
	elseif force_refresh then
		render_month(self)
	end
end

function calendar:next_month()
	current_month = current_month + 1
	if current_month > 12 then
		current_month = 1
		current_year = current_year + 1
	end
	render_month(self)
	-- If a day was highlighted before scrolling we need to reemit the focus event
	-- to calculate the difference to the new day
	if self._highlighted_day then
		local prev_highlighted = self._highlighted_day
		prev_highlighted:emit_signal('mouse::leave')
		prev_highlighted:emit_signal('mouse::enter')
	end
end

function calendar:previous_month()
	current_month = current_month - 1
	if current_month < 1 then
		current_month = 12
		current_year = current_year - 1
	end
	render_month(self)
	-- If a day was highlighted before scrolling we need to reemit the focus event
	-- to calculate the difference to the new day
	if self._highlighted_day then
		local prev_highlighted = self._highlighted_day
		prev_highlighted:emit_signal('mouse::leave')
		prev_highlighted:emit_signal('mouse::enter')
	end
end

local function new(_, args)
	local self = wibox.widget {
		layout = wibox.layout.grid,
		forced_num_cols = 7,
		forced_num_rows = 7,
		spacing = lunaconf.dpi.x(2, args.screen),
		expand = true,
		homogeneous = true,
		superpose = true
	}

	self._screen = args.screen

	self._month_name = wibox.widget {
		widget = wibox.widget.textbox,
		align = 'center'
	}

	self._datediff = wibox.widget {
		widget = wibox.container.background,
		bg = lunaconf.theme.get().calendar_hover,
		fg = lunaconf.theme.get().calendar_hover_text,
		{
			widget = wibox.widget.textbox,
			align = 'center'
		}
	}

	self._highlight_label = wibox.widget {
		widget = wibox.container.background,
		bg = lunaconf.theme.get().calendar_highlight,
		fg = lunaconf.theme.get().calendar_highlight_text,
		visible = false,
		{
			widget = wibox.container.margin,
			left = lunaconf.dpi.x(6, self._screen),
			right = lunaconf.dpi.x(6, self._screen),
			{
				widget = wibox.widget.textbox,
				id = 'text'
			}
		}
	}

	self._hover_line = wibox.widget {
		widget = wibox.container.background,
		shape = gears.shape.rounded_rect,
		shape_clip = true,
		visible = false,
		wibox.layout.align.horizontal(self._highlight_label, self._datediff)
	}

	self:add_widget_at(self._month_name, 1, 1, 1, 7)
	self:add_widget_at(self._hover_line, 1, 1, 1, 7)
	self:add_widget_at(weekday_name('Mo'), 2, 1)
	self:add_widget_at(weekday_name('Tu'), 2, 2)
	self:add_widget_at(weekday_name('We'), 2, 3)
	self:add_widget_at(weekday_name('Th'), 2, 4)
	self:add_widget_at(weekday_name('Fr'), 2, 5)
	self:add_widget_at(weekday_name('Sa'), 2, 6)
	self:add_widget_at(weekday_name('Su'), 2, 7)

	for i=1, 7*6 do
		day_widgets[i] = daybox(self, i)
		self:add_widget_at(day_widgets[i], (i - 1) // 7 + 3, (i - 1) % 7 + 1)
	end

	for k,v in pairs(_) do
		self[k] = v
	end

	self:set_to_now()
	
	return self
end

return setmetatable(calendar, { __call = new })
