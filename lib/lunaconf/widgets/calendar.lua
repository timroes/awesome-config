local awful = require("awful")
local gears = require('gears')
local lunaconf = {
	theme = require('lunaconf.theme')
}

local theme = lunaconf.theme.get()

local calendar = {
	text_color = theme.cal_fg or theme.tooltip_fg or "#FFFFFF",
	today_color = theme.cal_today or theme.fg_urgent or "#00FF00",
	today_bg = theme.cal_today_bg or theme.bg_urgent or '#FFFFFF',
	font = theme.cal_font or 'monospace 11'
}

local tooltip = nil
local offset = 0

local function pop_spaces(s1, s2, maxsize)
	 local sps = ""
	 for i = 1, maxsize - string.len(s1) - string.len(s2) do
			sps = sps .. " "
	 end
	 return s1 .. sps .. s2
end

local function strip_time(time_obj)
	 local tbl = os.date("*t", time_obj)
	 return os.time{day = tbl.day, month = tbl.month, year = tbl.year}
end

local function create_calendar()
	 offset = offset or 0

	 local now = os.date("*t")
	 local cal_month = now.month + offset
	 local cal_year = now.year
	 if cal_month > 12 then
			cal_month = (cal_month % 12)
			cal_year = cal_year + 1
	 elseif cal_month < 1 then
			cal_month = (cal_month + 12)
			cal_year = cal_year - 1
	 end

	 local last_day = os.date("%d", os.time({ day = 1, year = cal_year,
																						month = cal_month + 1}) - 86400)
	 local first_day = os.time({ day = 1, month = cal_month, year = cal_year})
	 local first_day_in_week = (os.date("%w", first_day) - 1) % 7
	 local result = "Mo Di Mi Do Fr Sa So\n"
	 for i = 1, first_day_in_week do
			result = result .. "   "
	 end

	 local this_month = false
	 for day = 1, last_day do
			local last_in_week = (day + first_day_in_week) % 7 == 0
			local day_str = pop_spaces("", day, 2)
			if cal_month == now.month and cal_year == now.year and day == now.day then
				 this_month = true
				 result = result ..
						string.format('<span weight="bold" foreground="%s" background="%s">%s</span>',
													calendar.today_color, calendar.today_bg, day_str)
			else
				 result = result .. day_str
			end
			if not last_in_week then
				result = result .. ' '
			end
			if last_in_week and day ~= tonumber(last_day) then
				 result = result .. "\n"
			end
	 end

	 return string.format('<span font="%s" foreground="%s">%s\n%s</span>',
																calendar.font, calendar.text_color, os.date("%B %Y", first_day), result)
end

local function show(inc_offset)
	inc_offset = inc_offset or 0
	offset = offset + inc_offset
	tooltip.markup = create_calendar()
end

local function today()
	offset = 0
	show(0)
end

function calendar.register(_, widget)
	tooltip = awful.tooltip {

	}
	widget:connect_signal("mouse::enter", function()
		today()
		tooltip.visible = true
	end)
	widget:connect_signal("mouse::leave", function()
		tooltip.visible = false
	end)
	widget:buttons(gears.table.join(
		awful.button({ }, 2, function() today() end),
		awful.button({ }, 4, function() show(-1) end),
		awful.button({ }, 5, function() show(1) end)
	))
end

return setmetatable(calendar, { __call = calendar.register })
