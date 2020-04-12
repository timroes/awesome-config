local wibox = require('wibox')
local gears = require('gears')
local awful = require('awful')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	theme = require('lunaconf.theme')
}

local screen = screen

local switch = {}

function switch:set_state(state)
	self.state = state
	self:get_children_by_id('switch')[1]:emit_signal('widget::redraw_needed')
end

local function new(_, args)
	local sc = args.screen or screen.primary
	local theme = lunaconf.theme.get()
	local self = {
		state = args.initial_state or false
	}
	
	local widget = wibox.widget {
		layout = wibox.layout.align.horizontal,
		buttons = awful.button({}, 1, function()
			if args.on_toggle then
				args.on_toggle(not self.state, self)
			end
		end),
		nil,
		{
			widget = wibox.widget.textbox,
			text = args.title,
		},
		{
			widget = wibox.widget.base.make_widget,
			id = 'switch',
			fit = function (s, context, width, height)
				return math.min(lunaconf.dpi.x(40, sc), width), math.min(lunaconf.dpi.y(12, sc), height)
			end,
			draw = function (s, context, cr, width, height)
				cr:set_source_rgb(gears.color.parse_color(self.state and (args.active_color or theme.switch_bg_active) or theme.switch_bg))
				gears.shape.rounded_bar(cr, width, height)
				cr:fill()
				cr:set_source_rgb(gears.color.parse_color(theme.switch_handle))
				cr:arc(self.state and (width - height / 2) or (height / 2), height / 2, height / 2 - 4, 0, math.pi*2)
				cr:fill()
			end
		}
	}

	for k,v in pairs(widget) do
		self[k] = v
	end

	for k,v in pairs(_) do
		self[k] = v
	end

	return self
end

return setmetatable(switch, { __call = new })
