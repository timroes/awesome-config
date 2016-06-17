local wibox = require('wibox')
local screens = require('lunaconf.screens')
local dpi = require('lunaconf.dpi')
local config = require('lunaconf.config')
local awesome = awesome

local systray = {}

local screen = screens.primary()

local icon_size = config.get('systray.size', 50)
local icon_dpi_size_x = dpi.x(icon_size, screen)
local icon_dpi_size_y = dpi.y(icon_size, screen)
local padding = dpi.x(10, screen)

function systray:toggle()
	self._panel.visible = not self._panel.visible
end

local function new(self)
	self._panel = wibox({
		ontop = true,
		type = 'utility'
	})

	local hide_timer = timer({ timeout = 5 })
	hide_timer:connect_signal("timeout", function()
		self._panel.visible = false
		hide_timer:stop()
	end)

	local syswidget = wibox.widget.systray()

	self._panel:set_widget(syswidget)

	syswidget:connect_signal("widget::updated", function()
		local w, h = syswidget:fit(icon_dpi_size_x, icon_dpi_size_y)
		self._panel.width = w
		self._panel.height = h
		self._panel.x = screen.geometry.width - w - padding
		self._panel.y = math.ceil(screen.geometry.height - h)
		-- Show systray when it changed
		self._panel.visible = true
		hide_timer:again()
		hide_timer:start()
	end)

	return self
end

return setmetatable(systray, { __call = new })
