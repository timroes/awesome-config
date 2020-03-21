local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	config = require('lunaconf.config'),
	dialogs = require('lunaconf.dialogs'),
	dpi = require('lunaconf.dpi'),
	icons = require('lunaconf.icons'),
	keys = require('lunaconf.keys'),
	screens = require('lunaconf.screens'),
	strings = require('lunaconf.strings'),
	theme = require('lunaconf.theme'),
	utils = require('lunaconf.utils')
}

local switcher = {}

local modes = { 'Extend', 'Clone', 'Game' }

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
	self._dialog:hide()
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
	if self._dialog:is_visible() then
		return
	end

	self._dialog:recalculate_sizes(function (screen)
		-- Recalculate values that are dpi dependant
		self.icon_margin.top = lunaconf.dpi.y(4, screen)
		self.icon_margin.bottom = lunaconf.dpi.y(4, screen)
		self.icon_margin.left = lunaconf.dpi.y(4, screen)
		self.icon_margin.right = lunaconf.dpi.y(10, screen)
	end)

	awful.spawn.easy_async(script .. ' query', function(out, err, reason, code)
		local connected_display_count = #gears.string.split(out, ',')
		if code ~= 0 then
			self.has_multiple_displays = false
			self.label.text = 'Display only @ ' .. lunaconf.strings.trim(out)
		else
			self.has_multiple_displays = true
			self.current = 0
			self.label.text = tostring(connected_display_count) .. ' displays connected'
		end
		self._dialog:show()
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

	self._dialog = lunaconf.dialogs.base {
		widget = container,
		width = 250,
		height = 50
	}

	lunaconf.keys.globals(awful.key(modifiers, key, function() show(self) end))

	self.key = key

	-- When initializin this widget (usually at awesome reload) update dpis on all
	-- displays via this script.
	set_mode('dpi-only')

	return nil
end

return setmetatable(switcher, { __call = new })
