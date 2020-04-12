local gears = require('gears')
local wibox = require('wibox')
local awful = require('awful')
local naughty = require('naughty')

-- Internal widgets
local switch = require('lunaconf.sidebar.switch')
local calendar = require('lunaconf.sidebar.calendar')

local lunaconf = {
	config = require('lunaconf.config'),
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	keys = require('lunaconf.keys'),
	notify = require('lunaconf.notify'),
	screens = require('lunaconf.screens'),
	theme = require('lunaconf.theme'),
	dialogs = {
		base = require('lunaconf.dialogs.base')
	},
	utils = require('lunaconf.utils')
}
local screen = screen
local dx = function (v) return lunaconf.dpi.x(v, screen.primary) end
local dy = function (v) return lunaconf.dpi.y(v, screen.primary) end

local sidebar = {}

local dnd_enabled = false
local keepscreenawake = false
-- Resume screensaver on startup, so the icon will always be in sync over awesome restarts
awful.spawn.spawn(lunaconf.utils.scriptpath() .. '/screensaver.sh resume')

local theme = lunaconf.theme.get()

-- Placement function for the sidebar
local function placement_fn(wibox)
	local p = awful.placement.maximize_vertically + awful.placement.right
	p(wibox, { honor_workarea = true })	
end

local function hide(self, stop_keygrabber)
	self._popup.visible = false
	self._calendar:set_to_now()
	if stop_keygrabber then
		self._keygrabber:stop()
	end
end

local function show(self)
	self._popup.screen = screen.primary
	placement_fn(self._popup)
	self._keygrabber:start()
	self._popup.visible = true
end

local function toggle(self)
	if self._popup.visible then
		hide(self, true)
	else
		show(self)
	end
end

function sidebar:toggle_screensleep()
	keepscreenawake = not keepscreenawake
	self._screensleep:set_state(keepscreenawake)
	self.trigger:emit_signal('widget::redraw_needed')
	awful.spawn.spawn(lunaconf.utils.scriptpath() .. '/screensaver.sh ' .. (keepscreenawake and 'pause' or 'resume'))
end

function sidebar:toggle_dnd()
	dnd_enabled = not dnd_enabled
	self._dnd_switch:set_state(dnd_enabled)
	self.trigger:emit_signal('widget::redraw_needed')
	if dnd_enabled then
		naughty.destroy_all_notifications()
	end
end

function sidebar.is_dnd_enabled()
	return dnd_enabled
end

local function new(_, args)
	local self = {}
	for k,v in pairs(_) do
		self[k] = v
	end
	
	self.trigger = wibox.widget {
		widget = wibox.widget.base.make_widget,
		buttons = gears.table.join(
			awful.button({}, 1, function() toggle(self) end)
		),
		fit = function (s, context, width, height)
			return math.min(height, width), math.min(height, width)
		end,
		draw = function (s, context, cr, width, height)
			local regular_color = theme.sidebar_trigger_color

			-- Top left square which indicates the dnd status
			cr:set_source_rgb(gears.color.parse_color(dnd_enabled and theme.sidebar_dnd_color or regular_color))
			gears.shape.transform(gears.shape.rounded_rect)
				:translate(0.15 * width, 0.15 * height)
				(cr, 0.3 * width, 0.3 * height, dx(2))
			cr:fill()

			-- Top right square
			cr:set_source_rgb(gears.color.parse_color(regular_color))
			gears.shape.transform(gears.shape.rounded_rect)
				:translate(0.55 * width, 0.15 * height)
				(cr, 0.3 * width, 0.3 * height, dx(2))
			cr:fill()
			
			-- Bottom left square
			gears.shape.transform(gears.shape.rounded_rect)
				:translate(0.15 * width, 0.55 * height)
				(cr, 0.3 * width, 0.3 * height, dx(2))
			cr:fill()

			-- Bottom right square
			cr:set_source_rgb(gears.color.parse_color(keepscreenawake and theme.sidebar_screensleep_color or regular_color))
			gears.shape.transform(gears.shape.rounded_rect)
				:translate(0.55 * width, 0.55 * height)
				(cr, 0.3 * width, 0.3 * height, dx(2))
			cr:fill()
		end
	}

	self._calendar = calendar()

	self._dnd_switch = switch {
		screen = screen.primary,
		title = 'Do Not Disturb',
		active_color = theme.sidebar_dnd_color,
		initial_state = dnd_enabled,
		on_toggle = function() self:toggle_dnd() end
	}

	self._screensleep = switch {
		screen = screen.primary,
		title = 'Keep Screen Awake',
		active_color = theme.sidebar_screensleep_color,
		initial_state = keepscreenawake,
		on_toggle = function() self:toggle_screensleep() end
	}

	self._popup = awful.popup {
		widget = {
			widget = wibox.container.margin,
			forced_width = dx(450),
			left = dx(20),
			right = dx(20),
			top = dy(20),
			bottom = dy(20),
			{
				widget = wibox.layout.fixed.vertical,
				spacing = dy(10),
				{
					widget = wibox.container.background,
					bg = theme.sidebar_panel_bg,
					shape = gears.shape.rounded_rect,
					{
						widget = wibox.layout.fixed.vertical,
						spacing = dy(2),
						spacing_widget = {
							widget = wibox.widget.separator,
							color = theme.sidebar_bg,
							span_ratio = 0.95
						},
						{
							widget = wibox.container.margin,
							left = dx(10),
							right = dx(10),
							top = dy(10),
							bottom = dy(10),
							self._dnd_switch
						},
						{
							widget = wibox.container.margin,
							left = dx(10),
							right = dx(10),
							top = dy(10),
							bottom = dy(10),
							self._screensleep
						}
					}
				},
				{
					widget = wibox.container.background,
					bg = theme.sidebar_panel_bg,
					shape = gears.shape.rounded_rect,
					{ 
						widget = wibox.container.margin,
						left = dx(10),
						right = dx(10),
						top = dy(10),
						bottom = dy(10),
						self._calendar
					}
				}
			}
		},
		bg = theme.sidebar_bg,
		screen = screen.primary,
		placement = placement_fn,
		ontop = true,
		type = 'dock',
		visible = false
	}

	-- Mouse button mappings
	self._popup:buttons(gears.table.join(
		awful.button({}, 2, function() self._calendar:set_to_now() end),
		awful.button({}, 4, function() self._calendar:previous_month() end),
		awful.button({}, 5, function() self._calendar:next_month() end)
	))
	
	self._keygrabber = awful.keygrabber {
		keybindings = {
			{{}, 'd', function() self:toggle_dnd() end},
			{{}, 's', function() self:toggle_screensleep() end},
			{{}, 'Up', function() self._calendar:previous_month() end},
			{{}, 'Down', function() self._calendar:next_month() end},
			{{ lunaconf.config.MOD }, '\\', function(keygrabber) keygrabber:stop() end}
		},
		stop_key = 'Escape',
		stop_callback = function()
			-- Hide the panel in case the keygrabber will stop, but prevent the hide method from stopping it again
			hide(self, false)
		end
	}

	-- Whenever the primary screen change move the popup to that screen (this only works while it's open)
	screen.connect_signal('primary_changed', function ()
		self._popup.screen = screen.primary
	end)

	-- Register global hotkey to open sidebar
	lunaconf.keys.globals(
		awful.key({ lunaconf.config.MOD }, '\\', function()
			toggle(self)
		end)
	)

	return self
end

return setmetatable(sidebar, { __call = new })
