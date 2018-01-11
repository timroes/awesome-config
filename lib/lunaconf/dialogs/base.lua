local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	screens = require('lunaconf.screens'),
	theme = require('lunaconf.theme')
}

local theme = lunaconf.theme.get()

local base = {}

local last_shown_dialog

function base:recalculate_sizes(callback)
	local screen = lunaconf.screens.primary()
	self._widget.screen = screen
	self._widget.height = lunaconf.dpi.y(self._height, screen)
	self._widget.width = lunaconf.dpi.x(self._width, screen)

	-- Set dialog margins
	if self._margin then
		self._margin_widget.top = lunaconf.dpi.y(self._margin, screen)
		self._margin_widget.bottom = lunaconf.dpi.y(self._margin, screen)
		self._margin_widget.left = lunaconf.dpi.x(self._margin, screen)
		self._margin_widget.right = lunaconf.dpi.x(self._margin, screen)
	end

	self._widget.shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, lunaconf.dpi.x(4, screen))
	end

	-- Center dialog in screen
	awful.placement.centered(self._widget)

	-- Call the provided callback to let the dialog itself recalculate sizes
	if callback then
		callback(screen)
	end
end

function base:set_raw_dimensions(width, height)
	self._widget.height = height + 2 * lunaconf.dpi.y(self._margin, self._widget.screen)
	self._widget.width = width + 2 * lunaconf.dpi.x(self._margin, self._widget.screen)

	awful.placement.centered(self._widget)
end

function base:is_visible()
	return self._widget.visible
end

function base:hide()
	self._widget.visible = false
end

function base:show()
	-- If a dialog is already open, hide that one
	if last_shown_dialog and last_shown_dialog ~= self then
		last_shown_dialog:hide()
	end
	last_shown_dialog = self

	self._widget.visible = true

	if self._hide_timeout then
		self._hide_timeout:again()
	end
end

local function new(_, params)
	local self = {}
	for k,v in pairs(_) do
		self[k] = v
	end

	self._width = params.width
	self._height = params.height
	self._timeout = params.timeout

	self._margin = params.margin
	self._margin_widget = wibox.layout.margin(params.widget)

	self._widget = wibox {
		widget = self._margin_widget,
		bg = theme.dialog_bg or theme.bg_normal,
		fg = theme.dialog_fg or theme.fg_normal,
		visible = false,
		opacity = params.opacity or 0.9,
		ontop = true,
		type = 'notification'
	}

	if self._timeout then
		self._hide_timeout = gears.timer.start_new(self._timeout, function()
			self:hide()
		end)
	end

	return self
end

return setmetatable(base, { __call = new })
