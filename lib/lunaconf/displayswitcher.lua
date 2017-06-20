local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	keys = require('lunaconf.keys'),
	screens = require('lunaconf.screens'),
	strings = require('lunaconf.strings'),
	utils = require('lunaconf.utils')
}

local switcher = {}

local modes = { 'Clone', 'Extend' }

local script = lunaconf.utils.scriptpath() .. 'displayswitcher.py'
local display_icon = lunaconf.icons.lookup_icon('preferences-desktop-display')

local function apply_and_hide(self)
	if self.has_multiple_displays then
		-- If we detected multiple displays apply the chosen configuration
		awful.spawn.spawn(script .. ' ' .. modes[self.current]:lower())
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
		-- TODO: remove !
		self.widget.visible = false
		return
	end

	local screen = lunaconf.screens.primary()
	-- Before showing it, place it on the main screen
	self.widget.screen = screen

	-- Recalculate heights that are dpi dependant
	self.widget.width = lunaconf.dpi.x(250, screen)
	self.widget.height = lunaconf.dpi.y(50, screen)

	-- Center the widget in the screen
	awful.placement.centered(self.widget)

	awful.spawn.easy_async(script, function(out, err, reason, code)
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
	self.label = wibox.widget.textbox()
	local label_bg = wibox.container.background(self.label, nil)
	label_bg:set_fg('#000000')

	local container = wibox.widget {
		icon,
		label_bg,
		-- self.label,
		layout = wibox.layout.fixed.horizontal
	}

	self.widget = wibox {
		widget = container,
		screen = lunaconf.screens.primary(),
		bg = '#FFFFFF',
		visible = false,
		opacity = 1.0,
		ontop = true,
		shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 6) end,
		type = 'notification'
	}

	lunaconf.keys.globals(awful.key(modifiers, key, function() show(self) end))

	self.key = key

	return nil
end

return setmetatable(switcher, { __call = new })
