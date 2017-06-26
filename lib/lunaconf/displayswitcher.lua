local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	config = require('lunaconf.config'),
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	keys = require('lunaconf.keys'),
	screens = require('lunaconf.screens'),
	strings = require('lunaconf.strings'),
	theme = require('lunaconf.theme'),
	utils = require('lunaconf.utils')
}

local switcher = {}

local modes = { 'Extend', 'Clone' }

local theme = lunaconf.theme.get()

local script = lunaconf.utils.scriptpath() .. 'displayswitcher.py'
local display_icon = lunaconf.icons.lookup_icon('preferences-desktop-display')

local function set_mode(mode)
	-- Pass the configured dpi to the screen so it can use these instead
	-- of the ones it determined from xrandr infos
	local dpis = lunaconf.config.get('dpi', nil)
	local dpi_arg = ''
	if dpis then
		local dpi_strings = {}
		for k,v in pairs(dpis) do
			table.insert(dpi_strings, k .. '=' .. tostring(v))
		end
		if #dpi_strings > 0 then
			dpi_arg = ' --dpi ' .. table.concat(dpi_strings, ',')
		end
	end

	local cmd = string.format('%s %s %s', script, mode, dpi_arg)
	awful.spawn.spawn(cmd)
end

local function apply_and_hide(self)
	if self.has_multiple_displays then
		-- If we detected multiple displays apply the chosen configuration
		if self.current > 0 then
			set_mode(modes[self.current]:lower())
		end
	else
		-- If there is only a single display detected execute the auto setup on
		-- closing of the displayswitcher, so you can use it to reset possibly unplugged
		-- displays.
		set_mode('auto')
	end
	self.widget.visible = false
end

local function next_mode(self)
	self.current = gears.math.cycle(#modes, self.current + 1)
	self.label.text = modes[self.current]
end

local function setup_keygrabber(self)
	keygrabber.run(function(mod, key, event)
		if key == self.key and event == 'press' then
			if self.has_multiple_displays then
				next_mode(self)
			end
		elseif key ~= self.key and event == 'release' then
			-- If we release any other key than the actual trigger key (which rotates
			-- through the options) apply the config and hide it
			keygrabber.stop()
			apply_and_hide(self)
		end
	end)
end

local function show(self)
	-- If the switcher is already shown don't do anything
	if self.widget.visible then
		return
	end

	local screen = lunaconf.screens.primary()
	-- Before showing it, place it on the main screen
	self.widget.screen = screen

	-- Recalculate values that are dpi dependant
	self.widget.width = lunaconf.dpi.x(250, screen)
	self.widget.height = lunaconf.dpi.y(50, screen)
	self.icon_margin.top = lunaconf.dpi.y(4, screen)
	self.icon_margin.bottom = lunaconf.dpi.y(4, screen)
	self.icon_margin.left = lunaconf.dpi.y(4, screen)
	self.icon_margin.right = lunaconf.dpi.y(10, screen)

	-- Center the widget in the screen
	awful.placement.centered(self.widget)

	awful.spawn.easy_async(script .. ' query', function(out, err, reason, code)
		if code ~= 0 then
			self.has_multiple_displays = false
			self.label.text = 'Display only @ ' .. lunaconf.strings.trim(out)
		else
			self.has_multiple_displays = true
			self.label.text = 'Displays @ ' .. lunaconf.strings.trim(out)
			self.current = 0
		end
		self.widget.visible = true
		setup_keygrabber(self)
	end)

end

local function new(self, modifiers, key)
	local icon = wibox.widget.imagebox(display_icon)
	self.label = wibox.widget {
		widget = wibox.widget.textbox,
		font = theme.large_font or theme.font
	}
	self.icon_margin = wibox.container.margin(icon)

	local container = wibox.widget {
		self.icon_margin,
		self.label,
		layout = wibox.layout.fixed.horizontal
	}

	self.widget = wibox {
		widget = container,
		screen = lunaconf.screens.primary(),
		bg = theme.dialog_bg or theme.bg_normal,
		fg = theme.dialog_fg or theme.fg_normal,
		visible = false,
		opacity = 0.9,
		ontop = true,
		shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 6) end,
		type = 'notification'
	}

	lunaconf.keys.globals(awful.key(modifiers, key, function() show(self) end))

	self.key = key

	-- When initializin this widget (usually at awesome reload) update dpis on all
	-- displays via this script.
	set_mode('dpi-only')

	return nil
end

return setmetatable(switcher, { __call = new })
