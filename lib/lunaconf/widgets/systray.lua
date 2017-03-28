local wibox = require('wibox')
local screens = require('lunaconf.screens')
local dpi = require('lunaconf.dpi')
local config = require('lunaconf.config')
local gears = require('gears')
local awesome = awesome
local tostring = tostring

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
	self._panel = awful.wibar({
		stretch = true,
		ontop = true,
		position = 'bottom',
		type = 'utility'
	})

	local syswidget = wibox.widget.systray()

	self._panel:setup {
		syswidget,
		layout = wibox.layout.fixed.horizontal
	}

	self._panel.fit = function(self, context, w, h)
		local x, y = syswidget:fit(context, icon_dpi_size_x, icon_dpi_size_y)
		return x, y
	end

	self._panel:set_widget(syswidget)
	self._panel.visible = true
	-- local w, h = syswidget:fit(icon_dpi_size_x, icon_dpi_size_y)
	-- self._panel.width = w
	-- self._panel.height = h
	-- self._panel.x = screen.geometry.x + screen.geometry.width - w - padding
	-- self._panel.y = math.ceil(screen.geometry.y + screen.geometry.height - h)

	syswidget:connect_signal("widget::updated", function()
		dbg("systray::updated")
		-- local w, h = syswidget:fit(icon_dpi_size_x, icon_dpi_size_y)
		-- self._panel.width = w
		-- self._panel.height = h
		-- self._panel.x = screen.geometry.x + screen.geometry.width - w - padding
		-- self._panel.y = math.ceil(screen.geometry.y + screen.geometry.height - h)
		-- -- Show systray when it changed
		-- self._panel.visible = true
		-- gears.timer.start_new(5.0, function()
		-- 	self._panel.visible = false
		-- end)
	end)

	return self
end

return setmetatable(systray, { __call = new })
