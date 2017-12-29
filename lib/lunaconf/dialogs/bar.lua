local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	theme = require('lunaconf.theme'),
	dialogs = {
		base = require('lunaconf.dialogs.base')
	}
}

local bar = {}

local theme = lunaconf.theme.get()

local function recalculate_sizes(self, screen)
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

function bar:show()
	-- Recalculate all sizes on the new screen
	self._base:recalculate_sizes(function (screen)
		recalculate_sizes(self, screen)
	end)

	-- Show dialog
	self._base:show()
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

	self._base = lunaconf.dialogs.base {
		widget = container,
		width = 250,
		height = 50,
		timeout = timeout or 3
	}

	return self
end

return setmetatable(bar, { __call = new })
