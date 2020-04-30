local gears = require('gears')
local wibox = require('wibox')
local awful = require('awful')
local naughty = require('naughty')

-- Internal widgets
local switch = require('lunaconf.sidebar.switch')
local calendar = require('lunaconf.sidebar.calendar')
local battery = require('lunaconf.sidebar.battery')
local stats_panel = require('lunaconf.sidebar.stats_panel')

local lunaconf = {
	config = require('lunaconf.config'),
	dpi = require('lunaconf.dpi'),
	keys = require('lunaconf.keys'),
	theme = require('lunaconf.theme'),
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

local function calculate_stats(self)
	-- Load memory stats via `free`
	awful.spawn.easy_async('free -b', function (stdout)
		local total, used, free, shared, buffers, available = stdout:match('Mem:%s*(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)')
		local unfreeable_memory = tonumber(total) - tonumber(available)
		local mem_percentage = (unfreeable_memory / tonumber(total)) * 100
		self._memory_stats:set_value(
			string.format('%s / %s',
				lunaconf.utils.humanreadable_bytes(unfreeable_memory),
				lunaconf.utils.humanreadable_bytes(tonumber(total))
			)
		)
		self._memory_stats:set_percentage(mem_percentage)
	end)
end

-- Placement function for the sidebar
local function placement_fn(wibox)
	local p = awful.placement.maximize_vertically + awful.placement.right
	p(wibox, { honor_workarea = true })	
end

local function hide(self, stop_keygrabber)
	self._popup.visible = false
	self._calendar:set_to_now()
	self._stats_timer:stop()
	if stop_keygrabber then
		self._keygrabber:stop()
	end
	-- Restore focus to the previously focused client if it's still valid
	-- and haven't been destroyed in between
	if self._prev_focused_client and self._prev_focused_client.valid then
		client.focus = self._prev_focused_client
	end
	self._prev_focused_client = nil
end

local function show(self)
	-- Store the current focused client to focus it later again
	if client.focus then
		self._prev_focused_client = client.focus
		-- Remove focus from that client while sidebar is opened
		client.focus = nil
	end
	self._popup.screen = screen.primary
	placement_fn(self._popup)
	calculate_stats(self)
	self._stats_timer:start()
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

-- Do prevent screen sleep while a client that matches any of the given rules on startup
-- is still managed.
local function set_screensleep_rules(self, rules)
	self._keepalive_clients = {}
	self._count_keepalive_clients = 0
	client.connect_signal('manage', function (c)
		if awful.rules.matches_list(c, rules) then
			self._keepalive_clients[c.window] = true
			self._count_keepalive_clients = self._count_keepalive_clients + 1
			self:set_screensleep(true)
		end
	end)

	client.connect_signal('unmanage', function (c)
		if self._keepalive_clients[c.window] then
			self._keepalive_clients[c.window] = nil
			self._count_keepalive_clients = self._count_keepalive_clients - 1
			if self._count_keepalive_clients == 0 then
				self:set_screensleep(false)
			end
		end
	end)
end

function sidebar:set_screensleep(keepalive)
	-- If we're already in the right state, don't do anything
	if keepscreenawake == keepalive then
		return
	end
	keepscreenawake = keepalive
	self._screensleep:set_state(keepscreenawake)
	self._trigger_squares:emit_signal('widget::redraw_needed')
	awful.spawn.spawn(lunaconf.utils.scriptpath() .. '/screensaver.sh ' .. (keepscreenawake and 'pause' or 'resume'))
end

function sidebar:toggle_screensleep()
	self:set_screensleep(not keepscreenawake)
end

function sidebar:toggle_dnd()
	dnd_enabled = not dnd_enabled
	self._dnd_switch:set_state(dnd_enabled)
	self._trigger_squares:emit_signal('widget::redraw_needed')
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
	
	self._trigger_squares = wibox.widget {
		widget = wibox.widget.base.make_widget,
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

	self.trigger = wibox.widget {
		widget = wibox.layout.fixed.horizontal,
		buttons = gears.table.join(
			awful.button({}, 1, function() toggle(self) end)
		),
		self._trigger_squares,
	}

	self._calendar = calendar {
		screen = screen.primary
	}

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

	self._memory_stats = stats_panel {
		screen = screen.primary,
		color = theme.stats_memory,
		title = 'Memory'
	}

	self._popup = awful.popup {
		widget = {
			widget = wibox.container.margin,
			forced_width = dx(400),
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
				},
				{
					widget = wibox.layout.fixed.vertical,
					spacing = dy(10),
					{
						widget = wibox.container.background,
						bg = theme.sidebar_panel_bg,
						shape = gears.shape.rounded_rect,
						{
							id = 'stats_panel',
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
								self._memory_stats
							}
						}
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

	-- Only add the battery widget if upower is installed
	lunaconf.utils.only_if_command_exists('upower', function(upower_installed)
		self._battery = battery(screen.primary)
		self.trigger:insert(1, self._battery.quick_status)
		local battery_stats = wibox.widget {
			widget = wibox.container.margin,
			left = dx(10),
			right = dx(10),
			top = dy(10),
			bottom = dy(10),
			self._battery.full_status
		}
		self._popup.widget:get_children_by_id('stats_panel')[1]:add(battery_stats)
	end)

	self._stats_timer = gears.timer {
		timeout = 1,
		autostart = false,
		callback = function() calculate_stats(self) end
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
			{{}, 'Home', function() self._calendar:set_to_now() end},
			{{ lunaconf.config.MOD }, '\\', function(keygrabber) keygrabber:stop() end}
		},
		stop_key = 'Escape',
		stop_callback = function()
			-- Hide the panel in case the keygrabber will stop, but prevent the hide method from stopping it again
			hide(self, false)
		end
	}

	-- Hide the popup if a client gains focus while it's open
	client.connect_signal('focus', function()
		if self._popup.visible then
			hide(self, true)
		end
	end)

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

	if args.screen_keepalive then
		set_screensleep_rules(self, args.screen_keepalive)
	end

	return self
end

return setmetatable(sidebar, { __call = new })
