local wibox = require('wibox')
local gears = require('gears')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	theme = require('lunaconf.theme')
}

local calendar = {}

local day_widgets = {}

local current_month
local current_year

local function render_month(self)
	local now = os.date('*t')
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
		if i < first_weekday_in_month or i >= first_weekday_in_month + last_day_in_month then
			widget.visible = false
		else
			widget.visible = true
			widget:get_children_by_id('text')[1].text = tostring(i - first_weekday_in_month + 1)
			if now.year == current_year and now.month == current_month and (i - first_weekday_in_month + 1) == now.day then
				widget.shape_border_width = lunaconf.dpi.x(2, self._screen)
			else
				widget.shape_border_width = 0
			end
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
		daybox.bg = lunaconf.theme.get().calendar_hover
		daybox.fg = lunaconf.theme.get().calendar_hover_text
	end)
	daybox:connect_signal('mouse::leave', function()
		self._highlighted_day = nil
		daybox.bg = nil
		daybox.fg = nil
	end)
	return daybox
end

function calendar:set_to_now()
	local now = os.date('*t')
	current_month = now.month
	current_year = now.year
	render_month(self)
end

function calendar:hide_hover()
	if self._highlighted_day then
		self._highlighted_day:emit_signal('mouse::leave')
	end
end

function calendar:next_month()
	current_month = current_month + 1
	if current_month > 12 then
		current_month = 1
		current_year = current_year + 1
	end
	render_month(self)
end

function calendar:previous_month()
	current_month = current_month - 1
	if current_month < 1 then
		current_month = 12
		current_year = current_year - 1
	end
	render_month(self)
end

local function new(_, args)
	local self = wibox.widget {
		layout = wibox.layout.grid,
		forced_num_cols = 7,
		forced_num_rows = 7,
		spacing = lunaconf.dpi.x(2, args.screen),
		expand = true,
		homogeneous = true
	}

	self._screen = args.screen

	self._month_name = wibox.widget {
		widget = wibox.widget.textbox,
		align = 'center'
	}

	self:add_widget_at(self._month_name, 1, 1, 1, 7)
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
