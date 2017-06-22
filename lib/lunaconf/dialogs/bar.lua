local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	screens = require('lunaconf.screens'),
	theme = require('lunaconf.theme')
}

local bar = {}

local theme = lunaconf.theme.get()

local last_shown_dialog

local function recalculate_sizes(self)
	local screen = self._widget.screen
	self._widget.height = lunaconf.dpi.y(50, screen)
	self._widget.width = lunaconf.dpi.x(250, screen)

	-- self._progress.paddings = lunaconf.dpi.x(2, screen)
	self._progress.margins = {
		top = lunaconf.dpi.y(10, screen),
		bottom = lunaconf.dpi.y(10, screen),
		left = lunaconf.dpi.y(4, screen),
		right = lunaconf.dpi.y(10, screen),
	}
	-- Modify rounded corners
	self._progress.shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, lunaconf.dpi.x(2, screen))
	end

	self._widget.shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, lunaconf.dpi.x(4, screen))
	end

	self._icon_margin.margins = lunaconf.dpi.x(4, screen)
end

function bar:set_disabled(disabled)
	self._progress.color = disabled and theme.dialog_bar_disabled_fg or theme.dialog_bar_fg
end

function bar:set_icon(icon_name)
	local icon = lunaconf.icons.lookup_icon(icon_name)
	self._icon:set_image(icon)
end

function bar:set_value(value)
	self._progress:set_value(value)
end

function bar:hide()
	self._widget.visible = false
end

function bar:show()
	-- If a dialog is already open, hide that one
	if last_shown_dialog and last_shown_dialog ~= self then
		last_shown_dialog:hide()
	end
	last_shown_dialog = self

	self._widget.screen = lunaconf.screens.primary()

	-- Recalculate all sizes on the new screen
	recalculate_sizes(self)

	-- Center dialog in screen
	awful.placement.centered(self._widget)

	-- Show dialog
	self._widget.visible = true
	-- Reset hide timer again
	self._timeout:again()
end

local function new(_, icon_name, timeout)
	local self = {}
	for k,v in pairs(_) do
		self[k] = v
	end

	local icon = lunaconf.icons.lookup_icon(icon_name)

	self._icon = wibox.widget.imagebox(icon)
	self._icon_margin = wibox.container.margin(self._icon)

	self._progress = wibox.widget {
		color = theme.dialog_bar_fg,
		background_color = theme.dialog_bar_bg,
		max_value = 100,
		widget = wibox.widget.progressbar
	}

	local container = wibox.widget {
		self._icon_margin,
		self._progress,
		layout = wibox.layout.fixed.horizontal
	}

	self._widget = wibox {
		widget = container,
		bg = theme.dialog_bg or theme.bg_normal,
		fg = theme.dialog_fg or theme.fg_normal,
		visible = false,
		opacity = 0.9,
		ontop = true,
		type = 'notification'
	}

	self._timeout = gears.timer.start_new(timeout or 3, function()
		self:hide()
	end)

	return self
end

return setmetatable(bar, { __call = new })
